//===----------------------------------------------------------------------===//
//
//  Copyright (c) 2021 Svyatoslav Popov (info@keyvar.com).
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
//  KvFileKit.swift
//  kvKit
//
//  Created by Svyatoslav Popov on 03.02.2018.
//

import Foundation



public struct KvFileKit { private init() { } }



// MARK: File Manipilations

extension KvFileKit {

    /// Simple file item replacement procedure.
    ///
    /// First method removes the old backup item if exists.
    /// Then It appends ".bak" extension to original item, moves replacement to original URL, then deletes or reverts the backup item whether replacements has successfully moved.
    ///
    /// - Throws: ``ReplaceError``.
    ///
    /// - Note: This method is suitable for directories.
    public static func replaceItem(at originalURL: URL, withItemAt replacementURL: URL) throws {
        let fileManager = FileManager.default

        switch fileManager.fileExists(atPath: originalURL.path) {
        case true:
            let backupURL = originalURL.appendingPathExtension("bak")

            if fileManager.fileExists(atPath: backupURL.path) {
                do { try fileManager.removeItem(at: backupURL) }
                catch { throw ReplaceError.unableToRemoveOldBackupItem(backupURL, error) }
            }

            do { try fileManager.moveItem(at: originalURL, to: backupURL) }
            catch { throw ReplaceError.unableToMoveItem(at: originalURL, to: backupURL) }

            do { try fileManager.moveItem(at: replacementURL, to: originalURL) }
            catch {
                // Revert the backup.
                do { try fileManager.moveItem(at: backupURL, to: originalURL) }
                catch { print("ERROR: Failed to revert the backup at `\(backupURL)` to original `\(originalURL)`") }

                throw ReplaceError.unableToMoveItem(at: replacementURL, to: originalURL)
            }

        case false:
            do { try fileManager.moveItem(at: replacementURL, to: originalURL) }
            catch { throw ReplaceError.unableToMoveItem(at: replacementURL, to: originalURL) }
        }
    }


    // MARK: .ReplaceError

    /// Enumeration of errors thrown by ``replaceItem(at:withItemAt:)``.
    public enum ReplaceError : LocalizedError {
        
        case unableToMoveItem(at: URL, to: URL)
        case unableToRemoveOldBackupItem(URL, Error)


        // MARK: : LocalizedError

        public var errorDescription: String? {
            switch self {
            case .unableToMoveItem(at: let sourceURL, to: let destinationURL):
                return "Failed to move item at `\(sourceURL)` to `\(destinationURL)`"
            case .unableToRemoveOldBackupItem(let backupURL, let error):
                return "Failed to remove old backup item at `\(backupURL)`. \(error)"
            }
        }

    }

}



// MARK: .TemporaryUrlToken

extension KvFileKit {

    public class TemporaryUrlToken {

        public let url: URL

        public let fileManager: FileManager



        public init(with url: URL, fileManager: FileManager = .default) {
            if !url.isFileURL {
                KvDebug.pause("Invalid argument: \(url) is not a file URL")
            }

            self.url = url
            self.fileManager = fileManager
        }



        deinit {
            guard fileManager.fileExists(atPath: url.path) else { return }

            do { try fileManager.removeItem(at: url) }
            catch { KvDebug.pause("Unable to remove a temporary file at \(url) with error: \(error.localizedDescription)") }
        }

    }

}
