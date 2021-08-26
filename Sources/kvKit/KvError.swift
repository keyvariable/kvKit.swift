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

    #if DEBUG
    public let file: StaticString
    public let line: UInt
    #endif // DEBUG



    #if DEBUG
    @inlinable
    public init(_ message: String, _ file: StaticString = #fileID, _ line: UInt = #line) {
        self.message = message
        self.file = file
        self.line = line
    }

    #else // !DEBUG
    @inlinable
    public init(_ message: String) {
        self.message = message
    }
    #endif // !DEBUG



    #if DEBUG
    @inlinable
    public static func inconsistency(_ message: String, _ file: StaticString = #fileID, _ line: UInt = #line) -> KvError {
        .init("Internal inconsistency: \(message)", file, line)
    }

    #else // !DEBUG
    @inlinable
    public static func inconsistency(_ message: String) -> KvError {
        .init("Internal inconsistency: \(message)")
    }
    #endif // !DEBUG

}



// MARK: : LocalizedError

extension KvError : LocalizedError {

    @inlinable
    public var errorDescription: String? {
        #if DEBUG
        "\(message) | \(file):\(line)"
        #else // !DEBUG
        return message
        #endif // !DEBUG
    }

}



// MARK: Logging

extension KvError {

    /// - Returns: *self* for cascading.
    @discardableResult @inlinable
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
        #if DEBUG
        return KvDebug.pause(self, file, line)
        #else // !DEBUG
        KvDebug.pause(self)
        #endif // !DEBUG
    }

}



// MARK: .Storage

extension KvError {

    public struct Accumulator<Error> : LocalizedError where Error : Swift.Error {

        public private(set) var errors: [Error]


        public var first: Error { errors.first! }
        public var last: Error { errors.last! }



        public init(_ error: Error) { errors = [ error ] }



        public init(_ first: Error, _ others: Error...) {
            errors = [ first ]
            errors.append(contentsOf: others)
        }



        public init?<Errors>(_ errors: Errors) where Errors : Sequence, Errors.Element == Error {
            var iterator = errors.makeIterator()

            guard let first = iterator.next() else { return nil }

            self.errors = [ first ]

            while let next = iterator.next() {
                self.errors.append(next)
            }
        }



        // MARK: Operations

        public mutating func append(_ error: Error) { errors.append(error) }



        /// Invokes *body* for all errors, traversing all the hierarchy of accumulators starting from the receiver.
        @inlinable
        public func traverse(body: (Swift.Error) -> Void) {
            errors.forEach {
                ($0 as? Accumulator<Swift.Error>)?.traverse(body: body)
                    ?? body($0)
            }
        }



        // MARK: : LocalizedError

        public var errorDescription: String? {

            func Description(of error: Error) -> String? {
                switch error {
                case let error as LocalizedError:
                    return error.errorDescription
                default:
                    return error.localizedDescription
                }
            }


            return errors.count != 1
                ? KvStringKit.Accumulator(errors.lazy.compactMap(Description(of:)), separator: "\n").string
                : Description(of: errors.first!)
        }


        public var failureReason: String? {

            func FailureReason(of error: Error) -> String? { (error as? LocalizedError)?.failureReason }


            return errors.count != 1
                ? KvStringKit.Accumulator(errors.lazy.compactMap(FailureReason(of:)), separator: "\n").string
                : FailureReason(of: errors.first!)
        }


        public var helpAnchor: String? {

            func HelpAnchor(of error: Error) -> String? { (error as? LocalizedError)?.helpAnchor }


            return errors.count != 1
                ? KvStringKit.Accumulator(errors.lazy.compactMap(HelpAnchor(of:)), separator: "\n").string
                : HelpAnchor(of: errors.first!)
        }


        public var recoverySuggestion: String? {

            func RecoverySuggestion(of error: Error) -> String? { (error as? LocalizedError)?.recoverySuggestion }


            return errors.count != 1
                ? KvStringKit.Accumulator(errors.lazy.compactMap(RecoverySuggestion(of:)), separator: "\n").string
                : RecoverySuggestion(of: errors.first!)
        }

    }

}
