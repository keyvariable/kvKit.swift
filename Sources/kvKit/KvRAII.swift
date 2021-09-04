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
//  KvRAII.swift
//  kvKit
//
//  Created by Svyatoslav Popov on 10.12.2018.
//

import Foundation



/// A collection of RAII objects.
public enum KvRAII { }



// MARK: .Token

extension KvRAII {

    /// Invokes the callback when destroyed.
    public class Token : Hashable {

        public typealias ReleaseCallback = (Any?) -> Void



        public var userData: Any?



        public init(userData: Any? = nil, releaseCallback: @escaping ReleaseCallback) {
            self.userData = userData
            self.releaseCallbacks = [ releaseCallback ]
        }



        deinit { release() }



        private var releaseCallbacks: [ReleaseCallback]



        // MARK: : Equatable

        public static func ==(lhs: Token, rhs: Token) -> Bool { lhs === rhs }



        // MARK: : Hashable

        public func hash(into hasher: inout Hasher) { ObjectIdentifier(self).hash(into: &hasher) }



        // MARK: Operations

        public func addReleaseCallback(_ releaseCallback: @escaping ReleaseCallback) {
            releaseCallbacks.append(releaseCallback)
        }



        /// Invoke this method to release the receiver immediately.
        ///
        /// - Note: Sometimes it helps to prevent the «never read» compiler warning.
        public func release() {
            releaseCallbacks.removeAll {
                $0(userData)
                return true
            }
        }

    }

}



// MARK: .TokenSet

extension KvRAII {

    /// Executes a callback when becomes empty.
    public class TokenSet {

        public typealias IsEmptyCallback = (Bool) -> Void



        public var isEmptyCallback: IsEmptyCallback



        public init(isEmptyCallback: @escaping IsEmptyCallback) {
            self.isEmptyCallback = isEmptyCallback
        }



        private let mutationLock = NSLock()

        private var count: Int = 0 {
            willSet { assert(newValue >= 0, "Internal inconsistency: attempt to assign \(newValue) to count property") }
            didSet {
                guard count != oldValue else { return }

                let isEmpty = isEmpty
                if isEmpty != (oldValue <= 0) {
                    isEmptyCallback(isEmpty)
                }
            }
        }



        // MARK: Access

        public var isEmpty: Bool { KvThreadKit.locking(mutationLock) { count <= 0 } }



        // MARK: Mutation

        /// This method creates a token and stores it in the receiver. This method is convenient when empty state of the receiver is observed.
        public func make() -> Token {
            increateCount()

            return .init { [weak self] _ in
                self?.decreaseCount()
            }
        }



        public func make(userData: Any? = nil, releaseCallback: @escaping Token.ReleaseCallback) -> Token {
            let token = make()

            token.userData = userData
            token.addReleaseCallback(releaseCallback)

            return token
        }



        private func increateCount() {
            KvThreadKit.locking(mutationLock) {
                count += 1
            }
        }



        private func decreaseCount() {
            KvThreadKit.locking(mutationLock) {
                count -= 1
            }
        }

    }

}
