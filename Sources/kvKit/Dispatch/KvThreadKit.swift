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



/// Various auxiliaries related to threads and synchronization.
public class KvThreadKit { }



// MARK: NSLocking

extension KvThreadKit {

    /// A shortcut to execute *body* while *lock* is being locked.
    ///
    /// - Returns: The result of *body* invocation.
    @inlinable
    public static func locking<R>(_ lock: NSLocking, body: () throws -> R) rethrows -> R {
        lock.lock()
        defer { lock.unlock() }

        return try body()
    }



    /// A shortcut to execute *body* while optional *lock* is being locked.
    ///
    /// - Returns: The result of *body* invocation or `nil`.
    ///
    /// - Note: *body* is invoked even if *lock* is `nil`.
    @inlinable
    public static func locking<T, R>(_ lock: T?, body: () throws -> R) rethrows -> R
    where T : NSLocking
    {
        lock != nil ? try locking(lock!, body: body) : try body()
    }



    /// A shortcut trying to execute *body* while *lock* is being locked. *body* is not invoked then *lock* has already been locked.
    @inlinable
    public static func tryLocking(_ lock: NSLock, body: () throws -> Void) rethrows {
        guard lock.try() else { return }

        defer { lock.unlock() }

        try body()
    }



    /// A shortcut trying to execute *body* while *lock* is being locked. *body* is not invoked then *lock* has already been locked.
    @inlinable
    public static func tryLocking(_ lock: NSRecursiveLock, body: () throws -> Void) rethrows {
        guard lock.try() else { return }

        defer { lock.unlock() }

        try body()
    }



    /// A shortcut to execute *body* while *lock* is being locked. If *lock* is `nil` then nothing execued and `nil` is returned.
    ///
    /// - Returns: The result of *body* invocation or `nil`.
    @available(*, deprecated, message: "Use other version of this method")
    public static func locking<T, R>(_ lock: T?, body: (T) throws -> R) rethrows -> R?
    where T : NSLocking
    {
        guard let lock = lock else { return nil }

        lock.lock()
        defer { lock.unlock() }

        return try body(lock)
    }



    /// A shortcut to execute *body* while *lock* is being locked. If *lock* is `nil` then nothing execued and `nil` is returned.
    ///
    /// - Returns: The result of *body* invocation or `nil`.
    @available(*, deprecated, message: "Use other version of this method")
    public static func locking<T>(_ lock: T?, body: (T) throws -> Void) rethrows -> Void
    where T : NSLocking
    {
        guard let lock = lock else { return }

        lock.lock()
        defer { lock.unlock() }

        try body(lock)
    }

}
