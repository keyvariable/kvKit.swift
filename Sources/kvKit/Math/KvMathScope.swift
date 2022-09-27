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
//  KvMathScope.swift
//  kvKit
//
//  Created by Svyatoslav Popov on 19.09.2022.
//

import simd



// MARK: - KvMathScope

/// A collection of lightweight inlinable wrappers over fast math functions.
/// It designed to implement scalar independent generic math code preserving the performance.
public protocol KvMathScope {

    associatedtype Scalar : SIMDScalar & BinaryFloatingPoint

    associatedtype Vector2 : KvSimd2F where Vector2.Scalar == Scalar
    associatedtype Vector3 : KvSimd3F where Vector3.Scalar == Scalar
    associatedtype Vector4 : KvSimd4F where Vector4.Scalar == Scalar

    associatedtype Quaternion : KvSimdQuaternion where Quaternion.Scalar == Scalar, Quaternion.Matrix3x3 == Matrix3x3, Quaternion.Matrix4x4 == Matrix4x4

    associatedtype Matrix2x2 : KvSimd2x2 where Matrix2x2.Scalar == Scalar, Matrix2x2.Row == Vector2
    associatedtype Matrix3x3 : KvSimd3x3 where Matrix3x3.Scalar == Scalar, Matrix3x3.Row == Vector3, Matrix3x3.Quaternion == Quaternion
    associatedtype Matrix4x4 : KvSimd4x4 where Matrix4x4.Scalar == Scalar, Matrix4x4.Row == Vector4, Matrix4x4.Quaternion == Quaternion


    // MARK: Operations

    static func abs(_ v: Vector2) -> Vector2
    static func abs(_ v: Vector3) -> Vector3
    static func abs(_ v: Vector4) -> Vector4
    static func abs(_ v: Matrix2x2) -> Matrix2x2
    static func abs(_ v: Matrix3x3) -> Matrix3x3
    static func abs(_ v: Matrix4x4) -> Matrix4x4

    static func acos(_ x: Scalar) -> Scalar
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    static func acos(_ v: Vector2) -> Vector2
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    static func acos(_ v: Vector3) -> Vector3
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    static func acos(_ v: Vector4) -> Vector4

    static func asin(_ x: Scalar) -> Scalar
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    static func asin(_ v: Vector2) -> Vector2
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    static func asin(_ v: Vector3) -> Vector3
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    static func asin(_ v: Vector4) -> Vector4

    static func atan(_ x: Scalar) -> Scalar
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    static func atan(_ v: Vector2) -> Vector2
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    static func atan(_ v: Vector3) -> Vector3
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    static func atan(_ v: Vector4) -> Vector4

    static func atan2(_ x: Scalar, _ y: Scalar) -> Scalar
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    static func atan2(_ x: Vector2, _ y: Vector2) -> Vector2
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    static func atan2(_ x: Vector3, _ y: Vector3) -> Vector3
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    static func atan2(_ x: Vector4, _ y: Vector4) -> Vector4

    static func cos(_ x: Scalar) -> Scalar
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    static func cos(_ v: Vector2) -> Vector2
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    static func cos(_ v: Vector3) -> Vector3
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    static func cos(_ v: Vector4) -> Vector4

    static func cospi(_ x: Scalar) -> Scalar
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    static func cospi(_ v: Vector2) -> Vector2
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    static func cospi(_ v: Vector3) -> Vector3
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    static func cospi(_ v: Vector4) -> Vector4

    static func cross(_ lhs: Vector2, _ rhs: Vector2) -> Vector3
    static func cross(_ lhs: Vector3, _ rhs: Vector3) -> Vector3

    static func distance(_ lhs: Vector2, _ rhs: Vector2) -> Scalar
    static func distance(_ lhs: Vector3, _ rhs: Vector3) -> Scalar
    static func distance(_ lhs: Vector4, _ rhs: Vector4) -> Scalar

    static func distance²(_ lhs: Vector2, _ rhs: Vector2) -> Scalar
    static func distance²(_ lhs: Vector3, _ rhs: Vector3) -> Scalar
    static func distance²(_ lhs: Vector4, _ rhs: Vector4) -> Scalar

    static func dot(_ lhs: Vector2, _ rhs: Vector2) -> Scalar
    static func dot(_ lhs: Vector3, _ rhs: Vector3) -> Scalar
    static func dot(_ lhs: Vector4, _ rhs: Vector4) -> Scalar

    /// - Returns: A boolean value indicating wheather given vectors are co-directional.
    ///
    /// - Note: Two zero vectors are not co-directional.
    static func isCoDirectional(_ lhs: Vector2, _ rhs: Vector2) -> Bool
    /// - Returns: A boolean value indicating wheather given vectors are co-directional.
    ///
    /// - Note: Two zero vectors are not co-directional.
    static func isCoDirectional(_ lhs: Vector3, _ rhs: Vector3) -> Bool
    /// - Returns: A boolean value indicating wheather given vectors are co-directional.
    ///
    /// - Note: Two zero vectors are not co-directional.
    static func isCoDirectional(_ lhs: Vector4, _ rhs: Vector4) -> Bool

    /// - Returns: A boolean value indicating wheather given vectors are inequal.
    static func isInequal(_ lhs: Vector2, _ rhs: Vector2) -> Bool
    /// - Returns: A boolean value indicating wheather given vectors are inequal.
    static func isInequal(_ lhs: Vector3, _ rhs: Vector3) -> Bool
    /// - Returns: A boolean value indicating wheather given vectors are inequal.
    static func isInequal(_ lhs: Vector4, _ rhs: Vector4) -> Bool
    /// - Returns: A boolean value indicating wheather given quaternions are inequal.
    static func isInequal(_ lhs: Quaternion, _ rhs: Quaternion) -> Bool
    /// - Returns: A boolean value indicating wheather given matrices are inequal.
    static func isInequal(_ lhs: Matrix2x2, _ rhs: Matrix2x2) -> Bool
    /// - Returns: A boolean value indicating wheather given matrices are inequal.
    static func isInequal(_ lhs: Matrix3x3, _ rhs: Matrix3x3) -> Bool
    /// - Returns: A boolean value indicating wheather given matrices are inequal.
    static func isInequal(_ lhs: Matrix4x4, _ rhs: Matrix4x4) -> Bool

    /// - Returns: A boolean value indicating wheather given vectors are equal.
    static func isEqual(_ lhs: Vector2, _ rhs: Vector2) -> Bool
    /// - Returns: A boolean value indicating wheather given vectors are equal.
    static func isEqual(_ lhs: Vector3, _ rhs: Vector3) -> Bool
    /// - Returns: A boolean value indicating wheather given vectors are equal.
    static func isEqual(_ lhs: Vector4, _ rhs: Vector4) -> Bool
    /// - Returns: A boolean value indicating wheather given quaternions are equal.
    static func isEqual(_ lhs: Quaternion, _ rhs: Quaternion) -> Bool
    /// - Returns: A boolean value indicating wheather given matrices are equal.
    static func isEqual(_ lhs: Matrix2x2, _ rhs: Matrix2x2) -> Bool
    /// - Returns: A boolean value indicating wheather given matrices are equal.
    static func isEqual(_ lhs: Matrix3x3, _ rhs: Matrix3x3) -> Bool
    /// - Returns: A boolean value indicating wheather given matrices are equal.
    static func isEqual(_ lhs: Matrix4x4, _ rhs: Matrix4x4) -> Bool

    /// - Returns: A boolean value indicating wheather given vector is numerically inequal to zero vector.
    static func isNonzero(_ v: Vector2) -> Bool
    /// - Returns: A boolean value indicating wheather given vector is numerically inequal to zero vector.
    static func isNonzero(_ v: Vector3) -> Bool
    /// - Returns: A boolean value indicating wheather given vector is numerically inequal to zero vector.
    static func isNonzero(_ v: Vector4) -> Bool
    /// - Returns: A boolean value indicating wheather given quaternion is numerically inequal to zero quaternion.
    static func isNonzero(_ q: Quaternion) -> Bool
    /// - Returns: A boolean value indicating wheather given matrix is numerically inequal to zero matrix.
    static func isNonzero(_ m: Matrix2x2) -> Bool
    /// - Returns: A boolean value indicating wheather given matrix is numerically inequal to zero matrix.
    static func isNonzero(_ m: Matrix3x3) -> Bool
    /// - Returns: A boolean value indicating wheather given matrix is numerically inequal to zero matrix.
    static func isNonzero(_ m: Matrix4x4) -> Bool

    /// - Returns: A boolean value indicating wheather given vector is numerically equal to zero vector.
    static func isZero(_ v: Vector2) -> Bool
    /// - Returns: A boolean value indicating wheather given vector is numerically equal to zero vector.
    static func isZero(_ v: Vector3) -> Bool
    /// - Returns: A boolean value indicating wheather given vector is numerically equal to zero vector.
    static func isZero(_ v: Vector4) -> Bool
    /// - Returns: A boolean value indicating wheather given vector is numerically equal to zero quaternion.
    static func isZero(_ q: Quaternion) -> Bool
    /// - Returns: A boolean value indicating wheather given matrix is numerically equal to zero matrix.
    static func isZero(_ m: Matrix2x2) -> Bool
    /// - Returns: A boolean value indicating wheather given matrix is numerically equal to zero matrix.
    static func isZero(_ m: Matrix3x3) -> Bool
    /// - Returns: A boolean value indicating wheather given matrix is numerically equal to zero matrix.
    static func isZero(_ m: Matrix4x4) -> Bool

    static func length(_ v: Vector2) -> Scalar
    static func length(_ v: Vector3) -> Scalar
    static func length(_ v: Vector4) -> Scalar

    static func length²(_ v: Vector2) -> Scalar
    static func length²(_ v: Vector3) -> Scalar
    static func length²(_ v: Vector4) -> Scalar

    /// - Returns: Leading 2 elements of given vector.
    static func make2(_ v: Vector3) -> Vector2
    /// - Returns: Leading 2 elements of given vector.
    static func make2(_ v: Vector4) -> Vector2
    /// - Returns: Left top 2×2 submatrix.
    static func make2(_ m: Matrix3x3) -> Matrix2x2
    /// - Returns: Left top 2×2 submatrix.
    static func make2(_ m: Matrix4x4) -> Matrix2x2

    /// - Returns: Given vector extended with zeros.
    static func make3(_ v: Vector2) -> Vector3
    /// - Returns: Leading 3 elements of given vector.
    static func make3(_ v: Vector4) -> Vector3
    /// - Returns: Given matrix extended with corresponding elements of the identity matrix.
    static func make3(_ m: Matrix2x2) -> Matrix3x3
    /// - Returns: Left top 3×3 submatrix.
    static func make3(_ m: Matrix4x4) -> Matrix3x3

    /// - Returns: Given vector extended with zeros.
    static func make4(_ v: Vector2) -> Vector4
    /// - Returns: Given vector extended with zeros.
    static func make4(_ v: Vector3) -> Vector4
    /// - Returns: Given matrix extended with corresponding elements of the identity matrix.
    static func make4(_ m: Matrix2x2) -> Matrix4x4
    /// - Returns: Given matrix extended with corresponding elements of the identity matrix.
    static func make4(_ m: Matrix3x3) -> Matrix4x4

    /// - Returns: Maximum element in the receiver.
    static func max(_ m: Matrix2x2) -> Scalar
    /// - Returns: Maximum element in the receiver.
    static func max(_ m: Matrix3x3) -> Scalar
    /// - Returns: Maximum element in the receiver.
    static func max(_ m: Matrix4x4) -> Scalar

    static func max(_ lhs: Vector2, _ rhs: Vector2) -> Vector2
    static func max(_ lhs: Vector3, _ rhs: Vector3) -> Vector3
    static func max(_ lhs: Vector4, _ rhs: Vector4) -> Vector4

    /// - Returns: Minimum element in the receiver.
    static func min(_ m: Matrix2x2) -> Scalar
    /// - Returns: Minimum element in the receiver.
    static func min(_ m: Matrix3x3) -> Scalar
    /// - Returns: Minimum element in the receiver.
    static func min(_ m: Matrix4x4) -> Scalar

    static func min(_ lhs: Vector2, _ rhs: Vector2) -> Vector2
    static func min(_ lhs: Vector3, _ rhs: Vector3) -> Vector3
    static func min(_ lhs: Vector4, _ rhs: Vector4) -> Vector4

    static func mix(_ lhs: Scalar, _ rhs: Scalar, t: Scalar) -> Scalar
    static func mix(_ lhs: Vector2, _ rhs: Vector2, t: Vector2) -> Vector2
    static func mix(_ lhs: Vector2, _ rhs: Vector2, t: Scalar) -> Vector2
    static func mix(_ lhs: Vector3, _ rhs: Vector3, t: Vector3) -> Vector3
    static func mix(_ lhs: Vector3, _ rhs: Vector3, t: Scalar) -> Vector3
    static func mix(_ lhs: Vector4, _ rhs: Vector4, t: Vector4) -> Vector4
    static func mix(_ lhs: Vector4, _ rhs: Vector4, t: Scalar) -> Vector4
    static func mix(_ lhs: Matrix2x2, _ rhs: Matrix2x2, t: Scalar) -> Matrix2x2
    static func mix(_ lhs: Matrix3x3, _ rhs: Matrix3x3, t: Scalar) -> Matrix3x3
    static func mix(_ lhs: Matrix4x4, _ rhs: Matrix4x4, t: Scalar) -> Matrix4x4

    static func normalize(_ v: Vector2) -> Vector2
    static func normalize(_ v: Vector3) -> Vector3
    static func normalize(_ v: Vector4) -> Vector4

    static func recip(_ x: Scalar) -> Scalar
    static func recip(_ v: Vector2) -> Vector2
    static func recip(_ v: Vector3) -> Vector3
    static func recip(_ v: Vector4) -> Vector4

    static func rsqrt(_ x: Scalar) -> Scalar
    static func rsqrt(_ v: Vector2) -> Vector2
    static func rsqrt(_ v: Vector3) -> Vector3
    static func rsqrt(_ v: Vector4) -> Vector4

    /// - Returns: Normalized vector or *nil* whether *v* is nondegenerate.
    static func safeNormalize(_ v: Vector2) -> Vector2?
    /// - Returns: Normalized vector or *nil* whether *v* is nondegenerate.
    static func safeNormalize(_ v: Vector3) -> Vector3?
    /// - Returns: Normalized vector or *nil* whether *v* is nondegenerate.
    static func safeNormalize(_ v: Vector4) -> Vector4?

    static func sin(_ x: Scalar) -> Scalar
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    static func sin(_ v: Vector2) -> Vector2
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    static func sin(_ v: Vector3) -> Vector3
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    static func sin(_ v: Vector4) -> Vector4

    /// - Returns: Both sine and cosine of given angle.
    static func sincos(_ angle: Scalar) -> (sin: Scalar, cos: Scalar)

    static func sinpi(_ x: Scalar) -> Scalar
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    static func sinpi(_ v: Vector2) -> Vector2
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    static func sinpi(_ v: Vector3) -> Vector3
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    static func sinpi(_ v: Vector4) -> Vector4

    /// - Returns A spherical linearly interpolated value along the shortest arc between two vectors.
    static func slerp(_ lhs: Vector2, _ rhs: Vector2, t: Scalar) -> Vector2
    /// - Returns A spherical linearly interpolated value along the shortest arc between two vectors.
    static func slerp(_ lhs: Vector3, _ rhs: Vector3, t: Scalar) -> Vector3
    /// - Returns A spherical linearly interpolated value along the shortest arc between two quaternions.
    static func slerp(_ lhs: Quaternion, _ rhs: Quaternion, t: Scalar) -> Quaternion

    /// - Returns A spherical linearly interpolated value along the longest arc between two vectors.
    static func slerp_longest(_ lhs: Vector2, _ rhs: Vector2, t: Scalar) -> Vector2
    /// - Returns A spherical linearly interpolated value along the longest arc between two vectors.
    static func slerp_longest(_ lhs: Vector3, _ rhs: Vector3, t: Scalar) -> Vector3
    /// - Returns A spherical linearly interpolated value along the longest arc between two quaternions.
    static func slerp_longest(_ lhs: Quaternion, _ rhs: Quaternion, t: Scalar) -> Quaternion

    static func tan(_ x: Scalar) -> Scalar
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    static func tan(_ v: Vector2) -> Vector2
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    static func tan(_ v: Vector3) -> Vector3
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    static func tan(_ v: Vector4) -> Vector4

    static func tanpi(_ x: Scalar) -> Scalar
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    static func tanpi(_ v: Vector2) -> Vector2
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    static func tanpi(_ v: Vector3) -> Vector3
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    static func tanpi(_ v: Vector4) -> Vector4

}



// MARK: - KvMathFloatScope

public struct KvMathFloatScope : KvMathScope {

    public typealias Scalar = Float

    public typealias Quaternion = simd_quatf

    public typealias Vector2 = simd_float2
    public typealias Vector3 = simd_float3
    public typealias Vector4 = simd_float4

    public typealias Matrix2x2 = simd_float2x2
    public typealias Matrix3x3 = simd_float3x3
    public typealias Matrix4x4 = simd_float4x4


    // MARK: No initialization

    private init() { fatalError() }


    // MARK: Operations

    @inlinable public static func abs(_ v: Vector2) -> Vector2 { simd_abs(v) }

    @inlinable public static func abs(_ v: Vector3) -> Vector3 { simd_abs(v) }

    @inlinable public static func abs(_ v: Vector4) -> Vector4 { simd_abs(v) }

    @inlinable public static func abs(_ v: Matrix2x2) -> Matrix2x2 { .init(abs(v[0]), abs(v[1])) }

    @inlinable public static func abs(_ v: Matrix3x3) -> Matrix3x3 { .init(abs(v[0]), abs(v[1]), abs(v[2])) }

    @inlinable public static func abs(_ v: Matrix4x4) -> Matrix4x4 { .init(abs(v[0]), abs(v[1]), abs(v[2]), abs(v[3])) }


    @inlinable public static func acos(_ x: Scalar) -> Scalar { simd.acos(x) }

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    @inlinable public static func acos(_ v: Vector2) -> Vector2 { simd.acos(v) }

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    @inlinable public static func acos(_ v: Vector3) -> Vector3 { simd.acos(v) }

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    @inlinable public static func acos(_ v: Vector4) -> Vector4 { simd.acos(v) }


    @inlinable public static func asin(_ x: Scalar) -> Scalar { simd.asin(x) }

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    @inlinable public static func asin(_ v: Vector2) -> Vector2 { simd.asin(v) }

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    @inlinable public static func asin(_ v: Vector3) -> Vector3 { simd.asin(v) }

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    @inlinable public static func asin(_ v: Vector4) -> Vector4 { simd.asin(v) }


    @inlinable public static func atan(_ x: Scalar) -> Scalar { simd.atan(x) }

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    @inlinable public static func atan(_ v: Vector2) -> Vector2 { simd.atan(v) }

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    @inlinable public static func atan(_ v: Vector3) -> Vector3 { simd.atan(v) }

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    @inlinable public static func atan(_ v: Vector4) -> Vector4 { simd.atan(v) }


    @inlinable public static func atan2(_ x: Scalar, _ y: Scalar) -> Scalar { simd.atan2(x, y) }

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    @inlinable public static func atan2(_ x: Vector2, _ y: Vector2) -> Vector2 { simd.atan2(x, y) }

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    @inlinable public static func atan2(_ x: Vector3, _ y: Vector3) -> Vector3 { simd.atan2(x, y) }

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    @inlinable public static func atan2(_ x: Vector4, _ y: Vector4) -> Vector4 { simd.atan2(x, y) }


    @inlinable public static func cos(_ x: Scalar) -> Scalar { simd.cos(x) }

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    @inlinable public static func cos(_ v: Vector2) -> Vector2 { simd.cos(v) }

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    @inlinable public static func cos(_ v: Vector3) -> Vector3 { simd.cos(v) }

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    @inlinable public static func cos(_ v: Vector4) -> Vector4 { simd.cos(v) }


    @inlinable public static func cospi(_ x: Scalar) -> Scalar { __cospif(x) }

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    @inlinable public static func cospi(_ v: Vector2) -> Vector2 { simd.cospi(v) }

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    @inlinable public static func cospi(_ v: Vector3) -> Vector3 { simd.cospi(v) }

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    @inlinable public static func cospi(_ v: Vector4) -> Vector4 { simd.cospi(v) }


    @inlinable public static func cross(_ lhs: Vector2, _ rhs: Vector2) -> Vector3 { simd_cross(lhs, rhs) }

    @inlinable public static func cross(_ lhs: Vector3, _ rhs: Vector3) -> Vector3 { simd_cross(lhs, rhs) }


    @inlinable public static func distance(_ lhs: Vector2, _ rhs: Vector2) -> Scalar { simd_distance(lhs, rhs) }

    @inlinable public static func distance(_ lhs: Vector3, _ rhs: Vector3) -> Scalar { simd_distance(lhs, rhs) }

    @inlinable public static func distance(_ lhs: Vector4, _ rhs: Vector4) -> Scalar { simd_distance(lhs, rhs) }


    @inlinable public static func distance²(_ lhs: Vector2, _ rhs: Vector2) -> Scalar { simd_distance_squared(lhs, rhs) }

    @inlinable public static func distance²(_ lhs: Vector3, _ rhs: Vector3) -> Scalar { simd_distance_squared(lhs, rhs) }

    @inlinable public static func distance²(_ lhs: Vector4, _ rhs: Vector4) -> Scalar { simd_distance_squared(lhs, rhs) }


    @inlinable public static func dot(_ lhs: Vector2, _ rhs: Vector2) -> Scalar { simd.dot(lhs, rhs) }

    @inlinable public static func dot(_ lhs: Vector3, _ rhs: Vector3) -> Scalar { simd.dot(lhs, rhs) }

    @inlinable public static func dot(_ lhs: Vector4, _ rhs: Vector4) -> Scalar { simd.dot(lhs, rhs) }


    /// - Returns: A boolean value indicating wheather given vectors are co-directional.
    ///
    /// - Note: Two zero vectors are not co-directional.
    @inlinable
    public static func isCoDirectional(_ lhs: Vector2, _ rhs: Vector2) -> Bool {
        KvIs(lhs.x * rhs.y, equalTo: lhs.y * rhs.x)
        && KvIsPositive(dot(lhs, rhs))
    }

    /// - Returns: A boolean value indicating wheather given vectors are co-directional.
    ///
    /// - Note: Two zero vectors are not co-directional.
    @inlinable
    public static func isCoDirectional(_ lhs: Vector3, _ rhs: Vector3) -> Bool {
        KvIs(lhs.x * rhs.y, equalTo: lhs.y * rhs.x)
        && KvIs(lhs.y * rhs.z, equalTo: lhs.z * rhs.y)
        && KvIsPositive(simd_dot(lhs, rhs))
    }

    /// - Returns: A boolean value indicating wheather given vectors are co-directional.
    ///
    /// - Note: Two zero vectors are not co-directional.
    @inlinable
    public static func isCoDirectional(_ lhs: Vector4, _ rhs: Vector4) -> Bool {
        KvIs(lhs.x * rhs.y, equalTo: lhs.y * rhs.x)
        && KvIs(lhs.y * rhs.z, equalTo: lhs.z * rhs.y)
        && KvIs(lhs.z * rhs.w, equalTo: lhs.w * rhs.z)
        && KvIsPositive(simd_dot(lhs, rhs))
    }


    /// - Returns: A boolean value indicating wheather given vectors are inequal.
    @inlinable public static func isInequal(_ lhs: Vector2, _ rhs: Vector2) -> Bool { isNonzero(lhs - rhs) }

    /// - Returns: A boolean value indicating wheather given vectors are inequal.
    @inlinable public static func isInequal(_ lhs: Vector3, _ rhs: Vector3) -> Bool { isNonzero(lhs - rhs) }

    /// - Returns: A boolean value indicating wheather given vectors are inequal.
    @inlinable public static func isInequal(_ lhs: Vector4, _ rhs: Vector4) -> Bool { isNonzero(lhs - rhs) }

    /// - Returns: A boolean value indicating wheather given quaternions are inequal.
    @inlinable public static func isInequal(_ lhs: Quaternion, _ rhs: Quaternion) -> Bool { isInequal(lhs.vector, rhs.vector) }

    /// - Returns: A boolean value indicating wheather given matrices are inequal.
    @inlinable public static func isInequal(_ lhs: Matrix2x2, _ rhs: Matrix2x2) -> Bool { isNonzero(lhs - rhs) }

    /// - Returns: A boolean value indicating wheather given matrices are inequal.
    @inlinable public static func isInequal(_ lhs: Matrix3x3, _ rhs: Matrix3x3) -> Bool { isNonzero(lhs - rhs) }

    /// - Returns: A boolean value indicating wheather given matrices are inequal.
    @inlinable public static func isInequal(_ lhs: Matrix4x4, _ rhs: Matrix4x4) -> Bool { isNonzero(lhs - rhs) }


    /// - Returns: A boolean value indicating wheather given vectors are equal.
    @inlinable public static func isEqual(_ lhs: Vector2, _ rhs: Vector2) -> Bool { isZero(lhs - rhs) }

    /// - Returns: A boolean value indicating wheather given vectors are equal.
    @inlinable public static func isEqual(_ lhs: Vector3, _ rhs: Vector3) -> Bool { isZero(lhs - rhs) }

    /// - Returns: A boolean value indicating wheather given vectors are equal.
    @inlinable public static func isEqual(_ lhs: Vector4, _ rhs: Vector4) -> Bool { isZero(lhs - rhs) }

    /// - Returns: A boolean value indicating wheather given quaternions are equal.
    @inlinable public static func isEqual(_ lhs: Quaternion, _ rhs: Quaternion) -> Bool { isEqual(lhs.vector, rhs.vector) }

    /// - Returns: A boolean value indicating wheather given matrices are equal.
    @inlinable public static func isEqual(_ lhs: Matrix2x2, _ rhs: Matrix2x2) -> Bool { isZero(lhs - rhs) }

    /// - Returns: A boolean value indicating wheather given matrices are equal.
    @inlinable public static func isEqual(_ lhs: Matrix3x3, _ rhs: Matrix3x3) -> Bool { isZero(lhs - rhs) }

    /// - Returns: A boolean value indicating wheather given matrices are equal.
    @inlinable public static func isEqual(_ lhs: Matrix4x4, _ rhs: Matrix4x4) -> Bool { isZero(lhs - rhs) }


    /// - Returns: A boolean value indicating wheather given vector is numerically inequal to zero.
    @inlinable public static func isNonzero(_ v: Vector2) -> Bool { KvIsNonzero(abs(v).max()) }

    /// - Returns: A boolean value indicating wheather given vector is numerically inequal to zero.
    @inlinable public static func isNonzero(_ v: Vector3) -> Bool { KvIsNonzero(abs(v).max()) }

    /// - Returns: A boolean value indicating wheather given vector is numerically inequal to zero.
    @inlinable public static func isNonzero(_ v: Vector4) -> Bool { KvIsNonzero(abs(v).max()) }

    /// - Returns: A boolean value indicating wheather given quaternion is numerically inequal to zero quaternion.
    @inlinable public static func isNonzero(_ q: Quaternion) -> Bool { isNonzero(q.vector) }

    /// - Returns: A boolean value indicating wheather given matrix is numerically inequal to zero matrix.
    @inlinable public static func isNonzero(_ m: Matrix2x2) -> Bool { KvIsNonzero(max(abs(m))) }

    /// - Returns: A boolean value indicating wheather given matrix is numerically inequal to zero matrix.
    @inlinable public static func isNonzero(_ m: Matrix3x3) -> Bool { KvIsNonzero(max(abs(m))) }

    /// - Returns: A boolean value indicating wheather given matrix is numerically inequal to zero matrix.
    @inlinable public static func isNonzero(_ m: Matrix4x4) -> Bool { KvIsNonzero(max(abs(m))) }


    /// - Returns: A boolean value indicating wheather given vector is numerically equal to zero.
    @inlinable public static func isZero(_ v: Vector2) -> Bool { KvIsZero(abs(v).max()) }

    /// - Returns: A boolean value indicating wheather given vector is numerically equal to zero.
    @inlinable public static func isZero(_ v: Vector3) -> Bool { KvIsZero(abs(v).max()) }

    /// - Returns: A boolean value indicating wheather given vector is numerically equal to zero.
    @inlinable public static func isZero(_ v: Vector4) -> Bool { KvIsZero(abs(v).max()) }

    /// - Returns: A boolean value indicating wheather given vector is numerically equal to zero quaternion.
    @inlinable public static func isZero(_ q: Quaternion) -> Bool { isZero(q.vector) }

    /// - Returns: A boolean value indicating wheather given matrix is numerically equal to zero matrix.
    @inlinable public static func isZero(_ m: Matrix2x2) -> Bool { KvIsZero(max(abs(m))) }

    /// - Returns: A boolean value indicating wheather given matrix is numerically equal to zero matrix.
    @inlinable public static func isZero(_ m: Matrix3x3) -> Bool { KvIsZero(max(abs(m))) }

    /// - Returns: A boolean value indicating wheather given matrix is numerically equal to zero matrix.
    @inlinable public static func isZero(_ m: Matrix4x4) -> Bool { KvIsZero(max(abs(m))) }


    @inlinable public static func length(_ v: Vector2) -> Scalar { simd_length(v) }

    @inlinable public static func length(_ v: Vector3) -> Scalar { simd_length(v) }

    @inlinable public static func length(_ v: Vector4) -> Scalar { simd_length(v) }


    @inlinable public static func length²(_ v: Vector2) -> Scalar { simd_length_squared(v) }

    @inlinable public static func length²(_ v: Vector3) -> Scalar { simd_length_squared(v) }

    @inlinable public static func length²(_ v: Vector4) -> Scalar { simd_length_squared(v) }


    /// - Returns: Leading 2 elements of given vector.
    @inlinable
    public static func make2(_ v: Vector3) -> Vector2 { simd_make_float2(v) }

    /// - Returns: Leading 2 elements of given vector.
    @inlinable
    public static func make2(_ v: Vector4) -> Vector2 { simd_make_float2(v) }

    /// - Returns: Left top 2×2 submatrix.
    @inlinable
    public static func make2(_ m: Matrix3x3) -> Matrix2x2 {
        Matrix2x2(make2(m[0]),
                  make2(m[1]))
    }

    /// - Returns: Left top 2×2 submatrix.
    @inlinable
    public static func make2(_ m: Matrix4x4) -> Matrix2x2 {
        Matrix2x2(make2(m[0]),
                  make2(m[1]))
    }


    /// - Returns: Given vector extended with zeros.
    @inlinable
    public static func make3(_ v: Vector2) -> Vector3 { simd_make_float3(v) }

    /// - Returns: Leading 3 elements of given vector.
    @inlinable
    public static func make3(_ v: Vector4) -> Vector3 { simd_make_float3(v) }

    /// - Returns: Given matrix extended with corresponding elements of the identity matrix.
    @inlinable
    public static func make3(_ m: Matrix2x2) -> Matrix3x3 {
        Matrix3x3(make3(m[0]),
                  make3(m[1]),
                  Matrix3x3.Column.unitZ)
    }

    /// - Returns: Left top 3×3 submatrix.
    @inlinable
    public static func make3(_ m: Matrix4x4) -> Matrix3x3 {
        Matrix3x3(make3(m[0]),
                  make3(m[1]),
                  make3(m[2]))
    }


    /// - Returns: Given vector extended with zeros.
    @inlinable
    public static func make4(_ v: Vector2) -> Vector4 { simd_make_float4(v) }

    /// - Returns: Given vector extended with zeros.
    @inlinable
    public static func make4(_ v: Vector3) -> Vector4 { simd_make_float4(v) }

    /// - Returns: Given matrix extended with corresponding elements of the identity matrix.
    @inlinable
    public static func make4(_ m: Matrix2x2) -> Matrix4x4 {
        Matrix4x4(make4(m[0]),
                  make4(m[1]),
                  Matrix4x4.Column.unitZ,
                  Matrix4x4.Column.unitW)
    }

    /// - Returns: Given matrix extended with corresponding elements of the identity matrix.
    @inlinable
    public static func make4(_ m: Matrix3x3) -> Matrix4x4 {
        Matrix4x4(make4(m[0]),
                  make4(m[1]),
                  make4(m[2]),
                  Matrix4x4.Column.unitW)
    }


    /// - Returns: Maximum element in the receiver.
    @inlinable public static func max(_ m: Matrix2x2) -> Scalar { Swift.max(m[0].max(), m[1].max()) }

    /// - Returns: Maximum element in the receiver.
    @inlinable public static func max(_ m: Matrix3x3) -> Scalar { Swift.max(m[0].max(), m[1].max(), m[2].max()) }

    /// - Returns: Maximum element in the receiver.
    @inlinable public static func max(_ m: Matrix4x4) -> Scalar { Swift.max(m[0].max(), m[1].max(), m[2].max(), m[3].max()) }


    @inlinable public static func max(_ lhs: Vector2, _ rhs: Vector2) -> Vector2 { simd_max(lhs, rhs) }

    @inlinable public static func max(_ lhs: Vector3, _ rhs: Vector3) -> Vector3 { simd_max(lhs, rhs) }

    @inlinable public static func max(_ lhs: Vector4, _ rhs: Vector4) -> Vector4 { simd_max(lhs, rhs) }


    /// - Returns: Minimum element in the receiver.
    @inlinable public static func min(_ m: Matrix2x2) -> Scalar { Swift.min(m[0].min(), m[1].min()) }

    /// - Returns: Minimum element in the receiver.
    @inlinable public static func min(_ m: Matrix3x3) -> Scalar { Swift.min(m[0].min(), m[1].min(), m[2].min()) }

    /// - Returns: Minimum element in the receiver.
    @inlinable public static func min(_ m: Matrix4x4) -> Scalar { Swift.min(m[0].min(), m[1].min(), m[2].min(), m[3].min()) }


    @inlinable public static func min(_ lhs: Vector2, _ rhs: Vector2) -> Vector2 { simd_min(lhs, rhs) }

    @inlinable public static func min(_ lhs: Vector3, _ rhs: Vector3) -> Vector3 { simd_min(lhs, rhs) }

    @inlinable public static func min(_ lhs: Vector4, _ rhs: Vector4) -> Vector4 { simd_min(lhs, rhs) }


    @inlinable public static func mix(_ lhs: Scalar, _ rhs: Scalar, t: Scalar) -> Scalar { simd_mix(lhs, rhs, t) }

    @inlinable public static func mix(_ lhs: Vector2, _ rhs: Vector2, t: Vector2) -> Vector2 { simd_mix(lhs, rhs, t) }

    @inlinable public static func mix(_ lhs: Vector2, _ rhs: Vector2, t: Scalar) -> Vector2 { simd.mix(lhs, rhs, t: t) }

    @inlinable public static func mix(_ lhs: Vector3, _ rhs: Vector3, t: Vector3) -> Vector3 { simd_mix(lhs, rhs, t) }

    @inlinable public static func mix(_ lhs: Vector3, _ rhs: Vector3, t: Scalar) -> Vector3 { simd.mix(lhs, rhs, t: t) }

    @inlinable public static func mix(_ lhs: Vector4, _ rhs: Vector4, t: Vector4) -> Vector4 { simd_mix(lhs, rhs, t) }

    @inlinable public static func mix(_ lhs: Vector4, _ rhs: Vector4, t: Scalar) -> Vector4 { simd.mix(lhs, rhs, t: t) }

    @inlinable public static func mix(_ lhs: Matrix2x2, _ rhs: Matrix2x2, t: Scalar) -> Matrix2x2 { simd_linear_combination(1 - t, lhs, t, rhs) }

    @inlinable public static func mix(_ lhs: Matrix3x3, _ rhs: Matrix3x3, t: Scalar) -> Matrix3x3 { simd_linear_combination(1 - t, lhs, t, rhs) }

    @inlinable public static func mix(_ lhs: Matrix4x4, _ rhs: Matrix4x4, t: Scalar) -> Matrix4x4 { simd_linear_combination(1 - t, lhs, t, rhs) }


    @inlinable public static func normalize(_ v: Vector2) -> Vector2 { simd_normalize(v) }

    @inlinable public static func normalize(_ v: Vector3) -> Vector3 { simd_normalize(v) }

    @inlinable public static func normalize(_ v: Vector4) -> Vector4 { simd_normalize(v) }


    @inlinable public static func recip(_ x: Scalar) -> Scalar { simd_recip(x) }

    @inlinable public static func recip(_ v: Vector2) -> Vector2 { simd_recip(v) }

    @inlinable public static func recip(_ v: Vector3) -> Vector3 { simd_recip(v) }

    @inlinable public static func recip(_ v: Vector4) -> Vector4 { simd_recip(v) }


    @inlinable public static func rsqrt(_ x: Scalar) -> Scalar { simd_rsqrt(x) }

    @inlinable public static func rsqrt(_ v: Vector2) -> Vector2 { simd_rsqrt(v) }

    @inlinable public static func rsqrt(_ v: Vector3) -> Vector3 { simd_rsqrt(v) }

    @inlinable public static func rsqrt(_ v: Vector4) -> Vector4 { simd_rsqrt(v) }


    /// - Returns: Normalized vector or *nil* whether *v* is nondegenerate.
    @inlinable
    public static func safeNormalize(_ v: Vector2) -> Vector2? {
        guard isZero(v) else { return nil }
        return normalize(v)
    }

    /// - Returns: Normalized vector or *nil* whether *v* is nondegenerate.
    @inlinable
    public static func safeNormalize(_ v: Vector3) -> Vector3? {
        guard isZero(v) else { return nil }
        return normalize(v)
    }

    /// - Returns: Normalized vector or *nil* whether *v* is nondegenerate.
    @inlinable
    public static func safeNormalize(_ v: Vector4) -> Vector4? {
        guard isZero(v) else { return nil }
        return normalize(v)
    }


    @inlinable public static func sin(_ x: Scalar) -> Scalar { simd.sin(x) }

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    @inlinable public static func sin(_ v: Vector2) -> Vector2 { simd.sin(v) }

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    @inlinable public static func sin(_ v: Vector3) -> Vector3 { simd.sin(v) }

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    @inlinable public static func sin(_ v: Vector4) -> Vector4 { simd.sin(v) }


    /// - Returns: Both sine and cosine of given angle.
    @inlinable public static func sincos(_ angle: Scalar) -> (sin: Scalar, cos: Scalar) { (sin(angle), cos(angle)) }


    @inlinable public static func sinpi(_ x: Scalar) -> Scalar { sin(x * .pi) }

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    @inlinable public static func sinpi(_ v: Vector2) -> Vector2 { simd.sinpi(v) }

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    @inlinable public static func sinpi(_ v: Vector3) -> Vector3 { simd.sinpi(v) }

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    @inlinable public static func sinpi(_ v: Vector4) -> Vector4 { simd.sinpi(v) }


    /// - Returns A spherical linearly interpolated value along the shortest arc between two vectors.
    @inlinable
    public static func slerp(_ lhs: Vector2, _ rhs: Vector2, t: Scalar) -> Vector2 {
        make2(slerp(make3(lhs), make3(rhs), t: t))
    }

    /// - Returns A spherical linearly interpolated value along the shortest arc between two vectors.
    @inlinable
    public static func slerp(_ lhs: Vector3, _ rhs: Vector3, t: Scalar) -> Vector3 {
        let q = Quaternion(from: lhs, to: rhs)

        return Quaternion(angle: t * q.angle, axis: q.axis).act(lhs)
    }

    /// - Returns A spherical linearly interpolated value along the shortest arc between two quaternions.
    @inlinable public static func slerp(_ lhs: Quaternion, _ rhs: Quaternion, t: Scalar) -> Quaternion { simd_slerp(lhs, rhs, t) }


    /// - Returns A spherical linearly interpolated value along the longest arc between two vectors.
    @inlinable
    public static func slerp_longest(_ lhs: Vector2, _ rhs: Vector2, t: Scalar) -> Vector2 {
        make2(slerp_longest(make3(lhs), make3(rhs), t: t))
    }

    /// - Returns A spherical linearly interpolated value along the longest arc between two vectors.
    @inlinable
    public static func slerp_longest(_ lhs: Vector3, _ rhs: Vector3, t: Scalar) -> Vector3 {
        let q = Quaternion(from: lhs, to: rhs)

        return Quaternion(angle: t * (q.angle - 2 * Scalar.pi), axis: q.axis).act(lhs)
    }

    /// - Returns A spherical linearly interpolated value along the longest arc between two quaternions.
    @inlinable public static func slerp_longest(_ lhs: Quaternion, _ rhs: Quaternion, t: Scalar) -> Quaternion { simd_slerp_longest(lhs, rhs, t) }


    @inlinable public static func tan(_ x: Scalar) -> Scalar { simd.tan(x) }

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    @inlinable public static func tan(_ v: Vector2) -> Vector2 { simd.tan(v) }

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    @inlinable public static func tan(_ v: Vector3) -> Vector3 { simd.tan(v) }

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    @inlinable public static func tan(_ v: Vector4) -> Vector4 { simd.tan(v) }


    @inlinable public static func tanpi(_ x: Scalar) -> Scalar { tan(x * .pi) }

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    @inlinable public static func tanpi(_ v: Vector2) -> Vector2 { simd.tanpi(v) }

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    @inlinable public static func tanpi(_ v: Vector3) -> Vector3 { simd.tanpi(v) }

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    @inlinable public static func tanpi(_ v: Vector4) -> Vector4 { simd.tanpi(v) }

}



// MARK: - KvMathDoubleScope

public struct KvMathDoubleScope : KvMathScope {

    public typealias Scalar = Double

    public typealias Quaternion = simd_quatd

    public typealias Vector2 = simd_double2
    public typealias Vector3 = simd_double3
    public typealias Vector4 = simd_double4

    public typealias Matrix2x2 = simd_double2x2
    public typealias Matrix3x3 = simd_double3x3
    public typealias Matrix4x4 = simd_double4x4


    // MARK: No initialization

    private init() { fatalError() }


    // MARK: Operations

    @inlinable public static func abs(_ v: Vector2) -> Vector2 { simd_abs(v) }

    @inlinable public static func abs(_ v: Vector3) -> Vector3 { simd_abs(v) }

    @inlinable public static func abs(_ v: Vector4) -> Vector4 { simd_abs(v) }

    @inlinable public static func abs(_ v: Matrix2x2) -> Matrix2x2 { .init(abs(v[0]), abs(v[1])) }

    @inlinable public static func abs(_ v: Matrix3x3) -> Matrix3x3 { .init(abs(v[0]), abs(v[1]), abs(v[2])) }

    @inlinable public static func abs(_ v: Matrix4x4) -> Matrix4x4 { .init(abs(v[0]), abs(v[1]), abs(v[2]), abs(v[3])) }


    @inlinable public static func acos(_ x: Scalar) -> Scalar { simd.acos(x) }

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    @inlinable public static func acos(_ v: Vector2) -> Vector2 { simd.acos(v) }

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    @inlinable public static func acos(_ v: Vector3) -> Vector3 { simd.acos(v) }

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    @inlinable public static func acos(_ v: Vector4) -> Vector4 { simd.acos(v) }


    @inlinable public static func asin(_ x: Scalar) -> Scalar { simd.asin(x) }

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    @inlinable public static func asin(_ v: Vector2) -> Vector2 { simd.asin(v) }

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    @inlinable public static func asin(_ v: Vector3) -> Vector3 { simd.asin(v) }

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    @inlinable public static func asin(_ v: Vector4) -> Vector4 { simd.asin(v) }


    @inlinable public static func atan(_ x: Scalar) -> Scalar { simd.atan(x) }

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    @inlinable public static func atan(_ v: Vector2) -> Vector2 { simd.atan(v) }

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    @inlinable public static func atan(_ v: Vector3) -> Vector3 { simd.atan(v) }

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    @inlinable public static func atan(_ v: Vector4) -> Vector4 { simd.atan(v) }


    @inlinable public static func atan2(_ x: Scalar, _ y: Scalar) -> Scalar { simd.atan2(x, y) }

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    @inlinable public static func atan2(_ x: Vector2, _ y: Vector2) -> Vector2 { simd.atan2(x, y) }

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    @inlinable public static func atan2(_ x: Vector3, _ y: Vector3) -> Vector3 { simd.atan2(x, y) }

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    @inlinable public static func atan2(_ x: Vector4, _ y: Vector4) -> Vector4 { simd.atan2(x, y) }


    @inlinable public static func cos(_ x: Scalar) -> Scalar { simd.cos(x) }

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    @inlinable public static func cos(_ v: Vector2) -> Vector2 { simd.cos(v) }

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    @inlinable public static func cos(_ v: Vector3) -> Vector3 { simd.cos(v) }

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    @inlinable public static func cos(_ v: Vector4) -> Vector4 { simd.cos(v) }


    @inlinable public static func cospi(_ x: Scalar) -> Scalar { __cospi(x) }

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    @inlinable public static func cospi(_ v: Vector2) -> Vector2 { simd.cospi(v) }

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    @inlinable public static func cospi(_ v: Vector3) -> Vector3 { simd.cospi(v) }

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    @inlinable public static func cospi(_ v: Vector4) -> Vector4 { simd.cospi(v) }


    @inlinable public static func cross(_ lhs: Vector2, _ rhs: Vector2) -> Vector3 { simd_cross(lhs, rhs) }

    @inlinable public static func cross(_ lhs: Vector3, _ rhs: Vector3) -> Vector3 { simd_cross(lhs, rhs) }


    @inlinable public static func distance(_ lhs: Vector2, _ rhs: Vector2) -> Scalar { simd_distance(lhs, rhs) }

    @inlinable public static func distance(_ lhs: Vector3, _ rhs: Vector3) -> Scalar { simd_distance(lhs, rhs) }

    @inlinable public static func distance(_ lhs: Vector4, _ rhs: Vector4) -> Scalar { simd_distance(lhs, rhs) }


    @inlinable public static func distance²(_ lhs: Vector2, _ rhs: Vector2) -> Scalar { simd_distance_squared(lhs, rhs) }

    @inlinable public static func distance²(_ lhs: Vector3, _ rhs: Vector3) -> Scalar { simd_distance_squared(lhs, rhs) }

    @inlinable public static func distance²(_ lhs: Vector4, _ rhs: Vector4) -> Scalar { simd_distance_squared(lhs, rhs) }


    @inlinable public static func dot(_ lhs: Vector2, _ rhs: Vector2) -> Scalar { simd.dot(lhs, rhs) }

    @inlinable public static func dot(_ lhs: Vector3, _ rhs: Vector3) -> Scalar { simd.dot(lhs, rhs) }

    @inlinable public static func dot(_ lhs: Vector4, _ rhs: Vector4) -> Scalar { simd.dot(lhs, rhs) }


    /// - Returns: A boolean value indicating wheather given vectors are co-directional.
    ///
    /// - Note: Two zero vectors are not co-directional.
    @inlinable
    public static func isCoDirectional(_ lhs: Vector2, _ rhs: Vector2) -> Bool {
        KvIs(lhs.x * rhs.y, equalTo: lhs.y * rhs.x)
        && KvIsPositive(dot(lhs, rhs))
    }

    /// - Returns: A boolean value indicating wheather given vectors are co-directional.
    ///
    /// - Note: Two zero vectors are not co-directional.
    @inlinable
    public static func isCoDirectional(_ lhs: Vector3, _ rhs: Vector3) -> Bool {
        KvIs(lhs.x * rhs.y, equalTo: lhs.y * rhs.x)
        && KvIs(lhs.y * rhs.z, equalTo: lhs.z * rhs.y)
        && KvIsPositive(simd_dot(lhs, rhs))
    }

    /// - Returns: A boolean value indicating wheather given vectors are co-directional.
    ///
    /// - Note: Two zero vectors are not co-directional.
    @inlinable
    public static func isCoDirectional(_ lhs: Vector4, _ rhs: Vector4) -> Bool {
        KvIs(lhs.x * rhs.y, equalTo: lhs.y * rhs.x)
        && KvIs(lhs.y * rhs.z, equalTo: lhs.z * rhs.y)
        && KvIs(lhs.z * rhs.w, equalTo: lhs.w * rhs.z)
        && KvIsPositive(simd_dot(lhs, rhs))
    }


    /// - Returns: A boolean value indicating wheather given vectors are inequal.
    @inlinable public static func isInequal(_ lhs: Vector2, _ rhs: Vector2) -> Bool { isNonzero(lhs - rhs) }

    /// - Returns: A boolean value indicating wheather given vectors are inequal.
    @inlinable public static func isInequal(_ lhs: Vector3, _ rhs: Vector3) -> Bool { isNonzero(lhs - rhs) }

    /// - Returns: A boolean value indicating wheather given vectors are inequal.
    @inlinable public static func isInequal(_ lhs: Vector4, _ rhs: Vector4) -> Bool { isNonzero(lhs - rhs) }

    /// - Returns: A boolean value indicating wheather given quaternions are inequal.
    @inlinable public static func isInequal(_ lhs: Quaternion, _ rhs: Quaternion) -> Bool { isInequal(lhs.vector, rhs.vector) }

    /// - Returns: A boolean value indicating wheather given matrices are inequal.
    @inlinable public static func isInequal(_ lhs: Matrix2x2, _ rhs: Matrix2x2) -> Bool { isNonzero(lhs - rhs) }

    /// - Returns: A boolean value indicating wheather given matrices are inequal.
    @inlinable public static func isInequal(_ lhs: Matrix3x3, _ rhs: Matrix3x3) -> Bool { isNonzero(lhs - rhs) }

    /// - Returns: A boolean value indicating wheather given matrices are inequal.
    @inlinable public static func isInequal(_ lhs: Matrix4x4, _ rhs: Matrix4x4) -> Bool { isNonzero(lhs - rhs) }


    /// - Returns: A boolean value indicating wheather given vectors are equal.
    @inlinable public static func isEqual(_ lhs: Vector2, _ rhs: Vector2) -> Bool { isZero(lhs - rhs) }

    /// - Returns: A boolean value indicating wheather given vectors are equal.
    @inlinable public static func isEqual(_ lhs: Vector3, _ rhs: Vector3) -> Bool { isZero(lhs - rhs) }

    /// - Returns: A boolean value indicating wheather given vectors are equal.
    @inlinable public static func isEqual(_ lhs: Vector4, _ rhs: Vector4) -> Bool { isZero(lhs - rhs) }

    /// - Returns: A boolean value indicating wheather given quaternions are equal.
    @inlinable public static func isEqual(_ lhs: Quaternion, _ rhs: Quaternion) -> Bool { isEqual(lhs.vector, rhs.vector) }

    /// - Returns: A boolean value indicating wheather given matrices are equal.
    @inlinable public static func isEqual(_ lhs: Matrix2x2, _ rhs: Matrix2x2) -> Bool { isZero(lhs - rhs) }

    /// - Returns: A boolean value indicating wheather given matrices are equal.
    @inlinable public static func isEqual(_ lhs: Matrix3x3, _ rhs: Matrix3x3) -> Bool { isZero(lhs - rhs) }

    /// - Returns: A boolean value indicating wheather given matrices are equal.
    @inlinable public static func isEqual(_ lhs: Matrix4x4, _ rhs: Matrix4x4) -> Bool { isZero(lhs - rhs) }


    /// - Returns: A boolean value indicating wheather given vector is numerically inequal to zero.
    @inlinable public static func isNonzero(_ v: Vector2) -> Bool { KvIsNonzero(abs(v).max()) }

    /// - Returns: A boolean value indicating wheather given vector is numerically inequal to zero.
    @inlinable public static func isNonzero(_ v: Vector3) -> Bool { KvIsNonzero(abs(v).max()) }

    /// - Returns: A boolean value indicating wheather given vector is numerically inequal to zero.
    @inlinable public static func isNonzero(_ v: Vector4) -> Bool { KvIsNonzero(abs(v).max()) }

    /// - Returns: A boolean value indicating wheather given quaternion is numerically inequal to zero quaternion.
    @inlinable public static func isNonzero(_ q: Quaternion) -> Bool { isNonzero(q.vector) }

    /// - Returns: A boolean value indicating wheather given matrix is numerically inequal to zero matrix.
    @inlinable public static func isNonzero(_ m: Matrix2x2) -> Bool { KvIsNonzero(max(abs(m))) }

    /// - Returns: A boolean value indicating wheather given matrix is numerically inequal to zero matrix.
    @inlinable public static func isNonzero(_ m: Matrix3x3) -> Bool { KvIsNonzero(max(abs(m))) }

    /// - Returns: A boolean value indicating wheather given matrix is numerically inequal to zero matrix.
    @inlinable public static func isNonzero(_ m: Matrix4x4) -> Bool { KvIsNonzero(max(abs(m))) }


    /// - Returns: A boolean value indicating wheather given vector is numerically equal to zero.
    @inlinable public static func isZero(_ v: Vector2) -> Bool { KvIsZero(abs(v).max()) }

    /// - Returns: A boolean value indicating wheather given vector is numerically equal to zero.
    @inlinable public static func isZero(_ v: Vector3) -> Bool { KvIsZero(abs(v).max()) }

    /// - Returns: A boolean value indicating wheather given vector is numerically equal to zero.
    @inlinable public static func isZero(_ v: Vector4) -> Bool { KvIsZero(abs(v).max()) }

    /// - Returns: A boolean value indicating wheather given vector is numerically equal to zero quaternion.
    @inlinable public static func isZero(_ q: Quaternion) -> Bool { isZero(q.vector) }

    /// - Returns: A boolean value indicating wheather given matrix is numerically equal to zero matrix.
    @inlinable public static func isZero(_ m: Matrix2x2) -> Bool { KvIsZero(max(abs(m))) }

    /// - Returns: A boolean value indicating wheather given matrix is numerically equal to zero matrix.
    @inlinable public static func isZero(_ m: Matrix3x3) -> Bool { KvIsZero(max(abs(m))) }

    /// - Returns: A boolean value indicating wheather given matrix is numerically equal to zero matrix.
    @inlinable public static func isZero(_ m: Matrix4x4) -> Bool { KvIsZero(max(abs(m))) }


    @inlinable public static func length(_ v: Vector2) -> Scalar { simd_length(v) }

    @inlinable public static func length(_ v: Vector3) -> Scalar { simd_length(v) }

    @inlinable public static func length(_ v: Vector4) -> Scalar { simd_length(v) }


    @inlinable public static func length²(_ v: Vector2) -> Scalar { simd_length_squared(v) }

    @inlinable public static func length²(_ v: Vector3) -> Scalar { simd_length_squared(v) }

    @inlinable public static func length²(_ v: Vector4) -> Scalar { simd_length_squared(v) }


    /// - Returns: Leading 2 elements of given vector.
    @inlinable
    public static func make2(_ v: Vector3) -> Vector2 { simd_make_double2(v) }

    /// - Returns: Leading 2 elements of given vector.
    @inlinable
    public static func make2(_ v: Vector4) -> Vector2 { simd_make_double2(v) }

    /// - Returns: Left top 2×2 submatrix.
    @inlinable
    public static func make2(_ m: Matrix3x3) -> Matrix2x2 {
        Matrix2x2(make2(m[0]),
                  make2(m[1]))
    }

    /// - Returns: Left top 2×2 submatrix.
    @inlinable
    public static func make2(_ m: Matrix4x4) -> Matrix2x2 {
        Matrix2x2(make2(m[0]),
                  make2(m[1]))
    }


    /// - Returns: Given vector extended with zeros.
    @inlinable
    public static func make3(_ v: Vector2) -> Vector3 { simd_make_double3(v) }

    /// - Returns: Leading 3 elements of given vector.
    @inlinable
    public static func make3(_ v: Vector4) -> Vector3 { simd_make_double3(v) }

    /// - Returns: Given matrix extended with corresponding elements of the identity matrix.
    @inlinable
    public static func make3(_ m: Matrix2x2) -> Matrix3x3 {
        Matrix3x3(make3(m[0]),
                  make3(m[1]),
                  Matrix3x3.Column.unitZ)
    }

    /// - Returns: Left top 3×3 submatrix.
    @inlinable
    public static func make3(_ m: Matrix4x4) -> Matrix3x3 {
        Matrix3x3(make3(m[0]),
                  make3(m[1]),
                  make3(m[2]))
    }


    /// - Returns: Given vector extended with zeros.
    @inlinable
    public static func make4(_ v: Vector2) -> Vector4 { simd_make_double4(v) }

    /// - Returns: Given vector extended with zeros.
    @inlinable
    public static func make4(_ v: Vector3) -> Vector4 { simd_make_double4(v) }

    /// - Returns: Given matrix extended with corresponding elements of the identity matrix.
    @inlinable
    public static func make4(_ m: Matrix2x2) -> Matrix4x4 {
        Matrix4x4(make4(m[0]),
                  make4(m[1]),
                  Matrix4x4.Column.unitZ,
                  Matrix4x4.Column.unitW)
    }

    /// - Returns: Given matrix extended with corresponding elements of the identity matrix.
    @inlinable
    public static func make4(_ m: Matrix3x3) -> Matrix4x4 {
        Matrix4x4(make4(m[0]),
                  make4(m[1]),
                  make4(m[2]),
                  Matrix4x4.Column.unitW)
    }


    /// - Returns: Maximum element in the receiver.
    @inlinable public static func max(_ m: Matrix2x2) -> Scalar { Swift.max(m[0].max(), m[1].max()) }

    /// - Returns: Maximum element in the receiver.
    @inlinable public static func max(_ m: Matrix3x3) -> Scalar { Swift.max(m[0].max(), m[1].max(), m[2].max()) }

    /// - Returns: Maximum element in the receiver.
    @inlinable public static func max(_ m: Matrix4x4) -> Scalar { Swift.max(m[0].max(), m[1].max(), m[2].max(), m[3].max()) }


    @inlinable public static func max(_ lhs: Vector2, _ rhs: Vector2) -> Vector2 { simd_max(lhs, rhs) }

    @inlinable public static func max(_ lhs: Vector3, _ rhs: Vector3) -> Vector3 { simd_max(lhs, rhs) }

    @inlinable public static func max(_ lhs: Vector4, _ rhs: Vector4) -> Vector4 { simd_max(lhs, rhs) }


    /// - Returns: Minimum element in the receiver.
    @inlinable public static func min(_ m: Matrix2x2) -> Scalar { Swift.min(m[0].min(), m[1].min()) }

    /// - Returns: Minimum element in the receiver.
    @inlinable public static func min(_ m: Matrix3x3) -> Scalar { Swift.min(m[0].min(), m[1].min(), m[2].min()) }

    /// - Returns: Minimum element in the receiver.
    @inlinable public static func min(_ m: Matrix4x4) -> Scalar { Swift.min(m[0].min(), m[1].min(), m[2].min(), m[3].min()) }


    @inlinable public static func min(_ lhs: Vector2, _ rhs: Vector2) -> Vector2 { simd_min(lhs, rhs) }

    @inlinable public static func min(_ lhs: Vector3, _ rhs: Vector3) -> Vector3 { simd_min(lhs, rhs) }

    @inlinable public static func min(_ lhs: Vector4, _ rhs: Vector4) -> Vector4 { simd_min(lhs, rhs) }


    @inlinable public static func mix(_ lhs: Scalar, _ rhs: Scalar, t: Scalar) -> Scalar { simd_mix(lhs, rhs, t) }

    @inlinable public static func mix(_ lhs: Vector2, _ rhs: Vector2, t: Vector2) -> Vector2 { simd_mix(lhs, rhs, t) }

    @inlinable public static func mix(_ lhs: Vector2, _ rhs: Vector2, t: Scalar) -> Vector2 { simd.mix(lhs, rhs, t: t) }

    @inlinable public static func mix(_ lhs: Vector3, _ rhs: Vector3, t: Vector3) -> Vector3 { simd_mix(lhs, rhs, t) }

    @inlinable public static func mix(_ lhs: Vector3, _ rhs: Vector3, t: Scalar) -> Vector3 { simd.mix(lhs, rhs, t: t) }

    @inlinable public static func mix(_ lhs: Vector4, _ rhs: Vector4, t: Vector4) -> Vector4 { simd_mix(lhs, rhs, t) }

    @inlinable public static func mix(_ lhs: Vector4, _ rhs: Vector4, t: Scalar) -> Vector4 { simd.mix(lhs, rhs, t: t) }

    @inlinable public static func mix(_ lhs: Matrix2x2, _ rhs: Matrix2x2, t: Scalar) -> Matrix2x2 { simd_linear_combination(1 - t, lhs, t, rhs) }

    @inlinable public static func mix(_ lhs: Matrix3x3, _ rhs: Matrix3x3, t: Scalar) -> Matrix3x3 { simd_linear_combination(1 - t, lhs, t, rhs) }

    @inlinable public static func mix(_ lhs: Matrix4x4, _ rhs: Matrix4x4, t: Scalar) -> Matrix4x4 { simd_linear_combination(1 - t, lhs, t, rhs) }


    @inlinable public static func normalize(_ v: Vector2) -> Vector2 { simd_normalize(v) }

    @inlinable public static func normalize(_ v: Vector3) -> Vector3 { simd_normalize(v) }

    @inlinable public static func normalize(_ v: Vector4) -> Vector4 { simd_normalize(v) }


    @inlinable public static func recip(_ x: Scalar) -> Scalar { simd_recip(x) }

    @inlinable public static func recip(_ v: Vector2) -> Vector2 { simd_recip(v) }

    @inlinable public static func recip(_ v: Vector3) -> Vector3 { simd_recip(v) }

    @inlinable public static func recip(_ v: Vector4) -> Vector4 { simd_recip(v) }


    @inlinable public static func rsqrt(_ x: Scalar) -> Scalar { simd_rsqrt(x) }

    @inlinable public static func rsqrt(_ v: Vector2) -> Vector2 { simd_rsqrt(v) }

    @inlinable public static func rsqrt(_ v: Vector3) -> Vector3 { simd_rsqrt(v) }

    @inlinable public static func rsqrt(_ v: Vector4) -> Vector4 { simd_rsqrt(v) }


    /// - Returns: Normalized vector or *nil* whether *v* is nondegenerate.
    @inlinable
    public static func safeNormalize(_ v: Vector2) -> Vector2? {
        guard isZero(v) else { return nil }
        return normalize(v)
    }

    /// - Returns: Normalized vector or *nil* whether *v* is nondegenerate.
    @inlinable
    public static func safeNormalize(_ v: Vector3) -> Vector3? {
        guard isZero(v) else { return nil }
        return normalize(v)
    }

    /// - Returns: Normalized vector or *nil* whether *v* is nondegenerate.
    @inlinable
    public static func safeNormalize(_ v: Vector4) -> Vector4? {
        guard isZero(v) else { return nil }
        return normalize(v)
    }


    @inlinable public static func sin(_ x: Scalar) -> Scalar { simd.sin(x) }

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    @inlinable public static func sin(_ v: Vector2) -> Vector2 { simd.sin(v) }

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    @inlinable public static func sin(_ v: Vector3) -> Vector3 { simd.sin(v) }

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    @inlinable public static func sin(_ v: Vector4) -> Vector4 { simd.sin(v) }


    /// - Returns: Both sine and cosine of given angle.
    @inlinable public static func sincos(_ angle: Scalar) -> (sin: Scalar, cos: Scalar) { (sin(angle), cos(angle)) }


    @inlinable public static func sinpi(_ x: Scalar) -> Scalar { sin(x * .pi) }

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    @inlinable public static func sinpi(_ v: Vector2) -> Vector2 { simd.sinpi(v) }

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    @inlinable public static func sinpi(_ v: Vector3) -> Vector3 { simd.sinpi(v) }

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    @inlinable public static func sinpi(_ v: Vector4) -> Vector4 { simd.sinpi(v) }


    /// - Returns A spherical linearly interpolated value along the shortest arc between two vectors.
    @inlinable
    public static func slerp(_ lhs: Vector2, _ rhs: Vector2, t: Scalar) -> Vector2 {
        make2(slerp(make3(lhs), make3(rhs), t: t))
    }

    /// - Returns A spherical linearly interpolated value along the shortest arc between two vectors.
    @inlinable
    public static func slerp(_ lhs: Vector3, _ rhs: Vector3, t: Scalar) -> Vector3 {
        let q = Quaternion(from: lhs, to: rhs)

        return Quaternion(angle: t * q.angle, axis: q.axis).act(lhs)
    }

    /// - Returns A spherical linearly interpolated value along the shortest arc between two quaternions.
    @inlinable public static func slerp(_ lhs: Quaternion, _ rhs: Quaternion, t: Scalar) -> Quaternion { simd_slerp(lhs, rhs, t) }


    /// - Returns A spherical linearly interpolated value along the longest arc between two vectors.
    @inlinable
    public static func slerp_longest(_ lhs: Vector2, _ rhs: Vector2, t: Scalar) -> Vector2 {
        make2(slerp_longest(make3(lhs), make3(rhs), t: t))
    }

    /// - Returns A spherical linearly interpolated value along the longest arc between two vectors.
    @inlinable
    public static func slerp_longest(_ lhs: Vector3, _ rhs: Vector3, t: Scalar) -> Vector3 {
        let q = Quaternion(from: lhs, to: rhs)

        return Quaternion(angle: t * (q.angle - 2 * Scalar.pi), axis: q.axis).act(lhs)
    }

    /// - Returns A spherical linearly interpolated value along the longest arc between two quaternions.
    @inlinable public static func slerp_longest(_ lhs: Quaternion, _ rhs: Quaternion, t: Scalar) -> Quaternion { simd_slerp_longest(lhs, rhs, t) }


    @inlinable public static func tan(_ x: Scalar) -> Scalar { simd.tan(x) }

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    @inlinable public static func tan(_ v: Vector2) -> Vector2 { simd.tan(v) }

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    @inlinable public static func tan(_ v: Vector3) -> Vector3 { simd.tan(v) }

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    @inlinable public static func tan(_ v: Vector4) -> Vector4 { simd.tan(v) }


    @inlinable public static func tanpi(_ x: Scalar) -> Scalar { tan(x * .pi) }

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    @inlinable public static func tanpi(_ v: Vector2) -> Vector2 { simd.tanpi(v) }

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    @inlinable public static func tanpi(_ v: Vector3) -> Vector3 { simd.tanpi(v) }

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    @inlinable public static func tanpi(_ v: Vector4) -> Vector4 { simd.tanpi(v) }

}
