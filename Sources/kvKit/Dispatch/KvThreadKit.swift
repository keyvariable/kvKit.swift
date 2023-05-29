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
//  KvThreadKit.swift
//  kvKit
//
//  Created by Svyatoslav Popov on 17.01.2021.
//

import Foundation



// TODO: Delete in 6.0.0
/// Various auxiliaries related to threads and synchronization.
@available(*, deprecated, message: "Use standard methods of `NSLocking` protocol and it's particular implementations")
public class KvThreadKit { }



// MARK: NSLocking

// TODO: Delete in 6.0.0
@available(*, deprecated, message: "Use standard methods of `NSLocking` protocol and it's particular implementations")
extension KvThreadKit {

    // TODO: Delete in 6.0.0
    /// A shortcut to execute *body* while *lock* is being locked.
    ///
    /// - Returns: The result of *body* invocation.
    @available(*, deprecated, message: "Use standard `NSLocking.withLock(_:)` method of `lock` instance")
    @inlinable
    public static func locking<R>(_ lock: NSLocking, body: () throws -> R) rethrows -> R {
        lock.lock()
        defer { lock.unlock() }

        return try body()
    }



    // TODO: Delete in 6.0.0
    /// A shortcut to execute *body* while optional *lock* is being locked.
    ///
    /// - Returns: The result of *body* invocation or `nil`.
    ///
    /// - Note: *body* is invoked even if *lock* is `nil`.
    @inlinable
    @available(*, deprecated, message: "Use standard `NSLocking.withLock(_:)` method of `lock` instance")
    public static func locking<T, R>(_ lock: T?, body: () throws -> R) rethrows -> R
    where T : NSLocking
    {
        lock != nil ? try locking(lock!, body: body) : try body()
    }


    // TODO: Delete in 6.0.0
    /// A shortcut trying to execute *body* while *lock* is being locked. *body* is not invoked then *lock* has already been locked.
    @available(*, deprecated, message: "It's deprecated due to lack of flexibility in comparison with standard functionality of NSLock")
    @inlinable
    public static func tryLocking(_ lock: NSLock, body: () throws -> Void) rethrows {
        guard lock.try() else { return }

        defer { lock.unlock() }

        try body()
    }


    // TODO: Delete in 6.0.0
    /// A shortcut trying to execute *body* while *lock* is being locked. *body* is not invoked then *lock* has already been locked.
    @available(*, deprecated, message: "It's deprecated due to lack of flexibility in comparison with standard functionality of NSRecursiveLock")
    @inlinable
    public static func tryLocking(_ lock: NSRecursiveLock, body: () throws -> Void) rethrows {
        guard lock.try() else { return }

        defer { lock.unlock() }

        try body()
    }

}
