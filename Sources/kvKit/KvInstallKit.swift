//===----------------------------------------------------------------------===//
//
//  Copyright (c) 2023 Svyatoslav Popov (info@keyvar.com).
//
//  Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with
//  the License. You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on
//  an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the
//  specific language governing permissions and limitations under the License.
//
//  SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//
//
//  KvInstallKit.swift
//  kvKit
//
//  Created by Svyatoslav Popov on 05.12.2023.
//

#if os(Linux)

import Foundation



/// Collection of auxiliary methods to be used in installation subroutines.
public struct KvInstallKit { private init() { }

    // MARK: .Constants

    private struct Constants { private init() { }

        static let ignoredFileNames: Set<String> = [ ".DS_Store", "description.json" ]
        static let ignoredFileExtensions: Set<String> = [ "autolink", "o", "swiftdoc", "swiftmodule", "swiftsourceinfo" ]

        static let ignoredDirectoryNames: Set<String> = [ ".", "..", ".git", "index", "ModuleCache" ]
        static let ignoredDirectoryExtensions: Set<String> = [ "build", "product" ]

    }



    // MARK: Working with Bundles

    /// Copies the application bundle and the shared libraries to *destinationURL*.
    public static func copyBundle(to destinationURL: URL, shell: KvShell = .init()) throws {
        let sourceRootURL = Bundle.main.bundleURL
        let temporaryRootURL = destinationURL
            .appendingPathExtension("new")

        let fileManager = FileManager.default

        // Removal of existing temporary item.
        if fileManager.fileExists(atPath: temporaryRootURL.path) {
            do { try fileManager.removeItem(at: temporaryRootURL) }
            catch { throw InstallError.unableToRemoveTemporaryItem(temporaryRootURL, error) }
        }

        try copyBundleDirectory(at: sourceRootURL, to: temporaryRootURL)
        try copySwiftLinuxSharedLibraries(to: temporaryRootURL, shell: shell)

        try KvFileKit.replaceItem(at: destinationURL, withItemAt: temporaryRootURL)
    }



    // MARK: Auxiliaries

    /// As mentionad on swift.org, the Swift shared libraries have to be deployed with applications on Linux.
    /// This method uses `$ whreis swift` command to locate the usr/bin directory the Swift is available at and copies the libraries from usr/lib/swift/linux.
    public static func copySwiftLinuxSharedLibraries(to destinationURL: URL, shell: KvShell = .init()) throws {
        let swiftBinaryPath = shell.run("whereis", with: [ "swift" ]) { output, status -> String? in
            guard case .success = status else { return nil }

            let prefix = "swift:"
            guard output.hasPrefix(prefix) else { return nil }

            let path = output[output.index(output.startIndex, offsetBy: prefix.count)...]
                .trimmingCharacters(in: .whitespacesAndNewlines)

            guard !path.isEmpty else { return nil }

            return path
        }

        guard let swiftBinaryURL = (consume swiftBinaryPath).map(URL.init(fileURLWithPath:)) else { throw InstallError.unknownSwiftPath }

        let libURL = (consume swiftBinaryURL)
            .deletingLastPathComponent()    // usr/bin
            .deletingLastPathComponent()    // usr
            .appendingPathComponent("lib")
            .appendingPathComponent("swift")
            .appendingPathComponent("linux")

        let fileManager = FileManager.default

        try fileManager.enumerator(at: libURL, includingPropertiesForKeys: nil, options: .skipsSubdirectoryDescendants)?.forEach { element in
            guard let url = element as? URL else { return }

            let fileName = url.lastPathComponent

            guard fileName.hasPrefix("lib"),
                  fileName.hasSuffix(".so") || fileName.contains(".so.")
            else { return }

            try fileManager.copyItem(at: url, to: destinationURL.appendingPathComponent(fileName))
        }
    }


    private static func copyBundleDirectory(at sourceDirectoryURL: URL, to destinationDirectoryURL: URL) throws {
        let fileManager = FileManager.default
        var isDirectoryCreated = false

        try fileManager.enumerator(at: sourceDirectoryURL, includingPropertiesForKeys: nil, options: .skipsSubdirectoryDescendants)?.forEach { element in
            guard let url = element as? URL else { return }

            let component = url.lastPathComponent

            let sourceURL = sourceDirectoryURL.appendingPathComponent(component)
            let destinationURL = destinationDirectoryURL.appendingPathComponent(component)

            var isDirectory: ObjCBool = false
            guard fileManager.fileExists(atPath: sourceURL.path, isDirectory: &isDirectory) else { return }

            switch isDirectory.boolValue {
            case false:
                guard !Constants.ignoredFileNames.contains(component),
                      !Constants.ignoredFileExtensions.contains(sourceURL.pathExtension)
                else { return }

                if !isDirectoryCreated {
                    try fileManager.createDirectory(at: destinationDirectoryURL, withIntermediateDirectories: true)
                    isDirectoryCreated = true
                }

                try fileManager.copyItem(at: sourceURL, to: destinationURL)

            case true:
                guard !Constants.ignoredDirectoryNames.contains(component),
                      !Constants.ignoredDirectoryExtensions.contains(sourceURL.pathExtension)
                else { return }

                try copyBundleDirectory(at: sourceURL, to: destinationURL)
            }
        }
    }



    // MARK: .InstallError

    public enum InstallError : LocalizedError {
        case unableToRemoveTemporaryItem(URL, Error)
        case unknownSwiftPath
    }



    // MARK: .LeastPrivilegedUser

    /// Collection of auxiliaries to manage least-privileged users.
    public struct LeastPrivilegedUser {

        public let login: String


        @inlinable
        public init(login: String) {
            self.login = login
        }


        // MARK: Operations

        /// - Parameter rootPath: Custom root path. Default path is `/home/\(self.login)`.
        public func createIfNeeded(rootPath: String? = nil, shell: KvShell = .init()) throws {
            let webUserExists = try shell.run("id", with: [ "-u", login ])
                .map { $0 == 0 }
                .get()

            guard !webUserExists else { return }

            let homePath = rootPath ?? "/home/\(login)"

            // Creating user having locked password login, no-login shell and expiration date in the past.
            try shell.run(
                "useradd",
                with: [ login,
                        "--shell=/bin/false",
                        "--home-dir=\(homePath)",
                        "--create-home",
                        "--no-user-group",
                        "--expiredate=1" /* Jan 2, 1970 */ ]
            ).orThrow()
        }


        /// Replaces file item at given URL, changes ower to the user and sets minimum access rights to copies files.
        ///
        /// - Note: The replacing procedure uses backups.
        public func replaceItem(at originalURL: URL, withItemAt replacementURL: URL, shell: KvShell = .init()) throws {
            let fileManager = FileManager.default
            let temporaryURL = originalURL
                .appendingPathExtension("new")

            // Removal of existing temporary item.
            if fileManager.fileExists(atPath: temporaryURL.path) {
                do { try fileManager.removeItem(at: temporaryURL) }
                catch { throw InstallError.unableToRemoveTemporaryItem(temporaryURL, error) }
            }

            // Move replacement to temporary path.
            try shell.run("mv", with: [ replacementURL.path, temporaryURL.path ]).orThrow()

            // Permissions
            do {
                try shell.run("chown", with: [ "-fR", login, temporaryURL.path ]).orThrow()
                try shell.run("chmod", with: [ "-fR", "u=rX,go-rwx", temporaryURL.path ]).orThrow()
            }

            try KvFileKit.replaceItem(at: originalURL, withItemAt: temporaryURL)
        }

    }



    // MARK: .Service

    /// Collection of auxilaries to manage Linux services.
    public struct Service {

        public let name: String


        
        @inlinable
        public init(name: String) {
            self.name = name
        }



        // MARK: Operations

        /// - Parameter after: Optional value for `After` key in `[Unit]` section.
        /// - Parameter user: User to launch the process from.
        /// - Parameter wantedBy: Optional value for `WantedBy` key in `[Install]` section.
        public func install(launchCommand: String, after: String? = nil, user: String? = nil, wantedBy: String? = nil, shell: KvShell = .init()) throws {
            let servicePath = "/usr/lib/systemd/system/\(name).service"

            var serviceUnit = "[Unit]\nDescription=\(name)\n"
            if let after {
                serviceUnit += "After=\(after)\n"
            }
            serviceUnit += "\n[Service]\nType=exec\nExecStart=\(launchCommand)\n"
            if let user {
                serviceUnit += "User=\(user)\n"
            }
            serviceUnit += "Restart=on-failure\nRestartSec=1s\n"
            serviceUnit += "\n[Install]\n"
            if let wantedBy {
                serviceUnit += "WantedBy=\(wantedBy)\n"
            }

            do { try serviceUnit.write(toFile: servicePath, atomically: true, encoding: .utf8) }
            catch { throw ServiceError.writeUnitFile(path: servicePath, error: error) }

            // Load service
            do { try shell.run("systemctl", with: [ "daemon-reload" ]).orThrow() }
            catch { throw ServiceError.daemonReload(error) }

            // Autostart
            do { try shell.run("systemctl", with: [ "enable", name ]).orThrow() }
            catch { throw ServiceError.enable(service: name, error: error) }
        }


        public func start(_ shell: KvShell = .init()) throws {
            do { try shell.run("systemctl", with: [ "start", name ]).orThrow() }
            catch { throw ServiceError.start(service: name, error: error) }
        }


        public func stop(_ shell: KvShell = .init()) throws {
            do { try shell.run("systemctl", with: [ "stop", name ]).orThrow() }
            catch { throw ServiceError.stop(service: name, error: error) }
        }



        // MARK: .ServiceError

        public enum ServiceError : LocalizedError {

            case daemonReload(Error)
            case enable(service: String, error: Error)
            case start(service: String, error: Error)
            case stop(service: String, error: Error)
            case writeUnitFile(path: String, error: Error)


            // MARK: : LocalizedError

            public var errorDescription: String? {
                switch self {
                case .daemonReload(let error):
                    return "Failed to reload systemctl daemon. \(error)"
                case .enable(service: let service, error: let error):
                    return "Failed to enable autostart for service `\(service)`. \(error)"
                case .start(service: let service, error: let error):
                    return "Failed to start service `\(service)`. \(error)"
                case .stop(service: let service, error: let error):
                    return "Failed to stop service `\(service)`. \(error)"
                case .writeUnitFile(let path, let error):
                    return "Failed to create/update a service unit file at `\(path)`. \(error)"
                }
            }

        }

    }

}

#endif // os(Linux)
