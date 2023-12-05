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
//  KvShell.swift
//  kvKit
//
//  Created by Svyatoslav Popov on 05.12.2023.
//

import Foundation



/// Provides simple execution of shell commands.
///
/// Currently it use's `bash` shell.
public class KvShell {

    private var resolvedCommands: [String : String] = .init()



    @inlinable public init() { }



    // MARK: Operations

    public func run(_ command: String, with arguments: [String]? = nil) -> ShellResult {
        let executable: String
        switch resolved(command: command) {
        case .success(let value):
            executable = value
        case .failure(let error):
            return .failure(error)
        }

        return Self.run(executable: executable, with: arguments)
    }


    /// - Parameter completion: Block to be invoked with ouptut of the command.
    public func run<T>(_ command: String, with arguments: [String]? = nil, completion: (String, ShellResult) -> T) -> T {
        let executable: String
        switch resolved(command: command) {
        case .success(let value):
            executable = value
        case .failure(let error):
            return completion("", .failure(error))
        }

        return Self.run(executable: executable, with: arguments, completion: completion)
    }


    private func resolved(command: String) -> Result<String, Error> {
        return { lvalue in
            switch lvalue {
            case .some(let resolvedCommand):
                return .success(resolvedCommand)

            case .none:
                return Self.run(executable: "/bin/bash", with: [ "-l", "-c", "which \(command)"]) { output, status in
                    status
                        .flatMap { status -> Result<String, Error> in
                            guard status == 0 else { return .failure(ShellError.statusCode(status)) }

                            let resolvedCommand = output.trimmingCharacters(in: .whitespacesAndNewlines)

                            lvalue = resolvedCommand
                            return .success(resolvedCommand)
                        }
                        .mapError { ShellError.bashCommandNotFound(command, $0) }
                }
            }
        }(&resolvedCommands[command])
    }


    private static func run(executable: String, with arguments: [String]? = nil) -> ShellResult {
        run(executable: executable, with: arguments, outputPipe: nil)
    }


    /// - Parameter completion: Block to be invoked with ouptut of the command and the exit code.
    private static func run<T>(executable: String, with arguments: [String]? = nil, completion: (String, ShellResult) -> T) -> T {
        let outputPipe = Pipe()

        let result = run(executable: executable, with: arguments, outputPipe: outputPipe)
        let output = String(data: outputPipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8)!

        return completion(output, result)
    }


    private static func run(executable: String, with arguments: [String]? = nil, outputPipe: Pipe?) -> ShellResult {
        guard let executableURL = URL(string: executable) else { return .failure(ShellError.executableURL(executable)) }

        let process = Process()

#if os(Linux)
        // - NOTE: It's a walkaround. Currently missing launchPath causes fatalError in Linux.
        process.launchPath = executable
#else // !os(Linux)
        process.executableURL = executableURL
#endif // os(Linux)

        process.arguments = arguments
        process.standardOutput = outputPipe

        do { try process.run() }
        catch { return .failure(error) }

        process.waitUntilExit()

        let status = process.terminationStatus

        return status == 0 ? .success : .statusCode(status)
    }



    // MARK: .ShellResult

    public enum ShellResult {

        case success
        /// Non-zero status code.
        case statusCode(Int32)
        case failure(Error)


        // MARK: Operations

        /// Thorws an error when the receiver is not ``success``.
        ///
        /// - Throws: The associated error when the receiver is ``failure`` or ``StatusError`` with the associated status when the receiver is ``statusCode``.
        @inlinable
        public func orThrow() throws {
            switch self {
            case .success:
                return
            case .failure(let error):
                throw error
            case .statusCode(let status):
                throw StatusError(status: status)
            }
        }


        /// - Parameter statusPredicate: A block returning whether passed status code is acceptable. It's invoked for non-zero status codes. Default predicate returns `false`.
        ///
        /// - Returns: A boolean value indicating whether the receiver is ``success`` or ``statusCode`` with associated value passing *statusPredicate*.
        ///
        /// - Throws: The associated error when the receiver is ``failure`` or ``StatusError`` with the associated status when the receiver is ``statusCode`` and the status failing *statusPredicate*.
        ///
        /// - SeeAlso: ``orThrow``.
        @inlinable
        public func get(statusPredicate: (Int32) -> Bool = { _ in false }) throws -> Bool {
            switch self {
            case .success:
                true
            case .statusCode(let status):
                switch statusPredicate(status) {
                case true:
                    true
                case false:
                    throw StatusError(status: status)
                }
            case .failure(let error):
                throw error
            }
        }


        /// - Parameter transform: It's invoked with the receiver's status code if any.
        @inlinable
        public func map<T>(_ transform: (Int32) -> T) -> Result<T, Error> {
            switch self {
            case .success: .success(transform(0))
            case .statusCode(let status): .success(transform(status))
            case .failure(let error): .failure(error)
            }
        }


        /// - Parameter transform: It's invoked with the receiver's status code if any.
        @inlinable
        public func flatMap<T>(_ transform: (Int32) -> Result<T, Error>) -> Result<T, Error> {
            switch self {
            case .success: transform(0)
            case .statusCode(let status): transform(status)
            case .failure(let error): .failure(error)
            }
        }


        // MARK: .StatusError

        public struct StatusError : LocalizedError {

            public let status: Int32


            @usableFromInline
            init(status: Int32) {
                self.status = status
            }

        }

    }



    // MARK: .ShellError

    public enum ShellError : LocalizedError {
        case bashCommandNotFound(String, Error)
        /// Usable to convert executable path to an URL.
        case executableURL(String)
        case statusCode(Int32)
    }

}
