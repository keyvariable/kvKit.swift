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

import Foundation



/// Varios math auxiliaries.
public class KvMath { }



// MARK: Arithmetic

extension KvMath {

    /// - Returns: One of `[ -1, 0, 1]`  depending on sign of the argument.
    @inlinable
    public static func sign<T: BinaryInteger, S: ExpressibleByIntegerLiteral>(_ x: T) -> S {
        x > 0 ? 1 : (x == 0 ? 0 : -1)
    }



    /// - Returns: One of `[ -1, 0, 1]`  depending on sign of the argument.
    @inlinable
    public static func sign<T: BinaryFloatingPoint, S: ExpressibleByIntegerLiteral>(_ x: T) -> S {
        var isPositive = false

        return KvIsZero(x, alsoIsPositive: &isPositive) ? 0 : (isPositive ? 1 : -1)
    }



    /// - Returns: One of `[ -1, 0, 1]`  depending on sign of the argument.
    @inlinable
    public static func sign<T: SignedNumeric & Comparable, S: ExpressibleByIntegerLiteral>(_ x: T, eps: T) -> S {
        x >= eps ? 1 : (x > -eps ? 0 : -1)
    }



    /// - Returns: *x*².
    @inlinable
    public static func sqr<T: Numeric>(_ x: T) -> T {
        x * x
    }



    /// - Returns: The closest value to *x* from *min*...*max* range.
    @inlinable
    public static func clamp<T: Comparable>(_ x: T, min: T, max: T) -> T {
        x < min ? min : (x > max ? max : x)
    }



    /// - Returns: The closest value to *x* from given range.
    @inlinable
    public static func clamp<T: Comparable>(_ x: T, to range: ClosedRange<T>) -> T {
        clamp(x, min: range.lowerBound, max: range.upperBound)
    }



    @inlinable
    public static func lerp<T : Numeric>(_ a: T, _ b: T, weight: T) -> T {
        (1 - weight) * a + weight * b
    }



    @inlinable
    public static func lg₂<T : FixedWidthInteger>(_ x: T) -> Int {
        x.bitWidth - (x.leadingZeroBitCount + 1)
    }

}



// MARK: Minimum for Optionals

extension KvMath {

    @inlinable
    public static func min<T : Comparable>(_ lhs: T, _ rhs: T?) -> T {
        rhs != nil ? Swift.min(lhs, rhs!) : lhs
    }



    @inlinable
    public static func min<T : Comparable>(_ first: T, _ second: T?, _ others: T?...) -> T {
        min(first, others.reduce(second, min))
    }



    @inlinable
    public static func min<T : Comparable>(_ lhs: T?, _ rhs: T?) -> T? {
        switch (lhs, rhs) {
        case let (.some(l), .some(r)):
            return Swift.min(l, r)

        case (.some, .none):
            return lhs

        case (.none, .some):
            return rhs

        case (.none, .none):
            return nil
        }
    }



    @inlinable
    public static func min<T : Comparable>(_ first: T?, _ second: T?, _ others: T?...) -> T? {
        min(first, others.reduce(second, min))
    }

}



// MARK: Maximum for Optionals

extension KvMath {

    @inlinable
    public static func max<T : Comparable>(_ lhs: T, _ rhs: T?) -> T {
        rhs != nil ? Swift.max(lhs, rhs!) : lhs
    }



    @inlinable
    public static func max<T : Comparable>(_ first: T, _ second: T?, _ others: T?...) -> T {
        max(first, others.reduce(second, max))
    }



    @inlinable
    public static func max<T : Comparable>(_ lhs: T?, _ rhs: T?) -> T? {
        switch (lhs, rhs) {
        case let (.some(l), .some(r)):
            return Swift.max(l, r)

        case (.some, .none):
            return lhs

        case (.none, .some):
            return rhs

        case (.none, .none):
            return nil
        }
    }



    @inlinable
    public static func max<T : Comparable>(_ first: T?, _ second: T?, _ others: T?...) -> T? {
        max(first, others.reduce(second, max))
    }

}
