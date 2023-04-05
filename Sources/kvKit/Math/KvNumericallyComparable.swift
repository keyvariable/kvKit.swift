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
//  KvNumericallyComparable.swift
//  
//
//  Created by Svyatoslav Popov on 21.09.2022.
//

// MARK: - KvNumericallyComparable

/// Methods to compare entities taking into account the computational error.
public protocol KvNumericallyComparable : KvNumericallyEquatable {

    /// - Parameter greaterFlag: Destination for a boolean value indicating whether the receiver is greater than *rhs* taking into account the computational error.
    ///
    /// - Returns: A boolean value indicating whether the receiver is equal to *rhs* taking into account the computational error.
    ///
    /// - Note: It's expected to be faster to check the flag than to compare the same values twice.
    /// - Note: See `KvIs(_:equalTo:alsoIsGreaterThan:)` methods for standard floating point types.
    /// - Note: E.g. 0.1 · 10 is 1.0 but `(0..<10).reduce(0.0, { a, _ in a + 0.1 }) == 1.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
    func isEqual(to rhs: Self, alsoIsGreaterThan greaterFlag: inout Bool) -> Bool

    /// - Parameter greaterFlag: Destination for a boolean value indicating whether the receiver is greater than *rhs* taking into account the computational error.
    ///
    /// - Returns: A boolean value indicating whether the receiver is inequal to *rhs* taking into account the computational error.
    ///
    /// - Note: It's expected to be faster to check the flag than to compare the same values twice.
    /// - Note: See `KvIs(_:inequalTo:alsoIsGreaterThan:)` methods for standard floating point types.
    /// - Note: E.g. 0.1 · 10 is 1.0 but `(0..<10).reduce(0.0, { a, _ in a + 0.1 }) == 1.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
    func isInequal(to rhs: Self, alsoIsGreaterThan greaterFlag: inout Bool) -> Bool

    /// - Returns: A boolean value indicating whether the receiver is greater than *rhs* taking into account the computational error.
    ///
    /// - Note: See `KvIs(_:greaterThan:)` methods for standard floating point types.
    /// - Note: E.g. 0.1 · 10 is 1.0 but `(0..<10).reduce(0.0, { a, _ in a + 0.1 }) == 1.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
    func isGreater(than rhs: Self) -> Bool

    /// - Parameter lessFlag: Destination for a boolean value indicating whether the receiver is less than *rhs* taking into account the computational error.
    ///
    /// - Returns: A boolean value indicating whether the receiver is greater than *rhs* taking into account the computational error.
    ///
    /// - Note: It's expected to be faster to check the flag than to compare the same values twice.
    /// - Note: See `KvIs(_:greaterThan:alsoIsLessThan:)` methods for standard floating point types.
    /// - Note: E.g. 0.1 · 10 is 1.0 but `(0..<10).reduce(0.0, { a, _ in a + 0.1 }) == 1.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
    func isGreater(than rhs: Self, alsoIsLessThan lessFlag: inout Bool) -> Bool

    /// - Returns: A boolean value indicating whether the receiver is less than *rhs* taking into account the computational error.
    ///
    /// - Note: See `KvIs(_:lessThan:)` methods for standard floating point types.
    /// - Note: E.g. 0.1 · 10 is 1.0 but `(0..<10).reduce(0.0, { a, _ in a + 0.1 }) == 1.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
    func isLess(than rhs: Self) -> Bool

    /// - Parameter greaterFlag: Destination for a boolean value indicating whether the receiver is greater than *rhs* taking into account the computational error.
    ///
    /// - Returns: A boolean value indicating whether the receiver is less than *rhs* taking into account the computational error.
    ///
    /// - Note: It's expected to be faster to check the flag than to compare the same values twice.
    /// - Note: See `KvIs(_:lessThan:alsoIsGreaterThan:)` methods for standard floating point types.
    /// - Note: E.g. 0.1 · 10 is 1.0 but `(0..<10).reduce(0.0, { a, _ in a + 0.1 }) == 1.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
    func isLess(than rhs: Self, alsoIsGreaterThan greaterFlag: inout Bool) -> Bool

    /// - Returns: A boolean value indicating whether the receiver is greater than or equal to *rhs* taking into account the computational error.
    ///
    /// - Note: See `KvIs(_:greaterThanOrEqualTo:)` methods for standard floating point types.
    /// - Note: E.g. 0.1 · 10 is 1.0 but `(0..<10).reduce(0.0, { a, _ in a + 0.1 }) == 1.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
    func isGreaterOrEqual(to rhs: Self) -> Bool

    /// - Returns: A boolean value indicating whether the receiver is less than or equal to *rhs* taking into account the computational error.
    ///
    /// - Note: See `KvIs(_:lessThanOrEqualTo:)` methods for standard floating point types.
    /// - Note: E.g. 0.1 · 10 is 1.0 but `(0..<10).reduce(0.0, { a, _ in a + 0.1 }) == 1.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
    func isLessOrEqual(than rhs: Self) -> Bool

}


// MARK: Default implementations

extension KvNumericallyComparable {

    @inlinable public func isGreater(than rhs: Self) -> Bool { !isLessOrEqual(than: rhs) }


    @inlinable public func isGreaterOrEqual(to rhs: Self) -> Bool { !isLess(than: rhs) }

}



// MARK: - KvNumericallyZeroComparable

/// Methods to compare entities with zero taking into account the computational error.
public protocol KvNumericallyZeroComparable : KvNumericallyZeroEquatable {

    /// - Parameter positiveFlag: Destination for a boolean value indicating whether the receiver is positive taking into account the computational error.
    ///
    /// - Returns: A boolean value indicating whether the receiver is equal to zero taking into account the computational error.
    ///
    /// - Note: It's expected to be faster to check the flag than to compare the same values twice.
    /// - Note: See `KvIsZero(_:alsoIsPositive:)` methods for standard floating point types.
    /// - Note: E.g. 1 – 0.1 · 10 is 0.0 but `(0..<10).reduce(1.0, { a, _ in a - 0.1 }) == 0.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
    func isZero(alsoIsPositive positiveFlag: inout Bool) -> Bool

    /// - Parameter positiveFlag: Destination for a boolean value indicating whether the receiver is positive taking into account the computational error.
    ///
    /// - Returns: A boolean value indicating whether the receiver is not equal to zero taking into account the computational error.
    ///
    /// - Note: It's expected to be faster to check the flag than to compare the same values twice.
    /// - Note: See `KvIsNonzero(_:alsoIsPositive:)` methods for standard floating point types.
    /// - Note: E.g. 1 – 0.1 · 10 is 0.0 but `(0..<10).reduce(1.0, { a, _ in a - 0.1 }) == 0.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
    func isNonzero(alsoIsPositive positiveFlag: inout Bool) -> Bool

    /// - Returns: A boolean value indicating whether the receiver is positive taking into account the computational error.
    ///
    /// - Note: See `KvIsPositive(_:)` methods for standard floating point types.
    /// - Note: E.g. 1 – 0.1 · 10 is 0.0 but `(0..<10).reduce(1.0, { a, _ in a - 0.1 }) == 0.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
    func isPositive() -> Bool

    /// - Parameter negativeFlag: Destination for a boolean value indicating whether the receiver is negative taking into account the computational error.
    ///
    /// - Returns: A boolean value indicating whether the receiver is positive taking into account the computational error.
    ///
    /// - Note: It's expected to be faster to check the flag than to compare the same values twice.
    /// - Note: See `KvIsPositive(_:alsoIsNegative:)` methods for standard floating point types.
    /// - Note: E.g. 1 – 0.1 · 10 is 0.0 but `(0..<10).reduce(1.0, { a, _ in a - 0.1 }) == 0.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
    func isPositive(alsoIsNegative negativeFlag: inout Bool) -> Bool

    /// - Returns: A boolean value indicating whether the receiver is negative taking into account the computational error.
    ///
    /// - Note: See `KvIsNegative(_:)` methods for standard floating point types.
    /// - Note: E.g. 1 – 0.1 · 10 is 0.0 but `(0..<10).reduce(1.0, { a, _ in a - 0.1 }) == 0.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
    func isNegative() -> Bool

    /// - Parameter positiveFlag: Destination for a boolean value indicating whether the receiver is positive taking into account the computational error.
    ///
    /// - Returns: A boolean value indicating whether the receiver is negative taking into account the computational error.
    ///
    /// - Note: It's expected to be faster to check the flag than to compare the same values twice.
    /// - Note: See `KvIsNegative(_:alsoIsPositive:)` methods for standard floating point types.
    /// - Note: E.g. 1 – 0.1 · 10 is 0.0 but `(0..<10).reduce(1.0, { a, _ in a - 0.1 }) == 0.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
    func isNegative(alsoIsPositive positiveFlag: inout Bool) -> Bool

    /// - Returns: A boolean value indicating whether the receiver is not positive taking into account the computational error.
    ///
    /// - Note: See `KvIsNotPositive(_:)` methods for standard floating point types.
    /// - Note: E.g. 1 – 0.1 · 10 is 0.0 but `(0..<10).reduce(1.0, { a, _ in a - 0.1 }) == 0.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
    func isNotPositive() -> Bool

    /// - Returns: A boolean value indicating whether the receiver is not negative taking into account the computational error.
    ///
    /// - Note: See `KvIsNotNegative(_:)` methods for standard floating point types.
    /// - Note: E.g. 1 – 0.1 · 10 is 0.0 but `(0..<10).reduce(1.0, { a, _ in a - 0.1 }) == 0.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
    func isNotNegative() -> Bool

}


// MARK: Default implementations

extension KvNumericallyZeroComparable {

    @inlinable public func isNotPositive() -> Bool { !isPositive() }


    @inlinable public func isNotNegative() -> Bool { !isNegative() }

}
