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
//  KvMath.swift
//  KvKit
//
//  Created by Svyatoslav Popov on 11.12.2019.
//

import simd



public typealias KvMathFloatingPoint = BinaryFloatingPoint & SIMDScalar



/// Various math auxiliaries.
public enum KvMath<Scalar> { }



// MARK: Arithmetic

extension KvMath where Scalar : Numeric {

    /// - Returns: *x*².
    @inlinable
    public static func sqr(_ x: Scalar) -> Scalar {
        x * x
    }

}


extension KvMath where Scalar : Comparable {

    /// - Returns: The closest value to *x* from *min*...*max* range.
    @inlinable
    public static func clamp(_ x: Scalar, _ min: Scalar, _ max: Scalar) -> Scalar {
        x < min ? min : (x > max ? max : x)
    }


    /// - Returns: The closest value to *x* from given range.
    @inlinable
    public static func clamp(_ x: Scalar, to range: ClosedRange<Scalar>) -> Scalar {
        clamp(x, range.lowerBound, range.upperBound)
    }

}


// MARK: Arithmetic: SignedNumeric

extension KvMath where Scalar : SignedNumeric & Comparable {

    /// - Returns: One of `[ -1, 0, 1]`  depending on sign of the argument.
    @inlinable
    public static func sign<Sign: ExpressibleByIntegerLiteral>(_ x: Scalar, eps: Scalar) -> Sign {
        x >= eps ? 1 : (x > -eps ? 0 : -1)
    }

}


// MARK: Arithmetic : BinaryInteger

extension KvMath where Scalar : BinaryInteger {

    /// - Returns: One of `[ -1, 0, 1]`  depending on sign of the argument.
    @inlinable
    public static func sign<Sign: ExpressibleByIntegerLiteral>(_ x: Scalar) -> Sign {
        x > 0 ? 1 : (x == 0 ? 0 : -1)
    }

}


// MARK: Arithmetic : BinaryFloatingPoint

extension KvMath where Scalar : BinaryFloatingPoint {

    /// - Returns: One of `[ -1, 0, 1]`  depending on sign of the argument.
    @inlinable
    public static func sign<Sign: ExpressibleByIntegerLiteral>(_ x: Scalar) -> Sign {
        var isPositive = false

        return KvIsZero(x, alsoIsPositive: &isPositive) ? 0 : (isPositive ? 1 : -1)
    }


    /// - Returns: Value of linear function *f* at *t* where *f* at 0 equals to *a*, *f* at 1 equals to *b*.
    @inlinable
    public static func mix(_ a: Scalar, _ b: Scalar, t: Scalar) -> Scalar {
        (1 - t) * a + t * b
    }

}


// MARK: Arithmetic : FixedWidthInteger

extension KvMath where Scalar : FixedWidthInteger {

    @inlinable
    public static func lg₂(_ x: Scalar) -> Int {
        x.bitWidth - (x.leadingZeroBitCount + 1)
    }

}


// MARK: Arithmetic : Float

extension KvMath where Scalar == Float {

    /// - Returns: The closest value to *x* from *min*...*max* range.
    @inlinable public static func clamp(_ x: Scalar, min: Scalar, max: Scalar) -> Scalar { simd_clamp(x, min, max) }

    /// - Returns: Value of linear function *f* at *t* where *f* at 0 equals to *a*, *f* at 1 equals to *b*.
    @inlinable public static func mix(_ a: Scalar, _ b: Scalar, t: Scalar) -> Scalar { simd_mix(a, b, t) }

}


// MARK: Arithmetic : Double

extension KvMath where Scalar == Double {

    /// - Returns: The closest value to *x* from *min*...*max* range.
    @inlinable public static func clamp(_ x: Scalar, min: Scalar, max: Scalar) -> Scalar { simd_clamp(x, min, max) }

    /// - Returns: Value of linear function *f* at *t* where *f* at 0 equals to *a*, *f* at 1 equals to *b*.
    @inlinable public static func mix(_ a: Scalar, _ b: Scalar, t: Scalar) -> Scalar { simd_mix(a, b, t) }

}



// MARK: Minimum for Optionals

extension KvMath where Scalar : Comparable {

    @inlinable
    public static func min(_ x: Scalar, _ y: Scalar?) -> Scalar {
        y.map({ Swift.min(x, $0) }) ?? x
    }


    @inlinable
    public static func min(_ x: Scalar, _ y: Scalar?, _ z: Scalar?, _ rest: Scalar?...) -> Scalar {
        rest.reduce(min(min(x, y), z), min)
    }


    @inlinable
    public static func min(_ x: Scalar?, _ y: Scalar?) -> Scalar? {
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


    @inlinable
    public static func min(_ x: Scalar?, _ y: Scalar?, _ z: Scalar?, _ rest: Scalar?...) -> Scalar? {
        min(min(x, y), rest.reduce(z, min))
    }

}



// MARK: Maximum for Optionals

extension KvMath where Scalar : Comparable {

    @inlinable
    public static func max(_ x: Scalar, _ y: Scalar?) -> Scalar {
        y.map({ Swift.max(x, $0) }) ?? x
    }


    @inlinable
    public static func max(_ x: Scalar, _ y: Scalar?, _ z: Scalar?, _ rest: Scalar?...) -> Scalar {
        rest.reduce(max(max(x, y), z), max)
    }


    @inlinable
    public static func max(_ x: Scalar?, _ y: Scalar?) -> Scalar? {
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


    @inlinable
    public static func max(_ x: Scalar?, _ y: Scalar?, _ z: Scalar?, _ rest: Scalar?...) -> Scalar? {
        max(max(x, y), rest.reduce(z, max))
    }

}



// MARK: - Legacy: Comparable

extension KvMath where Scalar : Comparable {

    @available(*, deprecated, renamed: "clamp(_:_:_:)")
    @inlinable public static func clamp(_ x: Scalar, min: Scalar, max: Scalar) -> Scalar { clamp(x, min, max) }

}
