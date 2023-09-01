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
//  KvCombine.swift
//  kvKit
//
//  Created by Svyatoslav Popov on 01.09.2023.
//
//===----------------------------------------------------------------------===//
//
//  Minimum collection of implementations required by kvKit on platforms where the Combine framework is unavailable.

#if !canImport(Darwin)

import Foundation



// MARK: - AnyCancellable

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
final public class AnyCancellable : Cancellable, Hashable {

    public init(_ cancel: @escaping () -> Void) {
        cancelBlock = cancel
    }


    public init<C>(_ canceller: C) where C : Cancellable {
        cancelBlock = { canceller.cancel() }
    }


    deinit {
        cancel()
    }


    private let mutationLock = NSLock()
    private var cancelBlock: (() -> Void)?


    // MARK: : Equatable

    @inlinable
    public static func == (lhs: AnyCancellable, rhs: AnyCancellable) -> Bool { lhs === rhs }


    // MARK: : Hashable

    public func hash(into hasher: inout Hasher) {
        ObjectIdentifier(self).hash(into: &hasher)
    }


    // MARK: Operations

    final public func cancel() {
        mutationLock.withLock {
            cancelBlock?()
            cancelBlock = nil
        }
    }

}



// MARK: - Cancellable

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public protocol Cancellable {

    func cancel()

}

#endif // !canImport(Darwin)
