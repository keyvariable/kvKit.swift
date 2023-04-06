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
//  KvMath.swift
//  KvKit
//
//  Created by Svyatoslav Popov on 11.12.2019.
//

import Foundation
import simd



/// - Returns: The closest value to *x* from *min*...*max* range.
@inlinable
public func clamp<T>(_ x: T, _ min: T, _ max: T) -> T where T : Comparable {
    x < min ? min : (x > max ? max : x)
}

@inlinable
public func clamp(_ x: Float, min: Float, max: Float) -> Float { simd_clamp(x, min, max) }

@inlinable
public func clamp(_ x: Double, min: Double, max: Double) -> Double { simd_clamp(x, min, max) }


/// - Returns: The closest value to *x* from given range.
@inlinable
public func clamp<T>(_ x: T, to range: ClosedRange<T>) -> T where T : Comparable {
    clamp(x, range.lowerBound, range.upperBound)
}

/// - Returns: The closest value to *x* from given range.
@inlinable
public func clamp(_ x: Float, to range: ClosedRange<Float>) -> Float {
    simd_clamp(x, range.lowerBound, range.upperBound)
}

/// - Returns: The closest value to *x* from given range.
@inlinable
public func clamp(_ x: Double, to range: ClosedRange<Double>) -> Double {
    simd_clamp(x, range.lowerBound, range.upperBound)
}


/// Fast implementation of the logarithm base 2 for integer arguments.
/// - Returns: max(p), where 2^p ≤ x.
@inlinable
public func lg₂<T>(_ x: T) -> Int where T : FixedWidthInteger {
    x.bitWidth - (x.leadingZeroBitCount + 1)
}


@inlinable
public func max<T>(_ x: T, _ y: T?) -> T where T : Comparable {
    switch y {
    case .some(let y):
        return max(x, y)
    case .none:
        return x
    }
}

@inlinable
public func max<T>(_ x: T?, _ y: T) -> T where T : Comparable {
    switch x {
    case .some(let x):
        return max(x, y)
    case .none:
        return y
    }
}

@inlinable
public func max<T>(_ x: T, _ y: T?, _ z: T?, _ rest: T?...) -> T where T : Comparable {
    rest.reduce(max(max(x, y), z), max)
}

@inlinable
public func max<T>(_ x: T?, _ y: T, _ z: T, _ rest: T...) -> T where T : Comparable {
    rest.reduce(max(max(x, y), z), max)
}

@inlinable
public func max<T>(_ x: T?, _ y: T?) -> T? where T : Comparable {
    switch (x, y) {
    case let (.some(x), .some(y)):
        return max(x, y)
    case (.some, .none):
        return x
    case (.none, .some):
        return y
    case (.none, .none):
        return nil
    }
}

@inlinable
public func max<T>(_ x: T?, _ y: T?, _ z: T?, _ rest: T?...) -> T? where T : Comparable {
    max(max(x, y), rest.reduce(z, max))
}


@inlinable
public func min<T>(_ x: T, _ y: T?) -> T where T : Comparable {
    switch y {
    case .some(let y):
        return min(x, y)
    case .none:
        return x
    }
}

@inlinable
public func min<T>(_ x: T?, _ y: T) -> T where T : Comparable {
    switch x {
    case .some(let x):
        return min(x, y)
    case .none:
        return y
    }
}

@inlinable
public func min<T>(_ x: T, _ y: T?, _ z: T?, _ rest: T?...) -> T where T : Comparable {
    rest.reduce(min(min(x, y), z), min)
}

@inlinable
public func min<T>(_ x: T?, _ y: T, _ z: T, _ rest: T...) -> T where T : Comparable {
    rest.reduce(min(min(x, y), z), min)
}

@inlinable
public func min<T>(_ x: T?, _ y: T?) -> T? where T : Comparable {
    switch (x, y) {
    case let (.some(x), .some(y)):
        return min(x, y)
    case (.some, .none):
        return x
    case (.none, .some):
        return y
    case (.none, .none):
        return nil
    }
}

@inlinable
public func min<T>(_ x: T?, _ y: T?, _ z: T?, _ rest: T?...) -> T? where T : Comparable {
    min(min(x, y), rest.reduce(z, min))
}


@inlinable
public func mix<T>(_ x: T, _ y: T, t: T) -> T where T : Numeric {
    x * (1 - t) + y * t
}

@inlinable public func mix(_ x: Float, _ y: Float, t: Float) -> Float { simd_mix(x, y, t) }

@inlinable public func mix(_ x: Double, _ y: Double, t: Double) -> Double { simd_mix(x, y, t) }


/// - Returns: `1 / sqrt(x)`.
///
/// - Note: Some specializations are fast. E.g. SIMD.
@inlinable
public func rsqrt<T>(_ x: T) -> T where T : BinaryFloatingPoint {
    1 / x.squareRoot()
}


/// - Returns: One of `[ -1, 0, 1]`  depending on sign of the argument.
@inlinable
public func sign<T, Sign: ExpressibleByIntegerLiteral>(_ x: T, eps: T) -> Sign
where T : SignedNumeric & Comparable {
    x >= eps ? 1 : (x > -eps ? 0 : -1)
}

/// - Returns: One of `[ -1, 0, 1]`  depending on sign of the argument.
@inlinable
public func sign<T, Sign: ExpressibleByIntegerLiteral>(_ x: T) -> Sign
where T : BinaryInteger {
    x > 0 ? 1 : (x == 0 ? 0 : -1)
}

/// - Returns: One of `[ -1, 0, 1]`  depending on sign of the argument.
@inlinable
public func sign<T, Sign: ExpressibleByIntegerLiteral>(_ x: T) -> Sign
where T : BinaryFloatingPoint {
    var isPositive = false

    return KvIsZero(x, alsoIsPositive: &isPositive) ? 0 : (isPositive ? 1 : -1)
}


/// - Returns: *x*².
@inlinable
public func sqr<T>(_ x: T) -> T where T : Numeric {
    x * x
}



// MARK: - Legacy

// TODO: Delete when KvMath will become degenerate.
@available(*, deprecated, message: "Use global analogs instead of KvMath methods")
public enum KvMath<Scalar> { }


@available(*, deprecated, message: "Use global analogs instead of KvMath methods")
extension KvMath where Scalar : Numeric {

    @available(*, deprecated, message: "Use global analog instead")
    @inlinable public static func sqr(_ x: Scalar) -> Scalar { x * x }

}


@available(*, deprecated, message: "Use global analogs instead of KvMath methods")
extension KvMath where Scalar : Comparable {

    @available(*, deprecated, message: "Use global analog instead")
    @inlinable public static func clamp(_ x: Scalar, _ min: Scalar, _ max: Scalar) -> Scalar { x < min ? min : (x > max ? max : x) }

    @available(*, deprecated, message: "Use global analog instead")
    @inlinable public static func clamp(_ x: Scalar, to range: ClosedRange<Scalar>) -> Scalar { clamp(x, range.lowerBound, range.upperBound) }

}


@available(*, deprecated, message: "Use global analogs instead of KvMath methods")
extension KvMath where Scalar : SignedNumeric & Comparable {

    @available(*, deprecated, message: "Use global analog instead")
    @inlinable public static func sign<Sign: ExpressibleByIntegerLiteral>(_ x: Scalar, eps: Scalar) -> Sign { x >= eps ? 1 : (x > -eps ? 0 : -1) }

}


@available(*, deprecated, message: "Use global analogs instead of KvMath methods")
extension KvMath where Scalar : BinaryInteger {

    @available(*, deprecated, message: "Use global analog instead")
    @inlinable public static func sign<Sign: ExpressibleByIntegerLiteral>(_ x: Scalar) -> Sign { x > 0 ? 1 : (x == 0 ? 0 : -1) }

}


@available(*, deprecated, message: "Use global analogs instead of KvMath methods")
extension KvMath where Scalar : BinaryFloatingPoint {

    @available(*, deprecated, message: "Use KvMathScalar.mix(_:_:t:)")
    @inlinable public static func mix(_ a: Scalar, _ b: Scalar, t: Scalar) -> Scalar { (1 - t) * a + t * b }

    @available(*, deprecated, message: "Use global analog instead")
    @inlinable public static func sign<Sign: ExpressibleByIntegerLiteral>(_ x: Scalar) -> Sign {
        var isPositive = false

        return KvIsZero(x, alsoIsPositive: &isPositive) ? 0 : (isPositive ? 1 : -1)
    }

}


@available(*, deprecated, message: "Use global analogs instead of KvMath methods")
extension KvMath where Scalar : FixedWidthInteger {

    @available(*, deprecated, message: "Use global analog instead")
    @inlinable public static func lg₂(_ x: Scalar) -> Int { x.bitWidth - (x.leadingZeroBitCount + 1) }

}



// MARK: Minimum for Optionals

@available(*, deprecated, message: "Use global analogs instead of KvMath methods")
extension KvMath where Scalar : Comparable {

    @available(*, deprecated, message: "Use global analog instead")
    @inlinable public static func min(_ x: Scalar, _ y: Scalar?) -> Scalar { y.map({ Swift.min(x, $0) }) ?? x }


    @available(*, deprecated, message: "Use global analog instead")
    @inlinable public static func min(_ x: Scalar, _ y: Scalar?, _ z: Scalar?, _ rest: Scalar?...) -> Scalar { rest.reduce(min(min(x, y), z), min) }


    @available(*, deprecated, message: "Use global analog instead")
    @inlinable public static func min(_ x: Scalar?, _ y: Scalar?) -> Scalar? {
        switch (x, y) {
        case let (.some(x), .some(y)):
            return Swift.min(x, y)
        case (.some, .none):
            return x
        case (.none, .some):
            return y
        case (.none, .none):
            return nil
        }
    }


    @available(*, deprecated, message: "Use global analog instead")
    @inlinable public static func min(_ x: Scalar?, _ y: Scalar?, _ z: Scalar?, _ rest: Scalar?...) -> Scalar? {
        min(min(x, y), rest.reduce(z, min))
    }

}



// MARK: Maximum for Optionals

@available(*, deprecated, message: "Use global analogs instead of KvMath methods")
extension KvMath where Scalar : Comparable {

    @available(*, deprecated, message: "Use global analog instead")
    @inlinable public static func max(_ x: Scalar, _ y: Scalar?) -> Scalar { y.map({ Swift.max(x, $0) }) ?? x }


    @available(*, deprecated, message: "Use global analog instead")
    @inlinable public static func max(_ x: Scalar, _ y: Scalar?, _ z: Scalar?, _ rest: Scalar?...) -> Scalar {
        rest.reduce(max(max(x, y), z), max)
    }


    @available(*, deprecated, message: "Use global analog instead")
    @inlinable public static func max(_ x: Scalar?, _ y: Scalar?) -> Scalar? {
        switch (x, y) {
        case let (.some(x), .some(y)):
            return Swift.max(x, y)
        case (.some, .none):
            return x
        case (.none, .some):
            return y
        case (.none, .none):
            return nil
        }
    }


    @available(*, deprecated, message: "Use global analog instead")
    @inlinable public static func max(_ x: Scalar?, _ y: Scalar?, _ z: Scalar?, _ rest: Scalar?...) -> Scalar? {
        max(max(x, y), rest.reduce(z, max))
    }

}



// MARK: - Legacy: Comparable

@available(*, deprecated, message: "Use global analogs instead of KvMath methods")
extension KvMath where Scalar : Comparable {

    @available(*, deprecated, message: "Use global analog instead")
    @inlinable public static func clamp(_ x: Scalar, min: Scalar, max: Scalar) -> Scalar { clamp(x, min, max) }

}
