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



// MARK: .KvNumericTolerance

/// A lightweight container for numerical comparison tolerance.
///
/// Use ``KvNumericToleranceMagnitude`` to combine magnitudes and calculate tolerance once.
public struct KvNumericTolerance<T : FloatingPoint> {

    public typealias Argument = KvNumericToleranceArgument<T>


    public let value: T


    @usableFromInline
    internal init(value: T) {
        Swift.assert(value >= 0, "Invalid argument: tolerance value (\(value)) must be positive")

        self.value = value
    }

    @inlinable
    public init(_ arg: Argument) {
        self.init(value: .ulpOfOne * Swift.max(Swift.min(16 * arg.value, T.greatestFiniteMagnitude), T.ulpOfOne))
    }


    /// Default tolerance for comparisons with zero.
    @inlinable public static var zero: Self { Self(value: 16 * T.ulpOfOne) }

}



// MARK: .KvNumericToleranceMagnitude

/// A lightweight container for magnitude of numerical comparison tolerance.
public struct KvNumericToleranceArgument<T : FloatingPoint> {

    public typealias Tolerance = KvNumericTolerance<T>


    public let value: T


    /// Memerwise initializer.
    @usableFromInline
    internal init(value: T) {
        Swift.assert(value >= 0, "Invalid argument: tolerance argument value (\(value)) must be positive")

        self.value = value
    }

    @usableFromInline
    internal init(values v1: T, _ v2: T) {
        Swift.assert(v1 >= 0, "Invalid argument: tolerance argument v1 (\(v1)) must be positive")
        Swift.assert(v2 >= 0, "Invalid argument: tolerance argument v2 (\(v2)) must be positive")

        self.value = Swift.max(v1, v2)
    }

    @usableFromInline
    internal init(values v1: T, _ v2: T, _ v3: T) {
        Swift.assert(v1 >= 0, "Invalid argument: tolerance argument v1 (\(v1)) must be positive")
        Swift.assert(v2 >= 0, "Invalid argument: tolerance argument v2 (\(v2)) must be positive")
        Swift.assert(v3 >= 0, "Invalid argument: tolerance argument v3 (\(v3)) must be positive")

        self.value = Swift.max(Swift.max(v1, v2), v3)
    }

    @usableFromInline
    internal init(values v1: T, _ v2: T, _ v3: T, _ v4: T) {
        Swift.assert(v1 >= 0, "Invalid argument: tolerance argument v1 (\(v1)) must be positive")
        Swift.assert(v2 >= 0, "Invalid argument: tolerance argument v2 (\(v2)) must be positive")
        Swift.assert(v3 >= 0, "Invalid argument: tolerance argument v3 (\(v3)) must be positive")
        Swift.assert(v4 >= 0, "Invalid argument: tolerance argument v4 (\(v4)) must be positive")

        self.value = Swift.max(Swift.max(v1, v2), Swift.max(v3, v4))
    }

    /// Initializes single argument tolerance.
    @inlinable public init(_ arg: T) { self.init(value: abs(arg)) }

    /// Initializes tolerance by simple combination of two arguments.
    @inlinable public init(_ a1: T, _ a2: T) { self.init(values: abs(a1), abs(a2)) }

    /// Initializes tolerance by simple combination of three arguments.
    @inlinable public init(_ a1: T, _ a2: T, _ a3: T) { self.init(values: abs(a1), abs(a2), abs(a3)) }

    /// Initializes tolerance by simple combination of three arguments.
    @inlinable public init(_ a1: T, _ a2: T, _ a3: T, _ a4: T) { self.init(values: abs(a1), abs(a2), abs(a3), abs(a4)) }


    // MARK: Operations

    @inlinable public var tolerance: Tolerance { Tolerance(self) }


    /// - Returns: A tolerance of a sum.
    @inlinable public static func +(lhs: Self, rhs: Self) -> Self { Self(value: lhs.value + rhs.value) }

    /// - Returns: A tolerance of a subtraction.
    @inlinable public static func -(lhs: Self, rhs: Self) -> Self { Self(value: lhs.value + rhs.value) }

    /// - Returns: A tolerance of a product.
    @inlinable public static func *(lhs: Self, rhs: Self) -> Self { Self(values: lhs.value, rhs.value, lhs.value * rhs.value) }

    /// - Returns: A tolerance of a devesion.
    @inlinable
    public static func /(lhs: Self, rhs: Self) -> Self {
        let inv_rhs = 1 / rhs.value
        return Self(values: lhs.value, inv_rhs, lhs.value * inv_rhs)
    }

}



// MARK: FP Comparisons

public typealias KvEps<T : FloatingPoint> = KvNumericTolerance<T>

public typealias KvEpsArg<T : FloatingPoint> = KvNumericToleranceArgument<T>



/// - Returns: A boolean value indicating whether *lhs* is equal to *rhs* taking into account the computational error.
///
/// - Note: E.g. 0.1 · 10 is 1.0 but `(0..<10).reduce(0.0, { a, _ in a + 0.1 }) == 1.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
@inlinable
public func KvIs<T : FloatingPoint>(_ lhs: T, equalTo rhs: T, eps: KvEps<T>) -> Bool {
    abs(lhs - rhs) <= eps.value
}

/// - Returns: A boolean value indicating whether *lhs* is equal to *rhs* taking into account the computational error.
///
/// - Note: E.g. 0.1 · 10 is 1.0 but `(0..<10).reduce(0.0, { a, _ in a + 0.1 }) == 1.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
@inlinable
public func KvIs<T : FloatingPoint>(_ lhs: T, equalTo rhs: T) -> Bool {
    KvIs(lhs, equalTo: rhs, eps: KvEpsArg(lhs, rhs).tolerance)
}



/// - Parameter greaterFlag: Destination for a boolean value indicating whether *lhs* is greater than *rhs* taking into account the computational error.
///
/// - Returns: A boolean value indicating whether *lhs* is equal to *rhs* taking into account the computational error.
///
/// - Note: It is designed to be applied when equality case is primary but the order is significant in opposite case.
/// - Note: It's faster to check the flag than to compare the same values twice.
/// - Note: E.g. 0.1 · 10 is 1.0 but `(0..<10).reduce(0.0, { a, _ in a + 0.1 }) == 1.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
@inlinable
public func KvIs<T : FloatingPoint>(_ lhs: T, equalTo rhs: T, eps: KvEps<T>, alsoIsGreaterThan greaterFlag: inout Bool) -> Bool {
    greaterFlag = lhs > rhs + eps.value

    return lhs >= rhs - eps.value && !greaterFlag
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
    KvIs(lhs, equalTo: rhs, eps: KvEpsArg(lhs, rhs).tolerance, alsoIsGreaterThan: &greaterFlag)
}



/// - Returns: A boolean value indicating whether *lhs* is inequal to *rhs* taking into account the computational error.
///
/// - Note: E.g. 0.1 · 10 is 1.0 but `(0..<10).reduce(0.0, { a, _ in a + 0.1 }) == 1.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
@inlinable
public func KvIs<T : FloatingPoint>(_ lhs: T, inequalTo rhs: T, eps: KvEps<T>) -> Bool {
    abs(rhs - lhs) > eps.value
}

/// - Returns: A boolean value indicating whether *lhs* is inequal to *rhs* taking into account the computational error.
///
/// - Note: E.g. 0.1 · 10 is 1.0 but `(0..<10).reduce(0.0, { a, _ in a + 0.1 }) == 1.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
@inlinable
public func KvIs<T : FloatingPoint>(_ lhs: T, inequalTo rhs: T) -> Bool {
    KvIs(lhs, inequalTo: rhs, eps: KvEpsArg(lhs, rhs).tolerance)
}



/// - Parameter greaterFlag: Destination for a boolean value indicating whether *lhs* is greater than *rhs* taking into account the computational error.
///
/// - Returns: A boolean value indicating whether *lhs* is inequal to *rhs* taking into account the computational error.
///
/// - Note: It is designed to be applied when inequality case is primary and the order is significant. E.g. *guard* statement.
/// - Note: It's faster to check the flag than to compare the same values twice.
/// - Note: E.g. 0.1 · 10 is 1.0 but `(0..<10).reduce(0.0, { a, _ in a + 0.1 }) == 1.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
@inlinable
public func KvIs<T : FloatingPoint>(_ lhs: T, inequalTo rhs: T, eps: KvEps<T>, alsoIsGreaterThan greaterFlag: inout Bool) -> Bool {
    greaterFlag = lhs > rhs + eps.value

    return lhs < rhs - eps.value || greaterFlag
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
    KvIs(lhs, inequalTo: rhs, eps: KvEpsArg(lhs, rhs).tolerance, alsoIsGreaterThan: &greaterFlag)
}



/// - Returns: A boolean value indicating whether *lhs* is greater than *rhs* taking into account the computational error.
///
/// - Note: E.g. 0.1 · 10 is 1.0 but `(0..<10).reduce(0.0, { a, _ in a + 0.1 }) == 1.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
@inlinable
public func KvIs<T : FloatingPoint>(_ lhs: T, greaterThan rhs: T, eps: KvEps<T>) -> Bool {
    lhs > rhs + eps.value
}

/// - Returns: A boolean value indicating whether *lhs* is greater than *rhs* taking into account the computational error.
///
/// - Note: E.g. 0.1 · 10 is 1.0 but `(0..<10).reduce(0.0, { a, _ in a + 0.1 }) == 1.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
@inlinable
public func KvIs<T : FloatingPoint>(_ lhs: T, greaterThan rhs: T) -> Bool {
    KvIs(lhs, greaterThan: rhs, eps: KvEpsArg(lhs, rhs).tolerance)
}



/// - Parameter lessFlag: Destination for a boolean value indicating whether *lhs* is less than *rhs* taking into account the computational error.
///
/// - Returns: A boolean value indicating whether *lhs* is greater than *rhs* taking into account the computational error.
///
/// - Note: It is designed to be applied when descendence case is primary but ascendence is significant in opposite case.
/// - Note: It's faster to check the flag than to compare the same values twice.
/// - Note: E.g. 0.1 · 10 is 1.0 but `(0..<10).reduce(0.0, { a, _ in a + 0.1 }) == 1.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
@inlinable
public func KvIs<T : FloatingPoint>(_ lhs: T, greaterThan rhs: T, eps: KvEps<T>, alsoIsLessThan lessFlag: inout Bool) -> Bool {
    lessFlag = lhs < rhs - eps.value

    return lhs > rhs + eps.value
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
    KvIs(lhs, greaterThan: rhs, eps: KvEpsArg(lhs, rhs).tolerance, alsoIsLessThan: &lessFlag)
}



/// - Returns: A boolean value indicating whether *lhs* is less than *rhs* taking into account the computational error.
///
/// - Note: E.g. 0.1 · 10 is 1.0 but `(0..<10).reduce(0.0, { a, _ in a + 0.1 }) == 1.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
@inlinable
public func KvIs<T : FloatingPoint>(_ lhs: T, lessThan rhs: T, eps: KvEps<T>) -> Bool {
    lhs < rhs - eps.value
}

/// - Returns: A boolean value indicating whether *lhs* is less than *rhs* taking into account the computational error.
///
/// - Note: E.g. 0.1 · 10 is 1.0 but `(0..<10).reduce(0.0, { a, _ in a + 0.1 }) == 1.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
@inlinable
public func KvIs<T : FloatingPoint>(_ lhs: T, lessThan rhs: T) -> Bool {
    KvIs(lhs, lessThan: rhs, eps: KvEpsArg(lhs, rhs).tolerance)
}



/// - Parameter greaterFlag: Destination for a boolean value indicating whether *lhs* is greater than *rhs* taking into account the computational error.
///
/// - Returns: A boolean value indicating whether *lhs* is less than *rhs* taking into account the computational error.
///
/// - Note: It is designed to be applied when ascendence case is primary but descendence is significant in opposite case.
/// - Note: It's faster to check the flag than to compare the same values twice.
/// - Note: E.g. 0.1 · 10 is 1.0 but `(0..<10).reduce(0.0, { a, _ in a + 0.1 }) == 1.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
@inlinable
public func KvIs<T : FloatingPoint>(_ lhs: T, lessThan rhs: T, eps: KvEps<T>, alsoIsGreaterThan greaterFlag: inout Bool) -> Bool {
    greaterFlag = lhs > rhs + eps.value

    return lhs < rhs - eps.value
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
    KvIs(lhs, lessThan: rhs, eps: KvEpsArg(lhs, rhs).tolerance, alsoIsGreaterThan: &greaterFlag)
}



/// - Returns: A boolean value indicating whether *lhs* is greater than or equal to *rhs* taking into account the computational error.
///
/// - Note: E.g. 0.1 · 10 is 1.0 but `(0..<10).reduce(0.0, { a, _ in a + 0.1 }) == 1.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
@inlinable
public func KvIs<T : FloatingPoint>(_ lhs: T, greaterThanOrEqualTo rhs: T, eps: KvEps<T>) -> Bool {
    lhs >= rhs - eps.value
}

/// - Returns: A boolean value indicating whether *lhs* is greater than or equal to *rhs* taking into account the computational error.
///
/// - Note: E.g. 0.1 · 10 is 1.0 but `(0..<10).reduce(0.0, { a, _ in a + 0.1 }) == 1.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
@inlinable
public func KvIs<T : FloatingPoint>(_ lhs: T, greaterThanOrEqualTo rhs: T) -> Bool {
    KvIs(lhs, greaterThanOrEqualTo: rhs, eps: KvEpsArg(lhs, rhs).tolerance)
}



/// - Returns: A boolean value indicating whether *lhs* is less than or equal to *rhs* taking into account the computational error.
///
/// - Note: E.g. 0.1 · 10 is 1.0 but `(0..<10).reduce(0.0, { a, _ in a + 0.1 }) == 1.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
@inlinable
public func KvIs<T : FloatingPoint>(_ lhs: T, lessThanOrEqualTo rhs: T, eps: KvEps<T>) -> Bool {
    lhs <= rhs + eps.value
}

/// - Returns: A boolean value indicating whether *lhs* is less than or equal to *rhs* taking into account the computational error.
///
/// - Note: E.g. 0.1 · 10 is 1.0 but `(0..<10).reduce(0.0, { a, _ in a + 0.1 }) == 1.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
@inlinable
public func KvIs<T : FloatingPoint>(_ lhs: T, lessThanOrEqualTo rhs: T) -> Bool {
    KvIs(lhs, lessThanOrEqualTo: rhs, eps: KvEpsArg(lhs, rhs).tolerance)
}



/// - Returns: A boolean value indicating whether *value* is equal to zero taking into account the computational error.
///
/// - Note: E.g. 1 – 0.1 · 10 is 0.0 but `(0..<10).reduce(1.0, { a, _ in a - 0.1 }) == 0.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
@inlinable
public func KvIsZero<T : FloatingPoint>(_ value: T, eps: KvEps<T> = .zero) -> Bool {
    abs(value) <= eps.value
}



/// - Parameter positiveFlag: Destination for a boolean value indicating whether *value* is positive taking into account the computational error.
///
/// - Returns: A boolean value indicating whether *value* is equal to zero taking into account the computational error.
///
/// - Note: It is designed to be applied when equality case is primary but the sign is significant in opposite case.
/// - Note: It's faster to check the flag than to compare the same values twice.
/// - Note: E.g. 1 – 0.1 · 10 is 0.0 but `(0..<10).reduce(1.0, { a, _ in a - 0.1 }) == 0.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
@inlinable
public func KvIsZero<T : FloatingPoint>(_ value: T, eps: KvEps<T> = .zero, alsoIsPositive positiveFlag: inout Bool) -> Bool {
    positiveFlag = value > eps.value

    return !positiveFlag && value >= -eps.value
}



/// - Returns: A boolean value indicating whether *value* is not equal to zero taking into account the computational error.
///
/// - Note: E.g. 1 – 0.1 · 10 is 0.0 but `(0..<10).reduce(1.0, { a, _ in a - 0.1 }) == 0.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
@inlinable
public func KvIsNonzero<T : FloatingPoint>(_ value: T, eps: KvEps<T> = .zero) -> Bool {
    abs(value) > eps.value
}



/// - Parameter positiveFlag: Destination for a boolean value indicating whether *value* is positive taking into account the computational error.
///
/// - Returns: A boolean value indicating whether *value* is not equal to zero taking into account the computational error.
///
/// - Note: It is designed to be applied when inequality case is primary and the sign is significant. E.g. *guard* statement.
/// - Note: It's faster to check the flag than to compare the same values twice.
/// - Note: E.g. 1 – 0.1 · 10 is 0.0 but `(0..<10).reduce(1.0, { a, _ in a - 0.1 }) == 0.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
@inlinable
public func KvIsNonzero<T : FloatingPoint>(_ value: T, eps: KvEps<T> = .zero, alsoIsPositive positiveFlag: inout Bool) -> Bool {
    positiveFlag = value > eps.value

    return positiveFlag || value < -eps.value
}



/// - Returns: A boolean value indicating whether *value* is positive taking into account the computational error.
///
/// - Note: E.g. 1 – 0.1 · 10 is 0.0 but `(0..<10).reduce(1.0, { a, _ in a - 0.1 }) == 0.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
@inlinable
public func KvIsPositive<T : FloatingPoint>(_ value: T, eps: KvEps<T> = .zero) -> Bool {
    value > eps.value
}



/// - Parameter negativeFlag: Destination for a boolean value indicating whether *value* is negative taking into account the computational error.
///
/// - Returns: A boolean value indicating whether *value* is positive taking into account the computational error.
///
/// - Note: It is designed to be applied when positivity case is primary but the sign is significant in opposite case.
/// - Note: It's faster to check the flag than to compare the same values twice.
/// - Note: E.g. 1 – 0.1 · 10 is 0.0 but `(0..<10).reduce(1.0, { a, _ in a - 0.1 }) == 0.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
@inlinable
public func KvIsPositive<T : FloatingPoint>(_ value: T, eps: KvEps<T> = .zero, alsoIsNegative negativeFlag: inout Bool) -> Bool {
    negativeFlag = value < -eps.value

    return value > eps.value
}



/// - Returns: A boolean value indicating whether *value* is negative taking into account the computational error.
///
/// - Note: E.g. 1 – 0.1 · 10 is 0.0 but `(0..<10).reduce(1.0, { a, _ in a - 0.1 }) == 0.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
@inlinable
public func KvIsNegative<T : FloatingPoint>(_ value: T, eps: KvEps<T> = .zero) -> Bool {
    value < -eps.value
}



/// - Parameter positiveFlag: Destination for a boolean value indicating whether *value* is positive taking into account the computational error.
///
/// - Returns: A boolean value indicating whether *value* is negative taking into account the computational error.
///
/// - Note: It is designed to be applied when negativity case is primary but the sign is significant in opposite case.
/// - Note: It's faster to check the flag than to compare the same values twice.
/// - Note: E.g. 1 – 0.1 · 10 is 0.0 but `(0..<10).reduce(1.0, { a, _ in a - 0.1 }) == 0.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
@inlinable
public func KvIsNegative<T : FloatingPoint>(_ value: T, eps: KvEps<T> = .zero, alsoIsPositive positiveFlag: inout Bool) -> Bool {
    positiveFlag = value > eps.value

    return value < -eps.value
}



/// - Returns: A boolean value indicating whether *value* isn't positive taking into account the computational error.
///
/// - Note: E.g. 1 – 0.1 · 10 is 0.0 but `(0..<10).reduce(1.0, { a, _ in a - 0.1 }) == 0.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
@inlinable
public func KvIsNotPositive<T : FloatingPoint>(_ value: T, eps: KvEps<T> = .zero) -> Bool {
    value <= eps.value
}



/// - Returns: A boolean value indicating whether *value* isn't negative taking into account the computational error.
///
/// - Note: E.g. 1 – 0.1 · 10 is 0.0 but `(0..<10).reduce(1.0, { a, _ in a - 0.1 }) == 0.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
@inlinable
public func KvIsNotNegative<T : FloatingPoint>(_ value: T, eps: KvEps<T> = .zero) -> Bool {
    value >= -eps.value
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

@available(*, deprecated, renamed: "KvEps(for:)")
@inlinable
public func KvUlp<T : FloatingPoint>(of value: T) -> T { KvEpsArg(value).tolerance.value }

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
