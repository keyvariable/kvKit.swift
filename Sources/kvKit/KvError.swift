//===----------------------------------------------------------------------===//
//
//  Copyright (c) 2021 Svyatoslav Popov.
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
//  KvError.swift
//  KvKit
//
//  Created by Svyatoslav Popov on 07.04.2019.
//

import Foundation



public struct KvError {

    public let message: String

    public let file: String
    public let line: Int



    public init(_ message: String, _ file: String = #file, _ line: Int = #line) {
        self.message = message
        self.file = file
        self.line = line
    }



    @inlinable
    public static func inconsistency(_ message: String, _ file: String = #file, _ line: Int = #line) -> KvError {
        .init("Internal inconsistency: \(message)", file, line)
    }

}



// MARK: : LocalizedError

extension KvError : LocalizedError {

    public var errorDescription: String? { "\(message) | \(file):\(line)" }

}



// MARK: Logging

extension KvError {

    /// - Returns: *self* for cascading.
    @discardableResult
    public func log() -> KvError {
        print("\(localizedDescription)")

        return self
    }

}



// MARK: KvDebug Integration

extension KvError {

    /// Executes *KvDebug.pause()* passing the receiver as first argument.
    ///
    /// - Returns: *self* for cascading.
    @discardableResult @inlinable
    public func debugPause() -> KvError {
        return KvDebug.pause(self, file, line)
    }

}
