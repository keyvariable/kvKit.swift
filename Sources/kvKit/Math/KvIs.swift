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
//  KvIs.swift
//  Kvkit
//
//  Created by Svyatoslav Popov on 18.08.2020.
//


// MARK: - KvNumericTolerance

/// A lightweight container for numerical comparison tolerance.
///
/// Use ``KvNumericToleranceArgument`` to combine magnitudes and calculate tolerance once.
///
/// E.g. `KvNumericTolerance<Double>(100.0)` defines a tolerance near 100.0 with double precision.
/// Consider ``near(_:)`` fabric. For example, if it's known that magnitudes of  *a* and *b* are less then 10, following code can be used:
///
///     KvIs(a, equalTo: b, eps: .near(100.0))
///     
public struct KvNumericTolerance<T : BinaryFloatingPoint> {

    public typealias Argument = KvNumericToleranceArgument<T>


    public let value: T


    /// Initializes an instance with explicit tolerance value.
    ///
    /// Consider implicit way of tolerance handling with ``KvNumericToleranceArgument``.
    /// E.g. `KvNumericTolerance<Double>(100.0)` defines a tolerance near 100.0 with double precision.
    @inlinable
    public init(explicit value: T) {
        Swift.assert(value >= (0.0 as T), "Invalid argument: tolerance value (\(value)) must be positive")

        self.value = value
    }


    /// Initializes a default tolerance for simple operations with given argument.
    @inlinable
    public init(_ arg: Argument) {
        self.init(explicit: T.ulpOfOne * Swift.max(Swift.min((32.0 as T) * arg.value, T.greatestFiniteMagnitude), T.ulpOfOne))
    }


    // MARK: Auxiliaries

    /// Default tolerance for comparisons.
    @inlinable public static var `default`: Self { Self(explicit: (32.0 as T) * T.ulpOfOne) }


    /// A shorthand for ``init(explicit:)``.
    @inlinable public static func explicit(_ value: T) -> Self { .init(explicit: value) }

    /// A shorthand for ``init(_:)``.
    @inlinable public static func near(_ arg: Argument) -> Self { .init(arg) }

}


// MARK: : ExpressibleByIntegerLiteral

extension KvNumericTolerance : ExpressibleByIntegerLiteral where T : ExpressibleByIntegerLiteral {

    @inlinable
    public init(integerLiteral value: T.IntegerLiteralType) {
        self.init(explicit: .init(integerLiteral: value))
    }

}


// MARK: : ExpressibleByFloatLiteral

extension KvNumericTolerance : ExpressibleByFloatLiteral where T : ExpressibleByFloatLiteral {

    @inlinable
    public init(floatLiteral value: T.FloatLiteralType) {
        self.init(explicit: .init(floatLiteral: value))
    }

}



// MARK: - KvNumericToleranceArgument

/// A lightweight container for magnitude of numerical comparison tolerance.
public struct KvNumericToleranceArgument<T : BinaryFloatingPoint> : Hashable {

    public typealias Tolerance = KvNumericTolerance<T>


    public let value: T


    /// Memerwise initializer.
    @usableFromInline
    internal init(value: T) {
        Swift.assert(value >= (0.0 as T), "Invalid argument: tolerance argument value (\(value)) must be positive")

        self.value = value
    }

    @usableFromInline
    internal init(values v1: T, _ v2: T) {
        Swift.assert(v1 >= (0.0 as T), "Invalid argument: tolerance argument v1 (\(v1)) must be positive")
        Swift.assert(v2 >= (0.0 as T), "Invalid argument: tolerance argument v2 (\(v2)) must be positive")

        self.value = Swift.max(v1, v2)
    }

    @usableFromInline
    internal init(values v1: T, _ v2: T, _ v3: T) {
        Swift.assert(v1 >= (0.0 as T), "Invalid argument: tolerance argument v1 (\(v1)) must be positive")
        Swift.assert(v2 >= (0.0 as T), "Invalid argument: tolerance argument v2 (\(v2)) must be positive")
        Swift.assert(v3 >= (0.0 as T), "Invalid argument: tolerance argument v3 (\(v3)) must be positive")

        self.value = Swift.max(Swift.max(v1, v2), v3)
    }

    @usableFromInline
    internal init(values v1: T, _ v2: T, _ v3: T, _ v4: T) {
        Swift.assert(v1 >= (0.0 as T), "Invalid argument: tolerance argument v1 (\(v1)) must be positive")
        Swift.assert(v2 >= (0.0 as T), "Invalid argument: tolerance argument v2 (\(v2)) must be positive")
        Swift.assert(v3 >= (0.0 as T), "Invalid argument: tolerance argument v3 (\(v3)) must be positive")
        Swift.assert(v4 >= (0.0 as T), "Invalid argument: tolerance argument v4 (\(v4)) must be positive")

        self.value = Swift.max(Swift.max(v1, v2), Swift.max(v3, v4))
    }

    /// Zero argument initializer.
    @inlinable public init() { value = 0.0 as T }

    /// Initializes a single argument tolerance.
    @inlinable public init(_ arg: T) { self.init(value: abs(arg)) }

    /// Initializes a tolerance by simple combination of two arguments.
    @inlinable public init(_ a1: T, _ a2: T) { self.init(values: abs(a1), abs(a2)) }

    /// Initializes a tolerance by simple combination of three arguments.
    @inlinable public init(_ a1: T, _ a2: T, _ a3: T) { self.init(values: abs(a1), abs(a2), abs(a3)) }

    /// Initializes a tolerance by simple combination of three arguments.
    @inlinable public init(_ a1: T, _ a2: T, _ a3: T, _ a4: T) { self.init(values: abs(a1), abs(a2), abs(a3), abs(a4)) }


    // MARK: Auxiliaries

    @inlinable public static var zero: Self { Self() }


    // MARK: Operations

    @inlinable public var tolerance: Tolerance { Tolerance(self) }


    /// - Returns: Tolerance of a sum.
    @inlinable public static func +(lhs: Self, rhs: Self) -> Self { Self(value: lhs.value + rhs.value) }

    /// - Returns: Tolerance of a subtraction.
    @inlinable public static func -(lhs: Self, rhs: Self) -> Self { Self(value: lhs.value + rhs.value) }

    /// - Returns: Tolerance of a product.
    @inlinable public static func *(lhs: Self, rhs: Self) -> Self { Self(value: 2 * lhs.value * rhs.value) }

    /// - Returns: Tolerance of a division.
    @inlinable public static func /(lhs: Self, rhs: Self) -> Self { Self(value: 2 * lhs.value / rhs.value) }


    /// - Returns: Tolarance of the squared receiver.
    @inlinable public func squared() -> Self { self * self }

    /// - Returns: Tolarance of square root of the receiver.
    @inlinable public func squareRoot() -> Self { .init(value: value.squareRoot()) }

}


// MARK: : ExpressibleByIntegerLiteral

extension KvNumericToleranceArgument : ExpressibleByIntegerLiteral where T : ExpressibleByIntegerLiteral {

    @inlinable
    public init(integerLiteral value: T.IntegerLiteralType) {
        self.init(.init(integerLiteral: value))
    }

}


// MARK: : ExpressibleByFloatLiteral

extension KvNumericToleranceArgument : ExpressibleByFloatLiteral where T : ExpressibleByFloatLiteral {

    @inlinable
    public init(floatLiteral value: T.FloatLiteralType) {
        self.init(.init(floatLiteral: value))
    }

}



// MARK: - FP Comparisons

public typealias KvEps<T : BinaryFloatingPoint> = KvNumericTolerance<T>

public typealias KvEpsArg<T : BinaryFloatingPoint> = KvNumericToleranceArgument<T>



/// - Returns: A boolean value indicating whether *lhs* is equal to *rhs* taking into account the computational error.
///
/// - Note: E.g. 0.1 · 10 is 1.0 but `(0..<10).reduce(0.0, { a, _ in a + 0.1 }) == 1.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
@inlinable
public func KvIs<T : BinaryFloatingPoint>(_ lhs: T, equalTo rhs: T, eps: KvEps<T>) -> Bool {
    abs(lhs - rhs) <= eps.value
}

/// - Returns: A boolean value indicating whether *lhs* is equal to *rhs* taking into account the computational error.
///
/// - Note: E.g. 0.1 · 10 is 1.0 but `(0..<10).reduce(0.0, { a, _ in a + 0.1 }) == 1.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
@inlinable
public func KvIs<T : BinaryFloatingPoint>(_ lhs: T, equalTo rhs: T) -> Bool {
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
public func KvIs<T : BinaryFloatingPoint>(_ lhs: T, equalTo rhs: T, eps: KvEps<T>, alsoIsGreaterThan greaterFlag: inout Bool) -> Bool {
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
public func KvIs<T : BinaryFloatingPoint>(_ lhs: T, equalTo rhs: T, alsoIsGreaterThan greaterFlag: inout Bool) -> Bool {
    KvIs(lhs, equalTo: rhs, eps: KvEpsArg(lhs, rhs).tolerance, alsoIsGreaterThan: &greaterFlag)
}



/// - Returns: A boolean value indicating whether *lhs* is inequal to *rhs* taking into account the computational error.
///
/// - Note: E.g. 0.1 · 10 is 1.0 but `(0..<10).reduce(0.0, { a, _ in a + 0.1 }) == 1.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
@inlinable
public func KvIs<T : BinaryFloatingPoint>(_ lhs: T, inequalTo rhs: T, eps: KvEps<T>) -> Bool {
    abs(rhs - lhs) > eps.value
}

/// - Returns: A boolean value indicating whether *lhs* is inequal to *rhs* taking into account the computational error.
///
/// - Note: E.g. 0.1 · 10 is 1.0 but `(0..<10).reduce(0.0, { a, _ in a + 0.1 }) == 1.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
@inlinable
public func KvIs<T : BinaryFloatingPoint>(_ lhs: T, inequalTo rhs: T) -> Bool {
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
public func KvIs<T : BinaryFloatingPoint>(_ lhs: T, inequalTo rhs: T, eps: KvEps<T>, alsoIsGreaterThan greaterFlag: inout Bool) -> Bool {
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
public func KvIs<T : BinaryFloatingPoint>(_ lhs: T, inequalTo rhs: T, alsoIsGreaterThan greaterFlag: inout Bool) -> Bool {
    KvIs(lhs, inequalTo: rhs, eps: KvEpsArg(lhs, rhs).tolerance, alsoIsGreaterThan: &greaterFlag)
}



/// - Returns: A boolean value indicating whether *lhs* is greater than *rhs* taking into account the computational error.
///
/// - Note: E.g. 0.1 · 10 is 1.0 but `(0..<10).reduce(0.0, { a, _ in a + 0.1 }) == 1.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
@inlinable
public func KvIs<T : BinaryFloatingPoint>(_ lhs: T, greaterThan rhs: T, eps: KvEps<T>) -> Bool {
    lhs > rhs + eps.value
}

/// - Returns: A boolean value indicating whether *lhs* is greater than *rhs* taking into account the computational error.
///
/// - Note: E.g. 0.1 · 10 is 1.0 but `(0..<10).reduce(0.0, { a, _ in a + 0.1 }) == 1.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
@inlinable
public func KvIs<T : BinaryFloatingPoint>(_ lhs: T, greaterThan rhs: T) -> Bool {
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
public func KvIs<T : BinaryFloatingPoint>(_ lhs: T, greaterThan rhs: T, eps: KvEps<T>, alsoIsLessThan lessFlag: inout Bool) -> Bool {
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
public func KvIs<T : BinaryFloatingPoint>(_ lhs: T, greaterThan rhs: T, alsoIsLessThan lessFlag: inout Bool) -> Bool {
    KvIs(lhs, greaterThan: rhs, eps: KvEpsArg(lhs, rhs).tolerance, alsoIsLessThan: &lessFlag)
}



/// - Returns: A boolean value indicating whether *lhs* is less than *rhs* taking into account the computational error.
///
/// - Note: E.g. 0.1 · 10 is 1.0 but `(0..<10).reduce(0.0, { a, _ in a + 0.1 }) == 1.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
@inlinable
public func KvIs<T : BinaryFloatingPoint>(_ lhs: T, lessThan rhs: T, eps: KvEps<T>) -> Bool {
    lhs < rhs - eps.value
}

/// - Returns: A boolean value indicating whether *lhs* is less than *rhs* taking into account the computational error.
///
/// - Note: E.g. 0.1 · 10 is 1.0 but `(0..<10).reduce(0.0, { a, _ in a + 0.1 }) == 1.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
@inlinable
public func KvIs<T : BinaryFloatingPoint>(_ lhs: T, lessThan rhs: T) -> Bool {
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
public func KvIs<T : BinaryFloatingPoint>(_ lhs: T, lessThan rhs: T, eps: KvEps<T>, alsoIsGreaterThan greaterFlag: inout Bool) -> Bool {
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
public func KvIs<T : BinaryFloatingPoint>(_ lhs: T, lessThan rhs: T, alsoIsGreaterThan greaterFlag: inout Bool) -> Bool {
    KvIs(lhs, lessThan: rhs, eps: KvEpsArg(lhs, rhs).tolerance, alsoIsGreaterThan: &greaterFlag)
}



/// - Returns: A boolean value indicating whether *lhs* is greater than or equal to *rhs* taking into account the computational error.
///
/// - Note: E.g. 0.1 · 10 is 1.0 but `(0..<10).reduce(0.0, { a, _ in a + 0.1 }) == 1.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
@inlinable
public func KvIs<T : BinaryFloatingPoint>(_ lhs: T, greaterThanOrEqualTo rhs: T, eps: KvEps<T>) -> Bool {
    lhs >= rhs - eps.value
}

/// - Returns: A boolean value indicating whether *lhs* is greater than or equal to *rhs* taking into account the computational error.
///
/// - Note: E.g. 0.1 · 10 is 1.0 but `(0..<10).reduce(0.0, { a, _ in a + 0.1 }) == 1.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
@inlinable
public func KvIs<T : BinaryFloatingPoint>(_ lhs: T, greaterThanOrEqualTo rhs: T) -> Bool {
    KvIs(lhs, greaterThanOrEqualTo: rhs, eps: KvEpsArg(lhs, rhs).tolerance)
}



/// - Returns: A boolean value indicating whether *lhs* is less than or equal to *rhs* taking into account the computational error.
///
/// - Note: E.g. 0.1 · 10 is 1.0 but `(0..<10).reduce(0.0, { a, _ in a + 0.1 }) == 1.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
@inlinable
public func KvIs<T : BinaryFloatingPoint>(_ lhs: T, lessThanOrEqualTo rhs: T, eps: KvEps<T>) -> Bool {
    lhs <= rhs + eps.value
}

/// - Returns: A boolean value indicating whether *lhs* is less than or equal to *rhs* taking into account the computational error.
///
/// - Note: E.g. 0.1 · 10 is 1.0 but `(0..<10).reduce(0.0, { a, _ in a + 0.1 }) == 1.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
@inlinable
public func KvIs<T : BinaryFloatingPoint>(_ lhs: T, lessThanOrEqualTo rhs: T) -> Bool {
    KvIs(lhs, lessThanOrEqualTo: rhs, eps: KvEpsArg(lhs, rhs).tolerance)
}



/// - Returns: A boolean value indicating whether *value* is equal to zero taking into account the computational error.
///
/// - Note: E.g. 1 – 0.1 · 10 is 0.0 but `(0..<10).reduce(1.0, { a, _ in a - 0.1 }) == 0.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
@inlinable
public func KvIsZero<T : BinaryFloatingPoint>(_ value: T, eps: KvEps<T> = .default) -> Bool {
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
public func KvIsZero<T : BinaryFloatingPoint>(_ value: T, eps: KvEps<T> = .default, alsoIsPositive positiveFlag: inout Bool) -> Bool {
    positiveFlag = value > eps.value

    return !positiveFlag && value >= -eps.value
}



/// - Returns: A boolean value indicating whether *value* is not equal to zero taking into account the computational error.
///
/// - Note: E.g. 1 – 0.1 · 10 is 0.0 but `(0..<10).reduce(1.0, { a, _ in a - 0.1 }) == 0.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
@inlinable
public func KvIsNonzero<T : BinaryFloatingPoint>(_ value: T, eps: KvEps<T> = .default) -> Bool {
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
public func KvIsNonzero<T : BinaryFloatingPoint>(_ value: T, eps: KvEps<T> = .default, alsoIsPositive positiveFlag: inout Bool) -> Bool {
    positiveFlag = value > eps.value

    return positiveFlag || value < -eps.value
}



/// - Returns: A boolean value indicating whether *value* is positive taking into account the computational error.
///
/// - Note: E.g. 1 – 0.1 · 10 is 0.0 but `(0..<10).reduce(1.0, { a, _ in a - 0.1 }) == 0.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
@inlinable
public func KvIsPositive<T : BinaryFloatingPoint>(_ value: T, eps: KvEps<T> = .default) -> Bool {
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
public func KvIsPositive<T : BinaryFloatingPoint>(_ value: T, eps: KvEps<T> = .default, alsoIsNegative negativeFlag: inout Bool) -> Bool {
    negativeFlag = value < -eps.value

    return value > eps.value
}



/// - Returns: A boolean value indicating whether *value* is negative taking into account the computational error.
///
/// - Note: E.g. 1 – 0.1 · 10 is 0.0 but `(0..<10).reduce(1.0, { a, _ in a - 0.1 }) == 0.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
@inlinable
public func KvIsNegative<T : BinaryFloatingPoint>(_ value: T, eps: KvEps<T> = .default) -> Bool {
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
public func KvIsNegative<T : BinaryFloatingPoint>(_ value: T, eps: KvEps<T> = .default, alsoIsPositive positiveFlag: inout Bool) -> Bool {
    positiveFlag = value > eps.value

    return value < -eps.value
}



/// - Returns: A boolean value indicating whether *value* isn't positive taking into account the computational error.
///
/// - Note: E.g. 1 – 0.1 · 10 is 0.0 but `(0..<10).reduce(1.0, { a, _ in a - 0.1 }) == 0.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
@inlinable
public func KvIsNotPositive<T : BinaryFloatingPoint>(_ value: T, eps: KvEps<T> = .default) -> Bool {
    value <= eps.value
}



/// - Returns: A boolean value indicating whether *value* isn't negative taking into account the computational error.
///
/// - Note: E.g. 1 – 0.1 · 10 is 0.0 but `(0..<10).reduce(1.0, { a, _ in a - 0.1 }) == 0.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
@inlinable
public func KvIsNotNegative<T : BinaryFloatingPoint>(_ value: T, eps: KvEps<T> = .default) -> Bool {
    value >= -eps.value
}



// MARK: - FP Optional Comparisons

/// - Returns: A boolean value indicating whether *lhs* is equal to *rhs* taking into account the computational error.
///
/// - Note: E.g. 0.1 · 10 is 1.0 but `(0..<10).reduce(0.0, { a, _ in a + 0.1 }) == 1.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
@inlinable
public func KvIs<T : BinaryFloatingPoint>(_ lhs: T?, equalTo rhs: T?) -> Bool {
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
public func KvIs<T : BinaryFloatingPoint>(_ lhs: T?, inequalTo rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case (.some(let lhs), .some(let rhs)):
        return KvIs(lhs, inequalTo: rhs)
    case (.none, .none):
        return false
    case (.some, .none), (.none, .some):
        return true
    }
}



// MARK: - FP Range Comparisons

/// - Returns: A boolean value indicating whether *range* contains *value* taking into account the computational error.
///
/// - Note: E.g. 0.1 · 10 is 1.0 but `(0..<10).reduce(0.0, { a, _ in a + 0.1 }) == 1.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
@inlinable
public func KvIs<T : BinaryFloatingPoint>(_ value: T, in range: Range<T>) -> Bool {
    KvIs(value, greaterThanOrEqualTo: range.lowerBound) && KvIs(value, lessThan: range.upperBound)
}



/// - Returns: A boolean value indicating whether *range* contains *value* taking into account the computational error.
///
/// - Note: E.g. 0.1 · 10 is 1.0 but `(0..<10).reduce(0.0, { a, _ in a + 0.1 }) == 1.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
@inlinable
public func KvIs<T : BinaryFloatingPoint>(_ value: T, in range: ClosedRange<T>) -> Bool {
    KvIs(value, greaterThanOrEqualTo: range.lowerBound) && KvIs(value, lessThanOrEqualTo: range.upperBound)
}



/// - Returns: A boolean value indicating whether *range* contains *value* taking into account the computational error.
///
/// - Note: E.g. 0.1 · 10 is 1.0 but `(0..<10).reduce(0.0, { a, _ in a + 0.1 }) == 1.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
@inlinable
public func KvIs<T : BinaryFloatingPoint>(_ value: T, in range: PartialRangeFrom<T>) -> Bool {
    KvIs(value, greaterThanOrEqualTo: range.lowerBound)
}



/// - Returns: A boolean value indicating whether *range* contains *value* taking into account the computational error.
///
/// - Note: E.g. 0.1 · 10 is 1.0 but `(0..<10).reduce(0.0, { a, _ in a + 0.1 }) == 1.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
@inlinable
public func KvIs<T : BinaryFloatingPoint>(_ value: T, in range: PartialRangeUpTo<T>) -> Bool {
    KvIs(value, lessThan: range.upperBound)
}



/// - Returns: A boolean value indicating whether *range* contains *value* taking into account the computational error.
///
/// - Note: E.g. 0.1 · 10 is 1.0 but `(0..<10).reduce(0.0, { a, _ in a + 0.1 }) == 1.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
@inlinable
public func KvIs<T : BinaryFloatingPoint>(_ value: T, in range: PartialRangeThrough<T>) -> Bool {
    KvIs(value, lessThanOrEqualTo: range.upperBound)
}



/// - Returns: A boolean value indicating whether *value* is out of *range* taking into account the computational error.
///
/// - Note: E.g. 0.1 · 10 is 1.0 but `(0..<10).reduce(0.0, { a, _ in a + 0.1 }) == 1.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
@inlinable
public func KvIs<T : BinaryFloatingPoint>(_ value: T, outOf range: Range<T>) -> Bool {
    KvIs(value, lessThan: range.lowerBound) || KvIs(value, greaterThanOrEqualTo: range.upperBound)
}



/// - Returns: A boolean value indicating whether *value* is out of *range* taking into account the computational error.
///
/// - Note: E.g. 0.1 · 10 is 1.0 but `(0..<10).reduce(0.0, { a, _ in a + 0.1 }) == 1.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
@inlinable
public func KvIs<T : BinaryFloatingPoint>(_ value: T, outOf range: ClosedRange<T>) -> Bool {
    KvIs(value, lessThan: range.lowerBound) || KvIs(value, greaterThan: range.upperBound)
}



/// - Returns: A boolean value indicating whether *value* is out of *range* taking into account the computational error.
///
/// - Note: E.g. 0.1 · 10 is 1.0 but `(0..<10).reduce(0.0, { a, _ in a + 0.1 }) == 1.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
@inlinable
public func KvIs<T : BinaryFloatingPoint>(_ value: T, outOf range: PartialRangeFrom<T>) -> Bool {
    KvIs(value, lessThan: range.lowerBound)
}



/// - Returns: A boolean value indicating whether *value* is out of *range* taking into account the computational error.
///
/// - Note: E.g. 0.1 · 10 is 1.0 but `(0..<10).reduce(0.0, { a, _ in a + 0.1 }) == 1.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
@inlinable
public func KvIs<T : BinaryFloatingPoint>(_ value: T, outOf range: PartialRangeUpTo<T>) -> Bool {
    KvIs(value, greaterThanOrEqualTo: range.upperBound)
}



/// - Returns: A boolean value indicating whether *value* is out of *range* taking into account the computational error.
///
/// - Note: E.g. 0.1 · 10 is 1.0 but `(0..<10).reduce(0.0, { a, _ in a + 0.1 }) == 1.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
@inlinable
public func KvIs<T : BinaryFloatingPoint>(_ value: T, outOf range: PartialRangeThrough<T>) -> Bool {
    KvIs(value, greaterThan: range.upperBound)
}



/// - Returns: A boolean value indicating whether *lhs* is equal to *rhs* taking into account the computational error.
///
/// - Note: E.g. 0.1 · 10 is 1.0 but `(0..<10).reduce(0.0, { a, _ in a + 0.1 }) == 1.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
@inlinable
public func KvIs<T : BinaryFloatingPoint>(_ lhs: Range<T>, equalTo rhs: Range<T>) -> Bool {
    KvIs(lhs.lowerBound, equalTo: rhs.lowerBound) && KvIs(lhs.upperBound, equalTo: rhs.upperBound)
}

/// - Returns: A boolean value indicating whether *lhs* is equal to *rhs* taking into account the computational error.
///
/// - Note: E.g. 0.1 · 10 is 1.0 but `(0..<10).reduce(0.0, { a, _ in a + 0.1 }) == 1.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
@inlinable
public func KvIs<T : BinaryFloatingPoint>(_ lhs: Range<T>, equalTo rhs: PartialRangeFrom<T>) -> Bool {
    KvIs(lhs.lowerBound, equalTo: rhs.lowerBound) && lhs.upperBound == .infinity
}

/// - Returns: A boolean value indicating whether *lhs* is equal to *rhs* taking into account the computational error.
///
/// - Note: E.g. 0.1 · 10 is 1.0 but `(0..<10).reduce(0.0, { a, _ in a + 0.1 }) == 1.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
@inlinable
public func KvIs<T : BinaryFloatingPoint>(_ lhs: Range<T>, equalTo rhs: PartialRangeUpTo<T>) -> Bool {
    lhs.upperBound == -.infinity && KvIs(lhs.upperBound, equalTo: rhs.upperBound)
}

/// - Returns: A boolean value indicating whether *lhs* is equal to *rhs* taking into account the computational error.
///
/// - Note: E.g. 0.1 · 10 is 1.0 but `(0..<10).reduce(0.0, { a, _ in a + 0.1 }) == 1.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
@inlinable
public func KvIs<T : BinaryFloatingPoint>(_ lhs: ClosedRange<T>, equalTo rhs: ClosedRange<T>) -> Bool {
    KvIs(lhs.lowerBound, equalTo: rhs.lowerBound) && KvIs(lhs.upperBound, equalTo: rhs.upperBound)
}

/// - Returns: A boolean value indicating whether *lhs* is equal to *rhs* taking into account the computational error.
///
/// - Note: E.g. 0.1 · 10 is 1.0 but `(0..<10).reduce(0.0, { a, _ in a + 0.1 }) == 1.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
@inlinable
public func KvIs<T : BinaryFloatingPoint>(_ lhs: ClosedRange<T>, equalTo rhs: PartialRangeFrom<T>) -> Bool {
    KvIs(lhs.lowerBound, equalTo: rhs.lowerBound) && lhs.upperBound == .infinity
}

/// - Returns: A boolean value indicating whether *lhs* is equal to *rhs* taking into account the computational error.
///
/// - Note: E.g. 0.1 · 10 is 1.0 but `(0..<10).reduce(0.0, { a, _ in a + 0.1 }) == 1.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
@inlinable
public func KvIs<T : BinaryFloatingPoint>(_ lhs: ClosedRange<T>, equalTo rhs: PartialRangeThrough<T>) -> Bool {
    lhs.upperBound == -.infinity && KvIs(lhs.upperBound, equalTo: rhs.upperBound)
}

/// - Returns: A boolean value indicating whether *lhs* is equal to *rhs* taking into account the computational error.
///
/// - Note: E.g. 0.1 · 10 is 1.0 but `(0..<10).reduce(0.0, { a, _ in a + 0.1 }) == 1.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
@inlinable
public func KvIs<T : BinaryFloatingPoint>(_ lhs: PartialRangeFrom<T>, equalTo rhs: PartialRangeFrom<T>) -> Bool {
    KvIs(lhs.lowerBound, equalTo: rhs.lowerBound)
}

/// - Returns: A boolean value indicating whether *lhs* is equal to *rhs* taking into account the computational error.
///
/// - Note: E.g. 0.1 · 10 is 1.0 but `(0..<10).reduce(0.0, { a, _ in a + 0.1 }) == 1.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
@inlinable
public func KvIs<T : BinaryFloatingPoint>(_ lhs: PartialRangeFrom<T>, equalTo rhs: Range<T>) -> Bool {
    KvIs(lhs.lowerBound, equalTo: rhs.lowerBound) && rhs.upperBound == .infinity
}

/// - Returns: A boolean value indicating whether *lhs* is equal to *rhs* taking into account the computational error.
///
/// - Note: E.g. 0.1 · 10 is 1.0 but `(0..<10).reduce(0.0, { a, _ in a + 0.1 }) == 1.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
@inlinable
public func KvIs<T : BinaryFloatingPoint>(_ lhs: PartialRangeFrom<T>, equalTo rhs: ClosedRange<T>) -> Bool {
    KvIs(lhs.lowerBound, equalTo: rhs.lowerBound) && rhs.upperBound == .infinity
}

/// - Returns: A boolean value indicating whether *lhs* is equal to *rhs* taking into account the computational error.
///
/// - Note: E.g. 0.1 · 10 is 1.0 but `(0..<10).reduce(0.0, { a, _ in a + 0.1 }) == 1.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
@inlinable
public func KvIs<T : BinaryFloatingPoint>(_ lhs: PartialRangeUpTo<T>, equalTo rhs: PartialRangeUpTo<T>) -> Bool {
    KvIs(lhs.upperBound, equalTo: rhs.upperBound)
}

/// - Returns: A boolean value indicating whether *lhs* is equal to *rhs* taking into account the computational error.
///
/// - Note: E.g. 0.1 · 10 is 1.0 but `(0..<10).reduce(0.0, { a, _ in a + 0.1 }) == 1.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
@inlinable
public func KvIs<T : BinaryFloatingPoint>(_ lhs: PartialRangeUpTo<T>, equalTo rhs: Range<T>) -> Bool {
    rhs.lowerBound == -.infinity && KvIs(lhs.upperBound, equalTo: rhs.upperBound)
}

/// - Returns: A boolean value indicating whether *lhs* is equal to *rhs* taking into account the computational error.
///
/// - Note: E.g. 0.1 · 10 is 1.0 but `(0..<10).reduce(0.0, { a, _ in a + 0.1 }) == 1.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
@inlinable
public func KvIs<T : BinaryFloatingPoint>(_ lhs: PartialRangeThrough<T>, equalTo rhs: PartialRangeThrough<T>) -> Bool {
    KvIs(lhs.upperBound, equalTo: rhs.upperBound)
}

/// - Returns: A boolean value indicating whether *lhs* is equal to *rhs* taking into account the computational error.
///
/// - Note: E.g. 0.1 · 10 is 1.0 but `(0..<10).reduce(0.0, { a, _ in a + 0.1 }) == 1.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
@inlinable
public func KvIs<T : BinaryFloatingPoint>(_ lhs: PartialRangeThrough<T>, equalTo rhs: ClosedRange<T>) -> Bool {
    rhs.lowerBound == -.infinity && KvIs(lhs.upperBound, equalTo: rhs.upperBound)
}



/// - Returns: A boolean value indicating whether *lhs* is inequal to *rhs* taking into account the computational error.
///
/// - Note: E.g. 0.1 · 10 is 1.0 but `(0..<10).reduce(0.0, { a, _ in a + 0.1 }) == 1.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
@inlinable
public func KvIs<T : BinaryFloatingPoint>(_ lhs: Range<T>, inequalTo rhs: Range<T>) -> Bool {
    KvIs(lhs.lowerBound, inequalTo: rhs.lowerBound) || KvIs(lhs.upperBound, inequalTo: rhs.upperBound)
}

/// - Returns: A boolean value indicating whether *lhs* is inequal to *rhs* taking into account the computational error.
///
/// - Note: E.g. 0.1 · 10 is 1.0 but `(0..<10).reduce(0.0, { a, _ in a + 0.1 }) == 1.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
@inlinable
public func KvIs<T : BinaryFloatingPoint>(_ lhs: Range<T>, inequalTo rhs: PartialRangeFrom<T>) -> Bool {
    KvIs(lhs.lowerBound, inequalTo: rhs.lowerBound) || lhs.upperBound != .infinity
}

/// - Returns: A boolean value indicating whether *lhs* is inequal to *rhs* taking into account the computational error.
///
/// - Note: E.g. 0.1 · 10 is 1.0 but `(0..<10).reduce(0.0, { a, _ in a + 0.1 }) == 1.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
@inlinable
public func KvIs<T : BinaryFloatingPoint>(_ lhs: Range<T>, inequalTo rhs: PartialRangeUpTo<T>) -> Bool {
    lhs.upperBound != -.infinity || KvIs(lhs.upperBound, inequalTo: rhs.upperBound)
}

/// - Returns: A boolean value indicating whether *lhs* is inequal to *rhs* taking into account the computational error.
///
/// - Note: E.g. 0.1 · 10 is 1.0 but `(0..<10).reduce(0.0, { a, _ in a + 0.1 }) == 1.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
@inlinable
public func KvIs<T : BinaryFloatingPoint>(_ lhs: ClosedRange<T>, inequalTo rhs: ClosedRange<T>) -> Bool {
    KvIs(lhs.lowerBound, inequalTo: rhs.lowerBound) || KvIs(lhs.upperBound, inequalTo: rhs.upperBound)
}

/// - Returns: A boolean value indicating whether *lhs* is inequal to *rhs* taking into account the computational error.
///
/// - Note: E.g. 0.1 · 10 is 1.0 but `(0..<10).reduce(0.0, { a, _ in a + 0.1 }) == 1.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
@inlinable
public func KvIs<T : BinaryFloatingPoint>(_ lhs: ClosedRange<T>, inequalTo rhs: PartialRangeFrom<T>) -> Bool {
    KvIs(lhs.lowerBound, inequalTo: rhs.lowerBound) || lhs.upperBound != .infinity
}

/// - Returns: A boolean value indicating whether *lhs* is inequal to *rhs* taking into account the computational error.
///
/// - Note: E.g. 0.1 · 10 is 1.0 but `(0..<10).reduce(0.0, { a, _ in a + 0.1 }) == 1.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
@inlinable
public func KvIs<T : BinaryFloatingPoint>(_ lhs: ClosedRange<T>, inequalTo rhs: PartialRangeThrough<T>) -> Bool {
    lhs.upperBound != -.infinity || KvIs(lhs.upperBound, inequalTo: rhs.upperBound)
}

/// - Returns: A boolean value indicating whether *lhs* is inequal to *rhs* taking into account the computational error.
///
/// - Note: E.g. 0.1 · 10 is 1.0 but `(0..<10).reduce(0.0, { a, _ in a + 0.1 }) == 1.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
@inlinable
public func KvIs<T : BinaryFloatingPoint>(_ lhs: PartialRangeFrom<T>, inequalTo rhs: PartialRangeFrom<T>) -> Bool {
    KvIs(lhs.lowerBound, inequalTo: rhs.lowerBound)
}

/// - Returns: A boolean value indicating whether *lhs* is inequal to *rhs* taking into account the computational error.
///
/// - Note: E.g. 0.1 · 10 is 1.0 but `(0..<10).reduce(0.0, { a, _ in a + 0.1 }) == 1.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
@inlinable
public func KvIs<T : BinaryFloatingPoint>(_ lhs: PartialRangeFrom<T>, inequalTo rhs: Range<T>) -> Bool {
    KvIs(lhs.lowerBound, inequalTo: rhs.lowerBound) || rhs.upperBound != .infinity
}

/// - Returns: A boolean value indicating whether *lhs* is inequal to *rhs* taking into account the computational error.
///
/// - Note: E.g. 0.1 · 10 is 1.0 but `(0..<10).reduce(0.0, { a, _ in a + 0.1 }) == 1.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
@inlinable
public func KvIs<T : BinaryFloatingPoint>(_ lhs: PartialRangeFrom<T>, inequalTo rhs: ClosedRange<T>) -> Bool {
    KvIs(lhs.lowerBound, inequalTo: rhs.lowerBound) || rhs.upperBound != .infinity
}

/// - Returns: A boolean value indicating whether *lhs* is inequal to *rhs* taking into account the computational error.
///
/// - Note: E.g. 0.1 · 10 is 1.0 but `(0..<10).reduce(0.0, { a, _ in a + 0.1 }) == 1.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
@inlinable
public func KvIs<T : BinaryFloatingPoint>(_ lhs: PartialRangeUpTo<T>, inequalTo rhs: PartialRangeUpTo<T>) -> Bool {
    KvIs(lhs.upperBound, inequalTo: rhs.upperBound)
}

/// - Returns: A boolean value indicating whether *lhs* is inequal to *rhs* taking into account the computational error.
///
/// - Note: E.g. 0.1 · 10 is 1.0 but `(0..<10).reduce(0.0, { a, _ in a + 0.1 }) == 1.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
@inlinable
public func KvIs<T : BinaryFloatingPoint>(_ lhs: PartialRangeUpTo<T>, inequalTo rhs: Range<T>) -> Bool {
    rhs.lowerBound != -.infinity || KvIs(lhs.upperBound, inequalTo: rhs.upperBound)
}

/// - Returns: A boolean value indicating whether *lhs* is inequal to *rhs* taking into account the computational error.
///
/// - Note: E.g. 0.1 · 10 is 1.0 but `(0..<10).reduce(0.0, { a, _ in a + 0.1 }) == 1.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
@inlinable
public func KvIs<T : BinaryFloatingPoint>(_ lhs: PartialRangeThrough<T>, inequalTo rhs: PartialRangeThrough<T>) -> Bool {
    KvIs(lhs.upperBound, inequalTo: rhs.upperBound)
}

/// - Returns: A boolean value indicating whether *lhs* is inequal to *rhs* taking into account the computational error.
///
/// - Note: E.g. 0.1 · 10 is 1.0 but `(0..<10).reduce(0.0, { a, _ in a + 0.1 }) == 1.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
@inlinable
public func KvIs<T : BinaryFloatingPoint>(_ lhs: PartialRangeThrough<T>, inequalTo rhs: ClosedRange<T>) -> Bool {
    rhs.lowerBound != -.infinity || KvIs(lhs.upperBound, inequalTo: rhs.upperBound)
}



/// - Returns: A boolean value indicating whether given range is degenerate.
///
/// - Note: E.g. 0.1 · 10 is 1.0 but `(0..<10).reduce(0.0, { a, _ in a + 0.1 }) == 1.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
@inlinable public func KvIsDegenerate<T : BinaryFloatingPoint>(_ r: Range<T>) -> Bool { KvIs(r.lowerBound, equalTo: r.upperBound) }

/// - Returns: A boolean value indicating whether given range is degenerate.
///
/// - Note: E.g. 0.1 · 10 is 1.0 but `(0..<10).reduce(0.0, { a, _ in a + 0.1 }) == 1.0` is *false*. It's due to 0.1 is unable to be exactly represented in a binary format.
@inlinable public func KvIsDegenerate<T : BinaryFloatingPoint>(_ r: ClosedRange<T>) -> Bool { KvIs(r.lowerBound, equalTo: r.upperBound) }



// MARK: - Power of 2

@inlinable
public func KvIsPowerOf2<T>(_ value: T) -> Bool where T : FixedWidthInteger {
    value > 0 && value.nonzeroBitCount == 1
}

/// - Note: Works for negative powers of two.
@inlinable
public func KvIsPowerOf2<T>(_ value: T) -> Bool where T : BinaryFloatingPoint {
    value > 0 && value.significandWidth == 0
}



// MARK: - Legacy

extension KvNumericTolerance {

    // TODO: Delete in 5.0.0
    @available(*, deprecated, renamed: "default")
    @inlinable public static var zero: Self { .default }

}


// TODO: Delete in 5.0.0
@available(*, deprecated, renamed: "KvEps(for:)")
@inlinable
public func KvUlp<T : BinaryFloatingPoint>(of value: T) -> T { KvEpsArg(value).tolerance.value }
