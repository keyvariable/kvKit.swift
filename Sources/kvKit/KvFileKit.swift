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



public class KvFileKit { }



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
