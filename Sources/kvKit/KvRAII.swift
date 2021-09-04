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

    /// Invokes given callback when destroyed.
    public class Token : Hashable {

        public typealias ReleaseCallback = (Token, Any?) -> Void



        public var userData: Any?


        fileprivate var tokenSet: TokenSet?



        public init(releaseCallback: ReleaseCallback?, userData: Any? = nil) {
            self.userData = userData
            self.releaseCallback = releaseCallback
        }



        deinit { release() }



        private var releaseCallback: ReleaseCallback?



        // MARK: Life Cycle

        /// Invoke this method to release the receiver immediately.
        ///
        /// - Note: Sometimes it helps to prevent the «never read» compiler warning.
        public func release() {
            releaseCallback?(self, userData)
            try? tokenSet?.remove(self)

            releaseCallback = nil
            tokenSet = nil
        }



        // MARK: : Equatable

        public static func ==(lhs: Token, rhs: Token) -> Bool { lhs === rhs }



        public static func !=(lhs: Token, rhs: Token) -> Bool { lhs !== rhs }



        // MARK: : Hashable

        public func hash(into hasher: inout Hasher) { ObjectIdentifier(self).hash(into: &hasher) }

    }

}



// MARK: .TokenSet

extension KvRAII {

    /// Executes a callback when becomes empty.
    ///
    /// - Warning: It's not thread-safe.
    public class TokenSet {

        public typealias IsEmptyCallback = (Bool) -> Void



        public var isEmptyCallback: IsEmptyCallback?



        public init(isEmptyCallback: IsEmptyCallback? = nil) {
            self.isEmptyCallback = isEmptyCallback
        }



        private var tokens: Set<KvWeak<Token>> = .init() {
            didSet {
                let isEmpty = tokens.isEmpty

                if isEmpty != oldValue.isEmpty {
                    isEmptyCallback?(isEmpty)
                }
            }
        }



        // MARK: Access

        public var isEmpty: Bool { tokens.isEmpty || tokens.allSatisfy { $0.value == nil } }



        public func forEach(_ body: (Token) throws -> Void) rethrows {
            try tokens.forEach {
                guard let token = $0.value else {
                    // Released tokens are removed.
                    tokens.remove($0)
                    return
                }

                try body(token)
            }
        }



        // MARK: Mutation

        public func insert(_ token: Token) {
            guard token.tokenSet !== self else { return }

            try? token.tokenSet?.remove(token)

            tokens.insert(.init(token))

            token.tokenSet = self
        }



        public func remove(_ token: Token) throws {
            guard token.tokenSet === self else {
                throw KvError.inconsistency("attempt to remove RAII token having reference to an unexpected token set")
            }
            guard tokens.remove(.init(token)) != nil else {
                throw KvError.inconsistency("attempt to remove an unexpected RAII token having token set reference to the receiver")
            }
        }

    }

}
