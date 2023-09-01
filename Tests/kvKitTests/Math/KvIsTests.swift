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
//  KvIsTests.swift
//  KvKitTests
//
//  Created by Svyatoslav Popov on 01.09.2023.
//

import XCTest

@testable import kvKit



final class KvIsTests : XCTestCase {

    // MARK: - testKvIsPowerOf2_i()

    func testKvIsPowerOf2_i() {
        assertEqual(KvIsPowerOf2(_:), with: -2, expected: false, "KvIsPowerOf2(Int)")
        assertEqual(KvIsPowerOf2(_:), with: -1, expected: false, "KvIsPowerOf2(Int)")
        assertEqual(KvIsPowerOf2(_:), with:  0, expected: false, "KvIsPowerOf2(Int)")
        assertEqual(KvIsPowerOf2(_:), with:  1, expected: true , "KvIsPowerOf2(Int)")
        assertEqual(KvIsPowerOf2(_:), with:  2, expected: true , "KvIsPowerOf2(Int)")
        assertEqual(KvIsPowerOf2(_:), with:  3, expected: false, "KvIsPowerOf2(Int)")
        assertEqual(KvIsPowerOf2(_:), with:  4, expected: true , "KvIsPowerOf2(Int)")
    }



    // MARK: - testKvIsPowerOf2_d()

    func testKvIsPowerOf2_d() {
        assertEqual(KvIsPowerOf2(_:), with: -2.0    , expected: false, "KvIsPowerOf2(Double)")
        assertEqual(KvIsPowerOf2(_:), with: -1.0    , expected: false, "KvIsPowerOf2(Double)")
        assertEqual(KvIsPowerOf2(_:), with: -0.1    , expected: false, "KvIsPowerOf2(Double)")
        assertEqual(KvIsPowerOf2(_:), with:  0.0    , expected: false, "KvIsPowerOf2(Double)")
        assertEqual(KvIsPowerOf2(_:), with:  0.1    , expected: false, "KvIsPowerOf2(Double)")
        assertEqual(KvIsPowerOf2(_:), with:  0.25   , expected: true , "KvIsPowerOf2(Double)")
        assertEqual(KvIsPowerOf2(_:), with:  0.25001, expected: false, "KvIsPowerOf2(Double)")
        assertEqual(KvIsPowerOf2(_:), with:  0.5    , expected: true , "KvIsPowerOf2(Double)")
        assertEqual(KvIsPowerOf2(_:), with:  1.0    , expected: true , "KvIsPowerOf2(Double)")
        assertEqual(KvIsPowerOf2(_:), with:  2.0    , expected: true , "KvIsPowerOf2(Double)")
        assertEqual(KvIsPowerOf2(_:), with:  3.0    , expected: false, "KvIsPowerOf2(Double)")
        assertEqual(KvIsPowerOf2(_:), with:  4.0    , expected: true , "KvIsPowerOf2(Double)")
        assertEqual(KvIsPowerOf2(_:), with:  4.5    , expected: false, "KvIsPowerOf2(Double)")
    }



    // MARK: - testKvIsInRange()

    func testKvIsInRange() {
        // Range<T>
        assertEqual(KvIs(_:in:), with: (2.0, 0.0 ..< 0.0), expected: false, "KvIs(_:T,in:Range<T>)")
        assertEqual(KvIs(_:in:), with: (2.0, 0.0 ..< 1.0), expected: false, "KvIs(_:T,in:Range<T>)")
        assertEqual(KvIs(_:in:), with: (2.0, 0.0 ..< 2.0), expected: false, "KvIs(_:T,in:Range<T>)")
        assertEqual(KvIs(_:in:), with: (2.0, 1.0 ..< 4.0), expected: true , "KvIs(_:T,in:Range<T>)")
        assertEqual(KvIs(_:in:), with: (2.0, 2.0 ..< 4.0), expected: true , "KvIs(_:T,in:Range<T>)")
        assertEqual(KvIs(_:in:), with: (2.0, 3.0 ..< 4.0), expected: false, "KvIs(_:T,in:Range<T>)")
        // ClosedRange<T>
        assertEqual(KvIs(_:in:), with: (2.0, 0.0 ... 0.0), expected: false, "KvIs(_:T,in:ClosedRange<T>)")
        assertEqual(KvIs(_:in:), with: (2.0, 0.0 ... 1.0), expected: false, "KvIs(_:T,in:ClosedRange<T>)")
        assertEqual(KvIs(_:in:), with: (2.0, 0.0 ... 2.0), expected: true , "KvIs(_:T,in:ClosedRange<T>)")
        assertEqual(KvIs(_:in:), with: (2.0, 1.0 ... 4.0), expected: true , "KvIs(_:T,in:ClosedRange<T>)")
        assertEqual(KvIs(_:in:), with: (2.0, 2.0 ... 4.0), expected: true , "KvIs(_:T,in:ClosedRange<T>)")
        assertEqual(KvIs(_:in:), with: (2.0, 3.0 ... 4.0), expected: false, "KvIs(_:T,in:ClosedRange<T>)")
        // PartialRangeFrom<T>
        assertEqual(KvIs(_:in:), with: (2.0, 1.0...), expected: true , "KvIs(_:T,in:PartialRangeFrom<T>)")
        assertEqual(KvIs(_:in:), with: (2.0, 2.0...), expected: true , "KvIs(_:T,in:PartialRangeFrom<T>)")
        assertEqual(KvIs(_:in:), with: (2.0, 3.0...), expected: false, "KvIs(_:T,in:PartialRangeFrom<T>)")
        // PartialRangeUpTo<T>
        assertEqual(KvIs(_:in:), with: (2.0, ..<1.0), expected: false, "KvIs(_:T,in:PartialRangeUpTo<T>)")
        assertEqual(KvIs(_:in:), with: (2.0, ..<2.0), expected: false, "KvIs(_:T,in:PartialRangeUpTo<T>)")
        assertEqual(KvIs(_:in:), with: (2.0, ..<3.0), expected: true , "KvIs(_:T,in:PartialRangeUpTo<T>)")
        // PartialRangeThrough<T>
        assertEqual(KvIs(_:in:), with: (2.0, ...1.0), expected: false, "KvIs(_:T,in:PartialRangeThrough<T>)")
        assertEqual(KvIs(_:in:), with: (2.0, ...2.0), expected: true , "KvIs(_:T,in:PartialRangeThrough<T>)")
        assertEqual(KvIs(_:in:), with: (2.0, ...3.0), expected: true , "KvIs(_:T,in:PartialRangeThrough<T>)")
    }



    // MARK: - testKvIsOutOfRange()

    func testKvIsOutOfRange() {
        // Range<T>
        assertEqual(KvIs(_:outOf:), with: (2.0, 0.0 ..< 0.0), expected: !false, "KvIs(_:T,outOf:Range<T>)")
        assertEqual(KvIs(_:outOf:), with: (2.0, 0.0 ..< 1.0), expected: !false, "KvIs(_:T,outOf:Range<T>)")
        assertEqual(KvIs(_:outOf:), with: (2.0, 0.0 ..< 2.0), expected: !false, "KvIs(_:T,outOf:Range<T>)")
        assertEqual(KvIs(_:outOf:), with: (2.0, 1.0 ..< 4.0), expected: !true , "KvIs(_:T,outOf:Range<T>)")
        assertEqual(KvIs(_:outOf:), with: (2.0, 2.0 ..< 4.0), expected: !true , "KvIs(_:T,outOf:Range<T>)")
        assertEqual(KvIs(_:outOf:), with: (2.0, 3.0 ..< 4.0), expected: !false, "KvIs(_:T,outOf:Range<T>)")
        // ClosedRange<T>
        assertEqual(KvIs(_:outOf:), with: (2.0, 0.0 ... 0.0), expected: !false, "KvIs(_:T,outOf:ClosedRange<T>)")
        assertEqual(KvIs(_:outOf:), with: (2.0, 0.0 ... 1.0), expected: !false, "KvIs(_:T,outOf:ClosedRange<T>)")
        assertEqual(KvIs(_:outOf:), with: (2.0, 0.0 ... 2.0), expected: !true , "KvIs(_:T,outOf:ClosedRange<T>)")
        assertEqual(KvIs(_:outOf:), with: (2.0, 1.0 ... 4.0), expected: !true , "KvIs(_:T,outOf:ClosedRange<T>)")
        assertEqual(KvIs(_:outOf:), with: (2.0, 2.0 ... 4.0), expected: !true , "KvIs(_:T,outOf:ClosedRange<T>)")
        assertEqual(KvIs(_:outOf:), with: (2.0, 3.0 ... 4.0), expected: !false, "KvIs(_:T,outOf:ClosedRange<T>)")
        // PartialRangeFrom<T>
        assertEqual(KvIs(_:outOf:), with: (2.0, 1.0...), expected: !true , "KvIs(_:T,outOf:PartialRangeFrom<T>)")
        assertEqual(KvIs(_:outOf:), with: (2.0, 2.0...), expected: !true , "KvIs(_:T,outOf:PartialRangeFrom<T>)")
        assertEqual(KvIs(_:outOf:), with: (2.0, 3.0...), expected: !false, "KvIs(_:T,outOf:PartialRangeFrom<T>)")
        // PartialRangeUpTo<T>
        assertEqual(KvIs(_:outOf:), with: (2.0, ..<1.0), expected: !false, "KvIs(_:T,outOf:PartialRangeUpTo<T>)")
        assertEqual(KvIs(_:outOf:), with: (2.0, ..<2.0), expected: !false, "KvIs(_:T,outOf:PartialRangeUpTo<T>)")
        assertEqual(KvIs(_:outOf:), with: (2.0, ..<3.0), expected: !true , "KvIs(_:T,outOf:PartialRangeUpTo<T>)")
        // PartialRangeThrough<T>
        assertEqual(KvIs(_:outOf:), with: (2.0, ...1.0), expected: !false, "KvIs(_:T,outOf:PartialRangeThrough<T>)")
        assertEqual(KvIs(_:outOf:), with: (2.0, ...2.0), expected: !true , "KvIs(_:T,outOf:PartialRangeThrough<T>)")
        assertEqual(KvIs(_:outOf:), with: (2.0, ...3.0), expected: !true , "KvIs(_:T,outOf:PartialRangeThrough<T>)")
    }



    // MARK: - Auxiliaries

    private func assertEqual<I, R>(_ subject: (I) -> R, with input: I, expected: R, _ label: @autoclosure () -> String) where R : Equatable {
        let result = subject(input)
        XCTAssertEqual(result, expected, "\(label()): `\(result)` is not equal to expected `\(expected)` for `\(input)` input")
    }

}
