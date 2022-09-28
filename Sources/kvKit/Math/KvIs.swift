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
//  KvIs.swift
//  Kvkit
//
//  Created by Svyatoslav Popov on 18.08.2020.
//

import simd



// MARK: Auxiliaries

@inlinable
public func KvUlp<T : FloatingPoint>(of value: T) -> T {
    .ulpOfOne * Swift.max(Swift.min(Swift.abs(16 * value), T.greatestFiniteMagnitude), T.ulpOfOne)
}



// MARK: FP Comparisons

/// - Returns: A boolean value indicating whether *lhs* is equal to *rhs* taking into account the computational error.
///
/// - Note: E.g. 0.1 · 10 is 1.0 but `(0..<10).reduce(0.0, { a, _ in a + 0.1 }) == 1.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
@inlinable
public func KvIs<T : FloatingPoint>(_ lhs: T, equalTo rhs: T) -> Bool {
    let eps = KvUlp(of: lhs)

    return lhs < rhs + eps && lhs > rhs - eps
}


/// - Parameter greaterFlag: Destination for a boolean value indicating whether *lhs* is greater than *rhs* taking into account the computational error.
///
/// - Returns: A boolean value indicating whether *lhs* is equal to *rhs* taking into account the computational error.
///
/// - Note: It is designed to be applied when equality case is primary but the order is significant in opposite case.
/// - Note: It's faster to check the flag than to compare the same values twice.
/// - Note: E.g. 0.1 · 10 is 1.0 but `(0..<10).reduce(0.0, { a, _ in a + 0.1 }) == 1.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
@inlinable
public func KvIs<T : FloatingPoint>(_ lhs: T, equalTo rhs: T, alsoIsGreaterThan greaterFlag: inout Bool) -> Bool {
    let eps = KvUlp(of: lhs)

    greaterFlag = lhs >= rhs + eps

    return lhs > rhs - eps && !greaterFlag
}



/// - Returns: A boolean value indicating whether *lhs* is inequal to *rhs* taking into account the computational error.
///
/// - Note: E.g. 0.1 · 10 is 1.0 but `(0..<10).reduce(0.0, { a, _ in a + 0.1 }) == 1.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
@inlinable
public func KvIs<T : FloatingPoint>(_ lhs: T, inequalTo rhs: T) -> Bool {
    let eps = KvUlp(of: lhs)

    return lhs >= rhs + eps || lhs <= rhs - eps
}



/// - Parameter greaterFlag: Destination for a boolean value indicating whether *lhs* is greater than *rhs* taking into account the computational error.
///
/// - Returns: A boolean value indicating whether *lhs* is inequal to *rhs* taking into account the computational error.
///
/// - Note: It is designed to be applied when inequality case is primary and the order is significant. E.g. *guard* statement.
/// - Note: It's faster to check the flag than to compare the same values twice.
/// - Note: E.g. 0.1 · 10 is 1.0 but `(0..<10).reduce(0.0, { a, _ in a + 0.1 }) == 1.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
@inlinable
public func KvIs<T : FloatingPoint>(_ lhs: T, inequalTo rhs: T, alsoIsGreaterThan greaterFlag: inout Bool) -> Bool {
    let eps = KvUlp(of: lhs)

    greaterFlag = lhs >= rhs + eps

    return lhs <= rhs - eps || greaterFlag
}



/// - Returns: A boolean value indicating whether *lhs* is greater than *rhs* taking into account the computational error.
///
/// - Note: E.g. 0.1 · 10 is 1.0 but `(0..<10).reduce(0.0, { a, _ in a + 0.1 }) == 1.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
@inlinable
public func KvIs<T : FloatingPoint>(_ lhs: T, greaterThan rhs: T) -> Bool {
    lhs >= rhs + KvUlp(of: lhs)
}



/// - Parameter lessFlag: Destination for a boolean value indicating whether *lhs* is less than *rhs* taking into account the computational error.
///
/// - Returns: A boolean value indicating whether *lhs* is greater than *rhs* taking into account the computational error.
///
/// - Note: It is designed to be applied when descendence case is primary but ascendence is significant in opposite case.
/// - Note: It's faster to check the flag than to compare the same values twice.
/// - Note: E.g. 0.1 · 10 is 1.0 but `(0..<10).reduce(0.0, { a, _ in a + 0.1 }) == 1.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
@inlinable
public func KvIs<T : FloatingPoint>(_ lhs: T, greaterThan rhs: T, alsoIsLessThan lessFlag: inout Bool) -> Bool {
    let eps = KvUlp(of: lhs)

    lessFlag = lhs <= rhs - eps

    return lhs >= rhs + eps
}




/// - Returns: A boolean value indicating whether *lhs* is less than *rhs* taking into account the computational error.
///
/// - Note: E.g. 0.1 · 10 is 1.0 but `(0..<10).reduce(0.0, { a, _ in a + 0.1 }) == 1.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
@inlinable
public func KvIs<T : FloatingPoint>(_ lhs: T, lessThan rhs: T) -> Bool {
    lhs <= rhs - KvUlp(of: lhs)
}



/// - Parameter greaterFlag: Destination for a boolean value indicating whether *lhs* is greater than *rhs* taking into account the computational error.
///
/// - Returns: A boolean value indicating whether *lhs* is less than *rhs* taking into account the computational error.
///
/// - Note: It is designed to be applied when ascendence case is primary but descendence is significant in opposite case.
/// - Note: It's faster to check the flag than to compare the same values twice.
/// - Note: E.g. 0.1 · 10 is 1.0 but `(0..<10).reduce(0.0, { a, _ in a + 0.1 }) == 1.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
@inlinable
public func KvIs<T : FloatingPoint>(_ lhs: T, lessThan rhs: T, alsoIsGreaterThan greaterFlag: inout Bool) -> Bool {
    let eps = KvUlp(of: lhs)

    greaterFlag = lhs >= rhs + eps

    return lhs <= rhs - eps
}



/// - Returns: A boolean value indicating whether *lhs* is greater than or equal to *rhs* taking into account the computational error.
///
/// - Note: E.g. 0.1 · 10 is 1.0 but `(0..<10).reduce(0.0, { a, _ in a + 0.1 }) == 1.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
@inlinable
public func KvIs<T : FloatingPoint>(_ lhs: T, greaterThanOrEqualTo rhs: T) -> Bool {
    lhs > rhs - KvUlp(of: lhs)
}



/// - Returns: A boolean value indicating whether *lhs* is less than or equal to *rhs* taking into account the computational error.
///
/// - Note: E.g. 0.1 · 10 is 1.0 but `(0..<10).reduce(0.0, { a, _ in a + 0.1 }) == 1.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
@inlinable
public func KvIs<T : FloatingPoint>(_ lhs: T, lessThanOrEqualTo rhs: T) -> Bool {
    lhs < rhs + KvUlp(of: lhs)
}



/// - Returns: A boolean value indicating whether *value* is equal to zero taking into account the computational error.
///
/// - Note: E.g. 1 – 0.1 · 10 is 0.0 but `(0..<10).reduce(1.0, { a, _ in a - 0.1 }) == 0.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
@inlinable
public func KvIsZero<T : FloatingPoint>(_ value: T) -> Bool {
    abs(value) < 16 * .ulpOfOne
}



/// - Parameter positiveFlag: Destination for a boolean value indicating whether *value* is positive taking into account the computational error.
///
/// - Returns: A boolean value indicating whether *value* is equal to zero taking into account the computational error.
///
/// - Note: It is designed to be applied when equality case is primary but the sign is significant in opposite case.
/// - Note: It's faster to check the flag than to compare the same values twice.
/// - Note: E.g. 1 – 0.1 · 10 is 0.0 but `(0..<10).reduce(1.0, { a, _ in a - 0.1 }) == 0.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
@inlinable
public func KvIsZero<T : FloatingPoint>(_ value: T, alsoIsPositive positiveFlag: inout Bool) -> Bool {
    let eps: T = 16 * .ulpOfOne

    positiveFlag = value >= eps

    return !positiveFlag && value > -eps
}



/// - Returns: A boolean value indicating whether *value* is not equal to zero taking into account the computational error.
///
/// - Note: E.g. 1 – 0.1 · 10 is 0.0 but `(0..<10).reduce(1.0, { a, _ in a - 0.1 }) == 0.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
@inlinable
public func KvIsNonzero<T : FloatingPoint>(_ value: T) -> Bool {
    abs(value) >= 16 * .ulpOfOne
}



/// - Parameter positiveFlag: Destination for a boolean value indicating whether *value* is positive taking into account the computational error.
///
/// - Returns: A boolean value indicating whether *value* is not equal to zero taking into account the computational error.
///
/// - Note: It is designed to be applied when inequality case is primary and the sign is significant. E.g. *guard* statement.
/// - Note: It's faster to check the flag than to compare the same values twice.
/// - Note: E.g. 1 – 0.1 · 10 is 0.0 but `(0..<10).reduce(1.0, { a, _ in a - 0.1 }) == 0.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
@inlinable
public func KvIsNonzero<T : FloatingPoint>(_ value: T, alsoIsPositive positiveFlag: inout Bool) -> Bool {
    let eps: T = 16 * .ulpOfOne

    positiveFlag = value >= eps

    return positiveFlag || value <= -eps
}



/// - Returns: A boolean value indicating whether *value* is positive taking into account the computational error.
///
/// - Note: E.g. 1 – 0.1 · 10 is 0.0 but `(0..<10).reduce(1.0, { a, _ in a - 0.1 }) == 0.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
@inlinable
public func KvIsPositive<T : FloatingPoint>(_ value: T) -> Bool {
    value >= 16 * .ulpOfOne
}



/// - Parameter negativeFlag: Destination for a boolean value indicating whether *value* is negative taking into account the computational error.
///
/// - Returns: A boolean value indicating whether *value* is positive taking into account the computational error.
///
/// - Note: It is designed to be applied when positivity case is primary but the sign is significant in opposite case.
/// - Note: It's faster to check the flag than to compare the same values twice.
/// - Note: E.g. 1 – 0.1 · 10 is 0.0 but `(0..<10).reduce(1.0, { a, _ in a - 0.1 }) == 0.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
@inlinable
public func KvIsPositive<T : FloatingPoint>(_ value: T, alsoIsNegative negativeFlag: inout Bool) -> Bool {
    let eps: T = 16 * .ulpOfOne

    negativeFlag = value <= -eps

    return value >= eps
}



/// - Returns: A boolean value indicating whether *value* is negative taking into account the computational error.
///
/// - Note: E.g. 1 – 0.1 · 10 is 0.0 but `(0..<10).reduce(1.0, { a, _ in a - 0.1 }) == 0.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
@inlinable
public func KvIsNegative<T : FloatingPoint>(_ value: T) -> Bool {
    value <= -16 * .ulpOfOne
}



/// - Parameter positiveFlag: Destination for a boolean value indicating whether *value* is positive taking into account the computational error.
///
/// - Returns: A boolean value indicating whether *value* is negative taking into account the computational error.
///
/// - Note: It is designed to be applied when negativity case is primary but the sign is significant in opposite case.
/// - Note: It's faster to check the flag than to compare the same values twice.
/// - Note: E.g. 1 – 0.1 · 10 is 0.0 but `(0..<10).reduce(1.0, { a, _ in a - 0.1 }) == 0.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
@inlinable
public func KvIsNegative<T : FloatingPoint>(_ value: T, alsoIsPositive positiveFlag: inout Bool) -> Bool {
    let eps: T = 16 * .ulpOfOne

    positiveFlag = value >= eps

    return value <= -eps
}



/// - Returns: A boolean value indicating whether *value* isn't positive taking into account the computational error.
///
/// - Note: E.g. 1 – 0.1 · 10 is 0.0 but `(0..<10).reduce(1.0, { a, _ in a - 0.1 }) == 0.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
@inlinable
public func KvIsNotPositive<T : FloatingPoint>(_ value: T) -> Bool {
    value < 16 * .ulpOfOne
}



/// - Returns: A boolean value indicating whether *value* isn't negative taking into account the computational error.
///
/// - Note: E.g. 1 – 0.1 · 10 is 0.0 but `(0..<10).reduce(1.0, { a, _ in a - 0.1 }) == 0.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
@inlinable
public func KvIsNotNegative<T : FloatingPoint>(_ value: T) -> Bool {
    value > -16 * .ulpOfOne
}



// MARK: FP Optional Comparisons

/// - Returns: A boolean value indicating whether *lhs* is equal to *rhs* taking into account the computational error.
///
/// - Note: E.g. 0.1 · 10 is 1.0 but `(0..<10).reduce(0.0, { a, _ in a + 0.1 }) == 1.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
@inlinable
public func KvIs<T : FloatingPoint>(_ lhs: T?, equalTo rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case (.some(let lhs), .some(let rhs)):
        return KvIs(lhs, equalTo: rhs)
    case (.none, .none):
        return true
    case (.some, .none), (.none, .some):
        return false
    }
}


/// - Returns: A boolean value indicating whether *lhs* is inequal to *rhs* taking into account the computational error.
///
/// - Note: E.g. 0.1 · 10 is 1.0 but `(0..<10).reduce(0.0, { a, _ in a + 0.1 }) == 1.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
@inlinable
public func KvIs<T : FloatingPoint>(_ lhs: T?, inequalTo rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case (.some(let lhs), .some(let rhs)):
        return KvIs(lhs, inequalTo: rhs)
    case (.none, .none):
        return false
    case (.some, .none), (.none, .some):
        return true
    }
}



// MARK: FP Range Comparisons

/// - Returns: A boolean value indicating whether *range* contains *value* taking into account the computational error.
///
/// - Note: E.g. 0.1 · 10 is 1.0 but `(0..<10).reduce(0.0, { a, _ in a + 0.1 }) == 1.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
@inlinable
public func KvIs<T : FloatingPoint>(_ value: T, in range: Range<T>) -> Bool {
    KvIs(value, greaterThanOrEqualTo: range.lowerBound) && KvIs(value, lessThan: range.upperBound)
}



/// - Returns: A boolean value indicating whether *range* contains *value* taking into account the computational error.
///
/// - Note: E.g. 0.1 · 10 is 1.0 but `(0..<10).reduce(0.0, { a, _ in a + 0.1 }) == 1.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
@inlinable
public func KvIs<T : FloatingPoint>(_ value: T, in range: ClosedRange<T>) -> Bool {
    KvIs(value, greaterThanOrEqualTo: range.lowerBound) && KvIs(value, lessThanOrEqualTo: range.upperBound)
}



/// - Returns: A boolean value indicating whether *range* contains *value* taking into account the computational error.
///
/// - Note: E.g. 0.1 · 10 is 1.0 but `(0..<10).reduce(0.0, { a, _ in a + 0.1 }) == 1.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
@inlinable
public func KvIs<T : FloatingPoint>(_ value: T, in range: PartialRangeFrom<T>) -> Bool {
    KvIs(value, greaterThanOrEqualTo: range.lowerBound)
}



/// - Returns: A boolean value indicating whether *range* contains *value* taking into account the computational error.
///
/// - Note: E.g. 0.1 · 10 is 1.0 but `(0..<10).reduce(0.0, { a, _ in a + 0.1 }) == 1.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
@inlinable
public func KvIs<T : FloatingPoint>(_ value: T, in range: PartialRangeUpTo<T>) -> Bool {
    KvIs(value, lessThan: range.upperBound)
}



/// - Returns: A boolean value indicating whether *range* contains *value* taking into account the computational error.
///
/// - Note: E.g. 0.1 · 10 is 1.0 but `(0..<10).reduce(0.0, { a, _ in a + 0.1 }) == 1.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
@inlinable
public func KvIs<T : FloatingPoint>(_ value: T, in range: PartialRangeThrough<T>) -> Bool {
    KvIs(value, lessThanOrEqualTo: range.upperBound)
}



/// - Returns: A boolean value indicating whether *value* is out of *range* taking into account the computational error.
///
/// - Note: E.g. 0.1 · 10 is 1.0 but `(0..<10).reduce(0.0, { a, _ in a + 0.1 }) == 1.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
@inlinable
public func KvIs<T : FloatingPoint>(_ value: T, outOf range: Range<T>) -> Bool {
    KvIs(value, lessThan: range.lowerBound) || KvIs(value, greaterThanOrEqualTo: range.upperBound)
}



/// - Returns: A boolean value indicating whether *value* is out of *range* taking into account the computational error.
///
/// - Note: E.g. 0.1 · 10 is 1.0 but `(0..<10).reduce(0.0, { a, _ in a + 0.1 }) == 1.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
@inlinable
public func KvIs<T : FloatingPoint>(_ value: T, outOf range: ClosedRange<T>) -> Bool {
    KvIs(value, lessThan: range.lowerBound) || KvIs(value, greaterThan: range.upperBound)
}



/// - Returns: A boolean value indicating whether *value* is out of *range* taking into account the computational error.
///
/// - Note: E.g. 0.1 · 10 is 1.0 but `(0..<10).reduce(0.0, { a, _ in a + 0.1 }) == 1.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
@inlinable
public func KvIs<T : FloatingPoint>(_ value: T, outOf range: PartialRangeFrom<T>) -> Bool {
    KvIs(value, lessThan: range.lowerBound)
}



/// - Returns: A boolean value indicating whether *value* is out of *range* taking into account the computational error.
///
/// - Note: E.g. 0.1 · 10 is 1.0 but `(0..<10).reduce(0.0, { a, _ in a + 0.1 }) == 1.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
@inlinable
public func KvIs<T : FloatingPoint>(_ value: T, outOf range: PartialRangeUpTo<T>) -> Bool {
    KvIs(value, greaterThanOrEqualTo: range.upperBound)
}



/// - Returns: A boolean value indicating whether *value* is out of *range* taking into account the computational error.
///
/// - Note: E.g. 0.1 · 10 is 1.0 but `(0..<10).reduce(0.0, { a, _ in a + 0.1 }) == 1.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
@inlinable
public func KvIs<T : FloatingPoint>(_ value: T, outOf range: PartialRangeThrough<T>) -> Bool {
    KvIs(value, greaterThan: range.upperBound)
}



/// - Returns: A boolean value indicating whether *lhs* is equal to *rhs* taking into account the computational error.
///
/// - Note: E.g. 0.1 · 10 is 1.0 but `(0..<10).reduce(0.0, { a, _ in a + 0.1 }) == 1.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
@inlinable
public func KvIs<T : FloatingPoint>(_ lhs: Range<T>, equalTo rhs: Range<T>) -> Bool {
    KvIs(lhs.lowerBound, equalTo: rhs.lowerBound) && KvIs(lhs.upperBound, equalTo: rhs.upperBound)
}

/// - Returns: A boolean value indicating whether *lhs* is equal to *rhs* taking into account the computational error.
///
/// - Note: E.g. 0.1 · 10 is 1.0 but `(0..<10).reduce(0.0, { a, _ in a + 0.1 }) == 1.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
@inlinable
public func KvIs<T : FloatingPoint>(_ lhs: Range<T>, equalTo rhs: PartialRangeFrom<T>) -> Bool {
    KvIs(lhs.lowerBound, equalTo: rhs.lowerBound) && lhs.upperBound == .infinity
}

/// - Returns: A boolean value indicating whether *lhs* is equal to *rhs* taking into account the computational error.
///
/// - Note: E.g. 0.1 · 10 is 1.0 but `(0..<10).reduce(0.0, { a, _ in a + 0.1 }) == 1.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
@inlinable
public func KvIs<T : FloatingPoint>(_ lhs: Range<T>, equalTo rhs: PartialRangeUpTo<T>) -> Bool {
    lhs.upperBound == -.infinity && KvIs(lhs.upperBound, equalTo: rhs.upperBound)
}

/// - Returns: A boolean value indicating whether *lhs* is equal to *rhs* taking into account the computational error.
///
/// - Note: E.g. 0.1 · 10 is 1.0 but `(0..<10).reduce(0.0, { a, _ in a + 0.1 }) == 1.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
@inlinable
public func KvIs<T : FloatingPoint>(_ lhs: ClosedRange<T>, equalTo rhs: ClosedRange<T>) -> Bool {
    KvIs(lhs.lowerBound, equalTo: rhs.lowerBound) && KvIs(lhs.upperBound, equalTo: rhs.upperBound)
}

/// - Returns: A boolean value indicating whether *lhs* is equal to *rhs* taking into account the computational error.
///
/// - Note: E.g. 0.1 · 10 is 1.0 but `(0..<10).reduce(0.0, { a, _ in a + 0.1 }) == 1.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
@inlinable
public func KvIs<T : FloatingPoint>(_ lhs: ClosedRange<T>, equalTo rhs: PartialRangeFrom<T>) -> Bool {
    KvIs(lhs.lowerBound, equalTo: rhs.lowerBound) && lhs.upperBound == .infinity
}

/// - Returns: A boolean value indicating whether *lhs* is equal to *rhs* taking into account the computational error.
///
/// - Note: E.g. 0.1 · 10 is 1.0 but `(0..<10).reduce(0.0, { a, _ in a + 0.1 }) == 1.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
@inlinable
public func KvIs<T : FloatingPoint>(_ lhs: ClosedRange<T>, equalTo rhs: PartialRangeThrough<T>) -> Bool {
    lhs.upperBound == -.infinity && KvIs(lhs.upperBound, equalTo: rhs.upperBound)
}

/// - Returns: A boolean value indicating whether *lhs* is equal to *rhs* taking into account the computational error.
///
/// - Note: E.g. 0.1 · 10 is 1.0 but `(0..<10).reduce(0.0, { a, _ in a + 0.1 }) == 1.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
@inlinable
public func KvIs<T : FloatingPoint>(_ lhs: PartialRangeFrom<T>, equalTo rhs: PartialRangeFrom<T>) -> Bool {
    KvIs(lhs.lowerBound, equalTo: rhs.lowerBound)
}

/// - Returns: A boolean value indicating whether *lhs* is equal to *rhs* taking into account the computational error.
///
/// - Note: E.g. 0.1 · 10 is 1.0 but `(0..<10).reduce(0.0, { a, _ in a + 0.1 }) == 1.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
@inlinable
public func KvIs<T : FloatingPoint>(_ lhs: PartialRangeFrom<T>, equalTo rhs: Range<T>) -> Bool {
    KvIs(lhs.lowerBound, equalTo: rhs.lowerBound) && rhs.upperBound == .infinity
}

/// - Returns: A boolean value indicating whether *lhs* is equal to *rhs* taking into account the computational error.
///
/// - Note: E.g. 0.1 · 10 is 1.0 but `(0..<10).reduce(0.0, { a, _ in a + 0.1 }) == 1.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
@inlinable
public func KvIs<T : FloatingPoint>(_ lhs: PartialRangeFrom<T>, equalTo rhs: ClosedRange<T>) -> Bool {
    KvIs(lhs.lowerBound, equalTo: rhs.lowerBound) && rhs.upperBound == .infinity
}

/// - Returns: A boolean value indicating whether *lhs* is equal to *rhs* taking into account the computational error.
///
/// - Note: E.g. 0.1 · 10 is 1.0 but `(0..<10).reduce(0.0, { a, _ in a + 0.1 }) == 1.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
@inlinable
public func KvIs<T : FloatingPoint>(_ lhs: PartialRangeUpTo<T>, equalTo rhs: PartialRangeUpTo<T>) -> Bool {
    KvIs(lhs.upperBound, equalTo: rhs.upperBound)
}

/// - Returns: A boolean value indicating whether *lhs* is equal to *rhs* taking into account the computational error.
///
/// - Note: E.g. 0.1 · 10 is 1.0 but `(0..<10).reduce(0.0, { a, _ in a + 0.1 }) == 1.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
@inlinable
public func KvIs<T : FloatingPoint>(_ lhs: PartialRangeUpTo<T>, equalTo rhs: Range<T>) -> Bool {
    rhs.lowerBound == -.infinity && KvIs(lhs.upperBound, equalTo: rhs.upperBound)
}

/// - Returns: A boolean value indicating whether *lhs* is equal to *rhs* taking into account the computational error.
///
/// - Note: E.g. 0.1 · 10 is 1.0 but `(0..<10).reduce(0.0, { a, _ in a + 0.1 }) == 1.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
@inlinable
public func KvIs<T : FloatingPoint>(_ lhs: PartialRangeThrough<T>, equalTo rhs: PartialRangeThrough<T>) -> Bool {
    KvIs(lhs.upperBound, equalTo: rhs.upperBound)
}

/// - Returns: A boolean value indicating whether *lhs* is equal to *rhs* taking into account the computational error.
///
/// - Note: E.g. 0.1 · 10 is 1.0 but `(0..<10).reduce(0.0, { a, _ in a + 0.1 }) == 1.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
@inlinable
public func KvIs<T : FloatingPoint>(_ lhs: PartialRangeThrough<T>, equalTo rhs: ClosedRange<T>) -> Bool {
    rhs.lowerBound == -.infinity && KvIs(lhs.upperBound, equalTo: rhs.upperBound)
}



/// - Returns: A boolean value indicating whether *lhs* is inequal to *rhs* taking into account the computational error.
///
/// - Note: E.g. 0.1 · 10 is 1.0 but `(0..<10).reduce(0.0, { a, _ in a + 0.1 }) == 1.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
@inlinable
public func KvIs<T : FloatingPoint>(_ lhs: Range<T>, inequalTo rhs: Range<T>) -> Bool {
    KvIs(lhs.lowerBound, inequalTo: rhs.lowerBound) || KvIs(lhs.upperBound, inequalTo: rhs.upperBound)
}

/// - Returns: A boolean value indicating whether *lhs* is inequal to *rhs* taking into account the computational error.
///
/// - Note: E.g. 0.1 · 10 is 1.0 but `(0..<10).reduce(0.0, { a, _ in a + 0.1 }) == 1.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
@inlinable
public func KvIs<T : FloatingPoint>(_ lhs: Range<T>, inequalTo rhs: PartialRangeFrom<T>) -> Bool {
    KvIs(lhs.lowerBound, inequalTo: rhs.lowerBound) || lhs.upperBound != .infinity
}

/// - Returns: A boolean value indicating whether *lhs* is inequal to *rhs* taking into account the computational error.
///
/// - Note: E.g. 0.1 · 10 is 1.0 but `(0..<10).reduce(0.0, { a, _ in a + 0.1 }) == 1.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
@inlinable
public func KvIs<T : FloatingPoint>(_ lhs: Range<T>, inequalTo rhs: PartialRangeUpTo<T>) -> Bool {
    lhs.upperBound != -.infinity || KvIs(lhs.upperBound, inequalTo: rhs.upperBound)
}

/// - Returns: A boolean value indicating whether *lhs* is inequal to *rhs* taking into account the computational error.
///
/// - Note: E.g. 0.1 · 10 is 1.0 but `(0..<10).reduce(0.0, { a, _ in a + 0.1 }) == 1.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
@inlinable
public func KvIs<T : FloatingPoint>(_ lhs: ClosedRange<T>, inequalTo rhs: ClosedRange<T>) -> Bool {
    KvIs(lhs.lowerBound, inequalTo: rhs.lowerBound) || KvIs(lhs.upperBound, inequalTo: rhs.upperBound)
}

/// - Returns: A boolean value indicating whether *lhs* is inequal to *rhs* taking into account the computational error.
///
/// - Note: E.g. 0.1 · 10 is 1.0 but `(0..<10).reduce(0.0, { a, _ in a + 0.1 }) == 1.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
@inlinable
public func KvIs<T : FloatingPoint>(_ lhs: ClosedRange<T>, inequalTo rhs: PartialRangeFrom<T>) -> Bool {
    KvIs(lhs.lowerBound, inequalTo: rhs.lowerBound) || lhs.upperBound != .infinity
}

/// - Returns: A boolean value indicating whether *lhs* is inequal to *rhs* taking into account the computational error.
///
/// - Note: E.g. 0.1 · 10 is 1.0 but `(0..<10).reduce(0.0, { a, _ in a + 0.1 }) == 1.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
@inlinable
public func KvIs<T : FloatingPoint>(_ lhs: ClosedRange<T>, inequalTo rhs: PartialRangeThrough<T>) -> Bool {
    lhs.upperBound != -.infinity || KvIs(lhs.upperBound, inequalTo: rhs.upperBound)
}

/// - Returns: A boolean value indicating whether *lhs* is inequal to *rhs* taking into account the computational error.
///
/// - Note: E.g. 0.1 · 10 is 1.0 but `(0..<10).reduce(0.0, { a, _ in a + 0.1 }) == 1.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
@inlinable
public func KvIs<T : FloatingPoint>(_ lhs: PartialRangeFrom<T>, inequalTo rhs: PartialRangeFrom<T>) -> Bool {
    KvIs(lhs.lowerBound, inequalTo: rhs.lowerBound)
}

/// - Returns: A boolean value indicating whether *lhs* is inequal to *rhs* taking into account the computational error.
///
/// - Note: E.g. 0.1 · 10 is 1.0 but `(0..<10).reduce(0.0, { a, _ in a + 0.1 }) == 1.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
@inlinable
public func KvIs<T : FloatingPoint>(_ lhs: PartialRangeFrom<T>, inequalTo rhs: Range<T>) -> Bool {
    KvIs(lhs.lowerBound, inequalTo: rhs.lowerBound) || rhs.upperBound != .infinity
}

/// - Returns: A boolean value indicating whether *lhs* is inequal to *rhs* taking into account the computational error.
///
/// - Note: E.g. 0.1 · 10 is 1.0 but `(0..<10).reduce(0.0, { a, _ in a + 0.1 }) == 1.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
@inlinable
public func KvIs<T : FloatingPoint>(_ lhs: PartialRangeFrom<T>, inequalTo rhs: ClosedRange<T>) -> Bool {
    KvIs(lhs.lowerBound, inequalTo: rhs.lowerBound) || rhs.upperBound != .infinity
}

/// - Returns: A boolean value indicating whether *lhs* is inequal to *rhs* taking into account the computational error.
///
/// - Note: E.g. 0.1 · 10 is 1.0 but `(0..<10).reduce(0.0, { a, _ in a + 0.1 }) == 1.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
@inlinable
public func KvIs<T : FloatingPoint>(_ lhs: PartialRangeUpTo<T>, inequalTo rhs: PartialRangeUpTo<T>) -> Bool {
    KvIs(lhs.upperBound, inequalTo: rhs.upperBound)
}

/// - Returns: A boolean value indicating whether *lhs* is inequal to *rhs* taking into account the computational error.
///
/// - Note: E.g. 0.1 · 10 is 1.0 but `(0..<10).reduce(0.0, { a, _ in a + 0.1 }) == 1.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
@inlinable
public func KvIs<T : FloatingPoint>(_ lhs: PartialRangeUpTo<T>, inequalTo rhs: Range<T>) -> Bool {
    rhs.lowerBound != -.infinity || KvIs(lhs.upperBound, inequalTo: rhs.upperBound)
}

/// - Returns: A boolean value indicating whether *lhs* is inequal to *rhs* taking into account the computational error.
///
/// - Note: E.g. 0.1 · 10 is 1.0 but `(0..<10).reduce(0.0, { a, _ in a + 0.1 }) == 1.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
@inlinable
public func KvIs<T : FloatingPoint>(_ lhs: PartialRangeThrough<T>, inequalTo rhs: PartialRangeThrough<T>) -> Bool {
    KvIs(lhs.upperBound, inequalTo: rhs.upperBound)
}

/// - Returns: A boolean value indicating whether *lhs* is inequal to *rhs* taking into account the computational error.
///
/// - Note: E.g. 0.1 · 10 is 1.0 but `(0..<10).reduce(0.0, { a, _ in a + 0.1 }) == 1.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
@inlinable
public func KvIs<T : FloatingPoint>(_ lhs: PartialRangeThrough<T>, inequalTo rhs: ClosedRange<T>) -> Bool {
    rhs.lowerBound != -.infinity || KvIs(lhs.upperBound, inequalTo: rhs.upperBound)
}



/// - Returns: A boolean value indicating whether given range is degenerate.
///
/// - Note: E.g. 0.1 · 10 is 1.0 but `(0..<10).reduce(0.0, { a, _ in a + 0.1 }) == 1.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
@inlinable public func KvIsDegenerate<T : FloatingPoint>(_ r: Range<T>) -> Bool { KvIs(r.lowerBound, equalTo: r.upperBound) }

/// - Returns: A boolean value indicating whether given range is degenerate.
///
/// - Note: E.g. 0.1 · 10 is 1.0 but `(0..<10).reduce(0.0, { a, _ in a + 0.1 }) == 1.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
@inlinable public func KvIsDegenerate<T : FloatingPoint>(_ r: ClosedRange<T>) -> Bool { KvIs(r.lowerBound, equalTo: r.upperBound) }



// MARK: Power of 2

@inlinable
public func KvIsPowerOf2<T>(_ value: T) -> Bool where T : FixedWidthInteger {
    value > 0 && value.nonzeroBitCount == 1
}

/// - Note: Works for negative powers of two.
@inlinable
public func KvIsPowerOf2<T>(_ value: T) -> Bool where T : BinaryFloatingPoint {
    value > 0 && value.significandWidth == 0
}



// MARK: Legacy

@available(*, deprecated, renamed: "KvIs(_:equalTo:alsoIsGreaterThan:)")
@inlinable
public func KvIs<T : FloatingPoint>(_ lhs: T, equalTo rhs: T, alsoIsGreaterThen greaterFlag: inout Bool) -> Bool {
    KvIs(lhs, equalTo: rhs, alsoIsGreaterThan: &greaterFlag)
}



@available(*, deprecated, renamed: "KvIs(_:inequalTo:alsoIsGreaterThan:)")
@inlinable
public func KvIs<T : FloatingPoint>(_ lhs: T, inequalTo rhs: T, alsoIsGreaterThen greaterFlag: inout Bool) -> Bool {
    KvIs(lhs, inequalTo: rhs, alsoIsGreaterThan: &greaterFlag)
}



@available(*, deprecated, renamed: "KvIs(_:greaterThan:)")
@inlinable
public func KvIs<T : FloatingPoint>(_ lhs: T, greaterThen rhs: T) -> Bool {
    KvIs(lhs, greaterThan: rhs)
}



@available(*, deprecated, renamed: "KvIs(_:greaterThan:alsoIsLessThan:)")
@inlinable
public func KvIs<T : FloatingPoint>(_ lhs: T, greaterThen rhs: T, alsoIsLessThen lessFlag: inout Bool) -> Bool {
    KvIs(lhs, greaterThan: rhs, alsoIsLessThan: &lessFlag)
}



@available(*, deprecated, renamed: "KvIs(_:lessThan:)")
@inlinable
public func KvIs<T : FloatingPoint>(_ lhs: T, lessThen rhs: T) -> Bool {
    KvIs(lhs, lessThan: rhs)
}



@available(*, deprecated, renamed: "KvIs(_:lessThan:alsoIsGreaterThan:)")
@inlinable
public func KvIs<T : FloatingPoint>(_ lhs: T, lessThen rhs: T, alsoIsGreaterThen greaterFlag: inout Bool) -> Bool {
    KvIs(lhs, lessThan: rhs, alsoIsGreaterThan: &greaterFlag)
}



@available(*, deprecated, renamed: "KvIs(_:greaterThanOrEqualTo:)")
@inlinable
public func KvIs<T : FloatingPoint>(_ lhs: T, greaterThenOrEqualTo rhs: T) -> Bool {
    KvIs(lhs, greaterThanOrEqualTo: rhs)
}



@available(*, deprecated, renamed: "KvIs(_:lessThanOrEqualTo:)")
@inlinable
public func KvIs<T : FloatingPoint>(_ lhs: T, lessThenOrEqualTo rhs: T) -> Bool {
    KvIs(lhs, lessThanOrEqualTo: rhs)
}
