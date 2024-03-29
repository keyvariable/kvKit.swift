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
//  KvNumericallyEquatable.swift
//  kvKit
//
//  Created by Svyatoslav Popov on 21.09.2022.
//

// MARK: - KvNumericallyEquatable

/// Methods to compare entities for equality taking into account the computational error.
public protocol KvNumericallyEquatable {

    /// - Returns: A boolean value indicating whether the receiver is equal to *rhs* taking into account the computational error.
    ///
    /// - Note: See `KvIs(_:equalTo:)` methods for standard floating point types.
    /// - Note: E.g. 0.1 · 10 is 1.0 but `(0..<10).reduce(0.0, { a, _ in a + 0.1 }) == 1.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
    func isEqual(to rhs: Self) -> Bool

    /// - Returns: A boolean value indicating whether the receiver is inequal to *rhs* taking into account the computational error.
    ///
    /// - Note: See `KvIs(_:inequalTo:)` methods for standard floating point types.
    /// - Note: E.g. 0.1 · 10 is 1.0 but `(0..<10).reduce(0.0, { a, _ in a + 0.1 }) == 1.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
    func isInequal(to rhs: Self) -> Bool

}


// MARK: Default Implementations

extension KvNumericallyEquatable {

    /// - Returns: A boolean value indicating whether the receiver is inequal to *rhs* taking into account the computational error.
    ///
    /// - Note: See `KvIs(_:inequalTo:)` methods for standard floating point types.
    /// - Note: E.g. 0.1 · 10 is 1.0 but `(0..<10).reduce(0.0, { a, _ in a + 0.1 }) == 1.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
    @inlinable public func isInequal(to rhs: Self) -> Bool { !isEqual(to: rhs) }

}


// MARK: Static Methods

extension KvNumericallyEquatable {

    /// - Returns: A boolean value indicating whether the receiver is equal to *rhs* taking into account the computational error.
    ///
    /// - Note: See `KvIs(_:equalTo:)` methods for standard floating point types.
    /// - Note: E.g. 0.1 · 10 is 1.0 but `(0..<10).reduce(0.0, { a, _ in a + 0.1 }) == 1.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
    @inlinable public static func isEqual(_ lhs: Self, to rhs: Self) -> Bool { lhs.isEqual(to: rhs) }

    /// - Returns: A boolean value indicating whether the receiver is inequal to *rhs* taking into account the computational error.
    ///
    /// - Note: See `KvIs(_:inequalTo:)` methods for standard floating point types.
    /// - Note: E.g. 0.1 · 10 is 1.0 but `(0..<10).reduce(0.0, { a, _ in a + 0.1 }) == 1.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
    @inlinable public static func isInequal(_ lhs: Self, to rhs: Self) -> Bool { lhs.isInequal(to: rhs) }

}



// MARK: - KvNumericallyZeroEquatable

/// Methods to compare entities for equality to zero taking into account the computational error.
public protocol KvNumericallyZeroEquatable {

    /// - Returns: A boolean value indicating whether the receiver is equal to zero taking into account the computational error.
    ///
    /// - Note: See `KvIsZero(_:)` methods for standard floating point types.
    /// - Note: E.g. 1 – 0.1 · 10 is 0.0 but `(0..<10).reduce(1.0, { a, _ in a - 0.1 }) == 0.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
    func isZero() -> Bool

    /// - Returns: A boolean value indicating whether the receiver is not equal to zero taking into account the computational error.
    ///
    /// - Note: See `KvIsNonzero(_:)` methods for standard floating point types.
    /// - Note: E.g. 1 – 0.1 · 10 is 0.0 but `(0..<10).reduce(1.0, { a, _ in a - 0.1 }) == 0.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
    func isNonzero() -> Bool

}


// MARK: Default Implementations

extension KvNumericallyZeroEquatable {

    /// - Returns: A boolean value indicating whether the receiver is not equal to zero taking into account the computational error.
    ///
    /// - Note: See `KvIsNonzero(_:)` methods for standard floating point types.
    /// - Note: E.g. 1 – 0.1 · 10 is 0.0 but `(0..<10).reduce(1.0, { a, _ in a - 0.1 }) == 0.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
    @inlinable public func isNonzero() -> Bool { !isZero() }

}


// MARK: Static Methods

extension KvNumericallyZeroEquatable {

    /// - Returns: A boolean value indicating whether the receiver is equal to zero taking into account the computational error.
    ///
    /// - Note: See `KvIsZero(_:)` methods for standard floating point types.
    /// - Note: E.g. 1 – 0.1 · 10 is 0.0 but `(0..<10).reduce(1.0, { a, _ in a - 0.1 }) == 0.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
    @inlinable public static func isZero(_ v: Self) -> Bool { v.isZero() }

    /// - Returns: A boolean value indicating whether the receiver is not equal to zero taking into account the computational error.
    ///
    /// - Note: See `KvIsNonzero(_:)` methods for standard floating point types.
    /// - Note: E.g. 1 – 0.1 · 10 is 0.0 but `(0..<10).reduce(1.0, { a, _ in a - 0.1 }) == 0.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
    @inlinable public static func isNonzero(_ v: Self) -> Bool { v.isNonzero() }

}
