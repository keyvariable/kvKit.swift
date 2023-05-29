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

    /// Invokes associated callbacks when destroyed.
    ///
    /// - Note: This class is not threadsafe.
    public class Token<Wrapped> : Hashable {

        public typealias Wrapped = Wrapped

        public typealias ReleaseCallback = (Wrapped) -> Void


        public var wrapped: Wrapped


        @inlinable
        public init(_ wrapped: Wrapped, releaseCallback: @escaping ReleaseCallback) {
            self.wrapped = wrapped
            self.releaseCallbacks = [ releaseCallback ]
        }


        deinit { release() }


        @usableFromInline
        internal private(set) var releaseCallbacks: [ReleaseCallback]


        // MARK: : Equatable

        @inlinable public static func ==(lhs: Token, rhs: Token) -> Bool { lhs === rhs }


        // MARK: : Hashable

        @inlinable public func hash(into hasher: inout Hasher) { ObjectIdentifier(self).hash(into: &hasher) }


        // MARK: Operations

        @inlinable
        public func addReleaseCallback(_ releaseCallback: @escaping ReleaseCallback) {
            releaseCallbacks.append(releaseCallback)
        }


        /// Invoke this method to release the receiver immediately.
        ///
        /// - Note: Sometimes it helps to prevent the «never read» compiler warning.
        @inlinable
        public func release() {
            releaseCallbacks.forEach { $0(wrapped) }
            releaseCallbacks.removeAll()
        }

    }

}


extension KvRAII.Token where Wrapped == Void {

    @inlinable
    public convenience init(releaseCallback: @escaping ReleaseCallback) {
        self.init((), releaseCallback: releaseCallback)
    }

}


// TODO: Remove in 6.0.0.
extension KvRAII.Token where Wrapped == Any? {

    // TODO: Delete in 6.0.0.
    @available(*, deprecated, renamed: "wrapped")
    @inlinable
    public var userData: Any? {
        get { wrapped }
        set { wrapped = newValue }
    }


    // TODO: Delete in 6.0.0.
    @available(*, deprecated, message: "Use generic .init(_:releaseCallback:)")
    @inlinable
    public convenience init(userData: Any? = nil, releaseCallback: @escaping ReleaseCallback) {
        self.init(userData, releaseCallback: releaseCallback)
    }

}



// MARK: .TokenSet

extension KvRAII {

    /// This class manages a set of tokens and executes given callback when it's empty state changes.
    ///
    /// Tokens are removed automatically when released. So there is no need to remove tokens explicitely.
    ///
    /// - Note: This class is thread-safe.
    public class TokenSet {

        public typealias EmptyCallback = (Bool) -> Void

        // TODO: Delete in 6.0.0
        @available(*, deprecated, renamed: "EmptyCallback")
        public typealias IsEmptyCallback = EmptyCallback


        /// A callback to be invoked when the receiver's empty state is changed.
        public var emptyCallback: EmptyCallback {
            get { mutationLock.withLock { _emptyCallback } }
            set { mutationLock.withLock { _emptyCallback = newValue } }
        }

        // TODO: Delete in 6.0.0
        @available(*, deprecated, renamed: "emptyCallback")
        @inlinable
        public var isEmptyCallback: IsEmptyCallback {
            get { emptyCallback }
            set { emptyCallback = newValue }
        }


        public init(emptyCallback: @escaping EmptyCallback) {
            self._emptyCallback = emptyCallback
        }

        // TODO: Delete in 6.0.0
        @available(*, deprecated, renamed: "init(emptyCallback:)")
        @inlinable
        public convenience init(isEmptyCallback: @escaping IsEmptyCallback) {
            self.init(emptyCallback: isEmptyCallback)
        }


        private let mutationLock = NSLock()

        /// - Warning: Access must be protected by `.mutationLock`.
        private var _count: Int = 0 {
            willSet { assert(newValue >= 0, "Internal inconsistency: attempt to assign \(newValue) to count property") }
        }

        /// - Warning: Access must be protected by `.mutationLock`.
        private var _emptyCallback: EmptyCallback


        // MARK: Access

        /// - Returns: A boolean value indicating whether the receiver is empty.
        public var isEmpty: Bool { mutationLock.withLock { _count <= 0 } }


        // MARK: Mutation

        /// This method creates a token and stores it in the receiver.
        public func make<Wrapped>(_ wrapped: Wrapped) -> Token<Wrapped> {
            increaseCount()

            return Token<Wrapped>(wrapped) { [weak self] _ in
                self?.decreaseCount()
            }
        }


        /// This method creates a token and stores it in the receiver.
        @inlinable
        public func make() -> Token<Void> { make(()) }


        /// This method creates a token and stores it in the receiver.
        public func make<Wrapped>(_ wrapped: Wrapped, releaseCallback: @escaping Token<Wrapped>.ReleaseCallback) -> Token<Wrapped> {
            let token = make(wrapped)

            token.addReleaseCallback(releaseCallback)

            return token
        }


        // TODO: Delete in 6.0.0
        /// This method creates a token and stores it in the receiver.
        @available(*, deprecated, renamed: "make(_:releaseCallback:)")
        @inlinable
        public func make(userData: Any? = nil, releaseCallback: @escaping Token<Any?>.ReleaseCallback) -> Token<Any?> {
            make(userData, releaseCallback: releaseCallback)
        }


        private func increaseCount() {
            let wasEmpty: Bool
            let emptyCallback: EmptyCallback
            do {
                mutationLock.lock()
                defer { mutationLock.unlock() }

                emptyCallback = _emptyCallback

                defer { _count += 1 }
                wasEmpty = _count == 0
            }

            if wasEmpty {
                emptyCallback(false)
            }
        }


        private func decreaseCount() {
            let becameEmpty: Bool
            let emptyCallback: EmptyCallback
            do {
                mutationLock.lock()
                defer { mutationLock.unlock() }

                emptyCallback = _emptyCallback

                _count -= 1
                becameEmpty = _count == 0
            }

            if becameEmpty {
                emptyCallback(true)
            }
        }

    }

}
