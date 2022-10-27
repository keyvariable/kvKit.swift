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
//  KvMathTestKit.swift
//  kvKit
//
//  Created by Svyatoslav Popov on 12.10.2022.
//

import XCTest

@testable import kvKit



/// Invokes ``XCTFail``() when *result* and *expectation* are not numerically equal.
@inlinable
public func KvAssertEqual<T : KvNumericallyEquatable>(_ result: T, _ expected: T, _ message: @autoclosure () -> String = "") {
    KvAssertEqual(result, expected, by: T.isEqual(_:to:), message())
}

/// Invokes ``XCTFail``() when *result* and *expectation* are not both `nil` or *result* and *expectation* are not numerically equal.
@inlinable
public func KvAssertEqual<T : KvNumericallyEquatable>(_ result: T?, _ expected: T?, _ message: @autoclosure () -> String = "") {
    KvAssertEqual(result, expected, by: T.isEqual(_:to:), message())
}


/// Invokes ``XCTFail``() when *result* and *expectation* are not numerically equal.
@inlinable
public func KvAssertEqual<Math : KvMathScope>(_ math: Math.Type, _ result: Math.Vector2, _ expected: Math.Vector2, _ message: @autoclosure () -> String = "") {
    KvAssertEqual(result, expected, by: Math.isEqual(_:_:), message())
}

/// Invokes ``XCTFail``() when *result* and *expectation* are not both `nil` or *result* and *expectation* are not numerically equal.
@inlinable
public func KvAssertEqual<Math : KvMathScope>(_ math: Math.Type, _ result: Math.Vector2?, _ expected: Math.Vector2?, _ message: @autoclosure () -> String = "") {
    KvAssertEqual(result, expected, by: Math.isEqual(_:_:), message())
}

/// Invokes ``XCTFail``() when *result* and *expectation* are not numerically equal.
@inlinable
public func KvAssertEqual<Math : KvMathScope>(_ math: Math.Type, _ result: Math.Vector3, _ expected: Math.Vector3, _ message: @autoclosure () -> String = "") {
    KvAssertEqual(result, expected, by: Math.isEqual(_:_:), message())
}

/// Invokes ``XCTFail``() when *result* and *expectation* are not both `nil` or *result* and *expectation* are not numerically equal.
@inlinable
public func KvAssertEqual<Math : KvMathScope>(_ math: Math.Type, _ result: Math.Vector3?, _ expected: Math.Vector3?, _ message: @autoclosure () -> String = "") {
    KvAssertEqual(result, expected, by: Math.isEqual(_:_:), message())
}

/// Invokes ``XCTFail``() when *result* and *expectation* are not numerically equal.
@inlinable
public func KvAssertEqual<Math : KvMathScope>(_ math: Math.Type, _ result: Math.Vector4, _ expected: Math.Vector4, _ message: @autoclosure () -> String = "") {
    KvAssertEqual(result, expected, by: Math.isEqual(_:_:), message())
}

/// Invokes ``XCTFail``() when *result* and *expectation* are not both `nil` or *result* and *expectation* are not numerically equal.
@inlinable
public func KvAssertEqual<Math : KvMathScope>(_ math: Math.Type, _ result: Math.Vector4?, _ expected: Math.Vector4?, _ message: @autoclosure () -> String = "") {
    KvAssertEqual(result, expected, by: Math.isEqual(_:_:), message())
}

/// Invokes ``XCTFail``() when *result* and *expectation* are not numerically equal.
@inlinable
public func KvAssertEqual<Math : KvMathScope>(_ math: Math.Type, _ result: Math.Quaternion, _ expected: Math.Quaternion, _ message: @autoclosure () -> String = "") {
    KvAssertEqual(result, expected, by: Math.isEqual(_:_:), message())
}

/// Invokes ``XCTFail``() when *result* and *expectation* are not both `nil` or *result* and *expectation* are not numerically equal.
@inlinable
public func KvAssertEqual<Math : KvMathScope>(_ math: Math.Type, _ result: Math.Quaternion?, _ expected: Math.Quaternion?, _ message: @autoclosure () -> String = "") {
    KvAssertEqual(result, expected, by: Math.isEqual(_:_:), message())
}

/// Invokes ``XCTFail``() when *result* and *expectation* are not numerically equal.
@inlinable
public func KvAssertEqual<Math : KvMathScope>(_ math: Math.Type, _ result: Math.Matrix2x2, _ expected: Math.Matrix2x2, _ message: @autoclosure () -> String = "") {
    KvAssertEqual(result, expected, by: Math.isEqual(_:_:), message())
}

/// Invokes ``XCTFail``() when *result* and *expectation* are not both `nil` or *result* and *expectation* are not numerically equal.
@inlinable
public func KvAssertEqual<Math : KvMathScope>(_ math: Math.Type, _ result: Math.Matrix2x2?, _ expected: Math.Matrix2x2?, _ message: @autoclosure () -> String = "") {
    KvAssertEqual(result, expected, by: Math.isEqual(_:_:), message())
}

/// Invokes ``XCTFail``() when *result* and *expectation* are not numerically equal.
@inlinable
public func KvAssertEqual<Math : KvMathScope>(_ math: Math.Type, _ result: Math.Matrix3x3, _ expected: Math.Matrix3x3, _ message: @autoclosure () -> String = "") {
    KvAssertEqual(result, expected, by: Math.isEqual(_:_:), message())
}

/// Invokes ``XCTFail``() when *result* and *expectation* are not both `nil` or *result* and *expectation* are not numerically equal.
@inlinable
public func KvAssertEqual<Math : KvMathScope>(_ math: Math.Type, _ result: Math.Matrix3x3?, _ expected: Math.Matrix3x3?, _ message: @autoclosure () -> String = "") {
    KvAssertEqual(result, expected, by: Math.isEqual(_:_:), message())
}

/// Invokes ``XCTFail``() when *result* and *expectation* are not numerically equal.
@inlinable
public func KvAssertEqual<Math : KvMathScope>(_ math: Math.Type, _ result: Math.Matrix4x4, _ expected: Math.Matrix4x4, _ message: @autoclosure () -> String = "") {
    KvAssertEqual(result, expected, by: Math.isEqual(_:_:), message())
}

/// Invokes ``XCTFail``() when *result* and *expectation* are not both `nil` or *result* and *expectation* are not numerically equal.
@inlinable
public func KvAssertEqual<Math : KvMathScope>(_ math: Math.Type, _ result: Math.Matrix4x4?, _ expected: Math.Matrix4x4?, _ message: @autoclosure () -> String = "") {
    KvAssertEqual(result, expected, by: Math.isEqual(_:_:), message())
}
