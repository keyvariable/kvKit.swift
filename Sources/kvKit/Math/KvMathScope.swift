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

    /// - Returns: Tolerance argument for numerical comparisons depending on a vector value.
    static func epsArg(_ v: Vector2) -> EpsArg2
    /// - Returns: Tolerance argument for numerical comparisons depending on a vector value.
    static func epsArg(_ v: Vector3) -> EpsArg3
    /// - Returns: Tolerance argument for numerical comparisons depending on a vector value.
    static func epsArg(_ v: Vector4) -> EpsArg4
    /// - Returns: Tolerance argument for numerical comparisons depending on a matrix value.
    static func epsArg(_ m: Matrix2x2) -> EpsArg2x2
    /// - Returns: Tolerance argument for numerical comparisons depending on a matrix value.
    static func epsArg(_ m: Matrix3x3) -> EpsArg3x3
    /// - Returns: Tolerance argument for numerical comparisons depending on a matrix value.
    static func epsArg(_ m: Matrix4x4) -> EpsArg4x4

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

    /// - Returns: A boolean value indicating wheather given vectors are collinear.
    ///
    /// - Note: *False* is returned if any of given vectors is zero.
    static func isCollinear(_ lhs: Vector2, _ rhs: Vector2) -> Bool
    /// - Returns: A boolean value indicating wheather given vectors are collinear.
    ///
    /// - Note: *False* is returned if any of given vectors is zero.
    static func isCollinear(_ lhs: Vector3, _ rhs: Vector3) -> Bool
    /// - Returns: A boolean value indicating wheather given vectors are collinear.
    ///
    /// - Note: *False* is returned if any of given vectors is zero.
    static func isCollinear(_ lhs: Vector4, _ rhs: Vector4) -> Bool

    /// - Returns: A boolean value indicating wheather given vectors are inequal.
    static func isInequal(_ lhs: Vector2, _ rhs: Vector2) -> Bool
    /// - Returns: A boolean value indicating wheather given vectors are inequal.
    static func isInequal(_ lhs: Vector2, _ rhs: Vector2, eps: Eps) -> Bool
    /// - Returns: A boolean value indicating wheather given vectors are inequal.
    static func isInequal(_ lhs: Vector3, _ rhs: Vector3) -> Bool
    /// - Returns: A boolean value indicating wheather given vectors are inequal.
    static func isInequal(_ lhs: Vector3, _ rhs: Vector3, eps: Eps) -> Bool
    /// - Returns: A boolean value indicating wheather given vectors are inequal.
    static func isInequal(_ lhs: Vector4, _ rhs: Vector4) -> Bool
    /// - Returns: A boolean value indicating wheather given vectors are inequal.
    static func isInequal(_ lhs: Vector4, _ rhs: Vector4, eps: Eps) -> Bool
    /// - Returns: A boolean value indicating wheather given quaternions are inequal.
    static func isInequal(_ lhs: Quaternion, _ rhs: Quaternion) -> Bool
    /// - Returns: A boolean value indicating wheather given quaternions are inequal.
    static func isInequal(_ lhs: Quaternion, _ rhs: Quaternion, eps: Eps) -> Bool
    /// - Returns: A boolean value indicating wheather given matrices are inequal.
    static func isInequal(_ lhs: Matrix2x2, _ rhs: Matrix2x2) -> Bool
    /// - Returns: A boolean value indicating wheather given matrices are inequal.
    static func isInequal(_ lhs: Matrix2x2, _ rhs: Matrix2x2, eps: Eps) -> Bool
    /// - Returns: A boolean value indicating wheather given matrices are inequal.
    static func isInequal(_ lhs: Matrix3x3, _ rhs: Matrix3x3) -> Bool
    /// - Returns: A boolean value indicating wheather given matrices are inequal.
    static func isInequal(_ lhs: Matrix3x3, _ rhs: Matrix3x3, eps: Eps) -> Bool
    /// - Returns: A boolean value indicating wheather given matrices are inequal.
    static func isInequal(_ lhs: Matrix4x4, _ rhs: Matrix4x4) -> Bool
    /// - Returns: A boolean value indicating wheather given matrices are inequal.
    static func isInequal(_ lhs: Matrix4x4, _ rhs: Matrix4x4, eps: Eps) -> Bool

    /// - Returns: A boolean value indicating wheather given vectors are equal.
    static func isEqual(_ lhs: Vector2, _ rhs: Vector2) -> Bool
    /// - Returns: A boolean value indicating wheather given vectors are equal.
    static func isEqual(_ lhs: Vector2, _ rhs: Vector2, eps: Eps) -> Bool
    /// - Returns: A boolean value indicating wheather given vectors are equal.
    static func isEqual(_ lhs: Vector3, _ rhs: Vector3) -> Bool
    /// - Returns: A boolean value indicating wheather given vectors are equal.
    static func isEqual(_ lhs: Vector3, _ rhs: Vector3, eps: Eps) -> Bool
    /// - Returns: A boolean value indicating wheather given vectors are equal.
    static func isEqual(_ lhs: Vector4, _ rhs: Vector4) -> Bool
    /// - Returns: A boolean value indicating wheather given vectors are equal.
    static func isEqual(_ lhs: Vector4, _ rhs: Vector4, eps: Eps) -> Bool
    /// - Returns: A boolean value indicating wheather given quaternions are equal.
    static func isEqual(_ lhs: Quaternion, _ rhs: Quaternion) -> Bool
    /// - Returns: A boolean value indicating wheather given quaternions are equal.
    static func isEqual(_ lhs: Quaternion, _ rhs: Quaternion, eps: Eps) -> Bool
    /// - Returns: A boolean value indicating wheather given matrices are equal.
    static func isEqual(_ lhs: Matrix2x2, _ rhs: Matrix2x2) -> Bool
    /// - Returns: A boolean value indicating wheather given matrices are equal.
    static func isEqual(_ lhs: Matrix2x2, _ rhs: Matrix2x2, eps: Eps) -> Bool
    /// - Returns: A boolean value indicating wheather given matrices are equal.
    static func isEqual(_ lhs: Matrix3x3, _ rhs: Matrix3x3) -> Bool
    /// - Returns: A boolean value indicating wheather given matrices are equal.
    static func isEqual(_ lhs: Matrix3x3, _ rhs: Matrix3x3, eps: Eps) -> Bool
    /// - Returns: A boolean value indicating wheather given matrices are equal.
    static func isEqual(_ lhs: Matrix4x4, _ rhs: Matrix4x4) -> Bool
    /// - Returns: A boolean value indicating wheather given matrices are equal.
    static func isEqual(_ lhs: Matrix4x4, _ rhs: Matrix4x4, eps: Eps) -> Bool

    /// - Returns: A boolean value indicating whether given vectors are both nonzero and are not orthogonal.
    static func isNonOrthogonal(_ lhs: Vector2, _ rhs: Vector2) -> Bool
    /// - Returns: A boolean value indicating whether given vectors are both nonzero and are not orthogonal.
    static func isNonOrthogonal(_ lhs: Vector2, _ rhs: Vector2, eps: Eps) -> Bool
    /// - Returns: A boolean value indicating whether given vectors are both nonzero and are not orthogonal.
    static func isNonOrthogonal(_ lhs: Vector3, _ rhs: Vector3) -> Bool
    /// - Returns: A boolean value indicating whether given vectors are both nonzero and are not orthogonal.
    static func isNonOrthogonal(_ lhs: Vector3, _ rhs: Vector3, eps: Eps) -> Bool
    /// - Returns: A boolean value indicating whether given vectors are both nonzero and are not orthogonal.
    static func isNonOrthogonal(_ lhs: Vector4, _ rhs: Vector4) -> Bool
    /// - Returns: A boolean value indicating whether given vectors are both nonzero and are not orthogonal.
    static func isNonOrthogonal(_ lhs: Vector4, _ rhs: Vector4, eps: Eps) -> Bool

    /// - Returns: A boolean value indicating whether given vectors are both nonzero and orthogonal.
    static func isOrthogonal(_ lhs: Vector2, _ rhs: Vector2) -> Bool
    /// - Returns: A boolean value indicating whether given vectors are both nonzero and orthogonal.
    static func isOrthogonal(_ lhs: Vector2, _ rhs: Vector2, eps: Eps) -> Bool
    /// - Returns: A boolean value indicating whether given vectors are both nonzero and orthogonal.
    static func isOrthogonal(_ lhs: Vector3, _ rhs: Vector3) -> Bool
    /// - Returns: A boolean value indicating whether given vectors are both nonzero and orthogonal.
    static func isOrthogonal(_ lhs: Vector3, _ rhs: Vector3, eps: Eps) -> Bool
    /// - Returns: A boolean value indicating whether given vectors are both nonzero and orthogonal.
    static func isOrthogonal(_ lhs: Vector4, _ rhs: Vector4) -> Bool
    /// - Returns: A boolean value indicating whether given vectors are both nonzero and orthogonal.
    static func isOrthogonal(_ lhs: Vector4, _ rhs: Vector4, eps: Eps) -> Bool

    /// - Returns: A boolean value indicating wheather given vector is numerically inequal to zero vector.
    static func isNonzero(_ v: Vector2) -> Bool
    /// - Returns: A boolean value indicating wheather given vector is numerically inequal to zero vector.
    static func isNonzero(_ v: Vector2, eps: Eps) -> Bool
    /// - Returns: A boolean value indicating wheather given vector is numerically inequal to zero vector.
    static func isNonzero(_ v: Vector3) -> Bool
    /// - Returns: A boolean value indicating wheather given vector is numerically inequal to zero vector.
    static func isNonzero(_ v: Vector3, eps: Eps) -> Bool
    /// - Returns: A boolean value indicating wheather given vector is numerically inequal to zero vector.
    static func isNonzero(_ v: Vector4) -> Bool
    /// - Returns: A boolean value indicating wheather given vector is numerically inequal to zero vector.
    static func isNonzero(_ v: Vector4, eps: Eps) -> Bool
    /// - Returns: A boolean value indicating wheather given quaternion is numerically inequal to zero quaternion.
    static func isNonzero(_ q: Quaternion) -> Bool
    /// - Returns: A boolean value indicating wheather given quaternion is numerically inequal to zero quaternion.
    static func isNonzero(_ q: Quaternion, eps: Eps) -> Bool
    /// - Returns: A boolean value indicating wheather given matrix is numerically inequal to zero matrix.
    static func isNonzero(_ m: Matrix2x2) -> Bool
    /// - Returns: A boolean value indicating wheather given matrix is numerically inequal to zero matrix.
    static func isNonzero(_ m: Matrix2x2, eps: Eps) -> Bool
    /// - Returns: A boolean value indicating wheather given matrix is numerically inequal to zero matrix.
    static func isNonzero(_ m: Matrix3x3) -> Bool
    /// - Returns: A boolean value indicating wheather given matrix is numerically inequal to zero matrix.
    static func isNonzero(_ m: Matrix3x3, eps: Eps) -> Bool
    /// - Returns: A boolean value indicating wheather given matrix is numerically inequal to zero matrix.
    static func isNonzero(_ m: Matrix4x4) -> Bool
    /// - Returns: A boolean value indicating wheather given matrix is numerically inequal to zero matrix.
    static func isNonzero(_ m: Matrix4x4, eps: Eps) -> Bool

    /// - Returns: A boolean value indicating whether given vector is of unit length.
    static func isUnit(_ v: Vector2) -> Bool
    /// - Returns: A boolean value indicating whether given vector is of unit length.
    static func isUnit(_ v: Vector2, eps: Eps) -> Bool
    /// - Returns: A boolean value indicating whether given vector is of unit length.
    static func isUnit(_ v: Vector3) -> Bool
    /// - Returns: A boolean value indicating whether given vector is of unit length.
    static func isUnit(_ v: Vector3, eps: Eps) -> Bool
    /// - Returns: A boolean value indicating whether given vector is of unit length.
    static func isUnit(_ v: Vector4) -> Bool
    /// - Returns: A boolean value indicating whether given vector is of unit length.
    static func isUnit(_ v: Vector4, eps: Eps) -> Bool

    /// - Returns: A boolean value indicating wheather given vector is numerically equal to zero vector.
    static func isZero(_ v: Vector2) -> Bool
    /// - Returns: A boolean value indicating wheather given vector is numerically equal to zero vector.
    static func isZero(_ v: Vector2, eps: Eps) -> Bool
    /// - Returns: A boolean value indicating wheather given vector is numerically equal to zero vector.
    static func isZero(_ v: Vector3) -> Bool
    /// - Returns: A boolean value indicating wheather given vector is numerically equal to zero vector.
    static func isZero(_ v: Vector3, eps: Eps) -> Bool
    /// - Returns: A boolean value indicating wheather given vector is numerically equal to zero vector.
    static func isZero(_ v: Vector4) -> Bool
    /// - Returns: A boolean value indicating wheather given vector is numerically equal to zero vector.
    static func isZero(_ v: Vector4, eps: Eps) -> Bool
    /// - Returns: A boolean value indicating wheather given vector is numerically equal to zero quaternion.
    static func isZero(_ q: Quaternion) -> Bool
    /// - Returns: A boolean value indicating wheather given vector is numerically equal to zero quaternion.
    static func isZero(_ q: Quaternion, eps: Eps) -> Bool
    /// - Returns: A boolean value indicating wheather given matrix is numerically equal to zero matrix.
    static func isZero(_ m: Matrix2x2) -> Bool
    /// - Returns: A boolean value indicating wheather given matrix is numerically equal to zero matrix.
    static func isZero(_ m: Matrix2x2, eps: Eps) -> Bool
    /// - Returns: A boolean value indicating wheather given matrix is numerically equal to zero matrix.
    static func isZero(_ m: Matrix3x3) -> Bool
    /// - Returns: A boolean value indicating wheather given matrix is numerically equal to zero matrix.
    static func isZero(_ m: Matrix3x3, eps: Eps) -> Bool
    /// - Returns: A boolean value indicating wheather given matrix is numerically equal to zero matrix.
    static func isZero(_ m: Matrix4x4) -> Bool
    /// - Returns: A boolean value indicating wheather given matrix is numerically equal to zero matrix.
    static func isZero(_ m: Matrix4x4, eps: Eps) -> Bool

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
    static func max(_ lhs: Matrix2x2, _ rhs: Matrix2x2) -> Matrix2x2
    static func max(_ lhs: Matrix3x3, _ rhs: Matrix3x3) -> Matrix3x3
    static func max(_ lhs: Matrix4x4, _ rhs: Matrix4x4) -> Matrix4x4

    /// - Returns: Minimum element in the receiver.
    static func min(_ m: Matrix2x2) -> Scalar
    /// - Returns: Minimum element in the receiver.
    static func min(_ m: Matrix3x3) -> Scalar
    /// - Returns: Minimum element in the receiver.
    static func min(_ m: Matrix4x4) -> Scalar

    static func min(_ lhs: Vector2, _ rhs: Vector2) -> Vector2
    static func min(_ lhs: Vector3, _ rhs: Vector3) -> Vector3
    static func min(_ lhs: Vector4, _ rhs: Vector4) -> Vector4
    static func min(_ lhs: Matrix2x2, _ rhs: Matrix2x2) -> Matrix2x2
    static func min(_ lhs: Matrix3x3, _ rhs: Matrix3x3) -> Matrix3x3
    static func min(_ lhs: Matrix4x4, _ rhs: Matrix4x4) -> Matrix4x4

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



// MARK: Auxiliaries

extension KvMathScope {

    public typealias Eps = KvEps<Scalar>
    public typealias EpsArg = KvEps<Scalar>.Argument

    public typealias EpsArg2 = KvNumericalToleranceVectorArgument2<Self>
    public typealias EpsArg3 = KvNumericalToleranceVectorArgument3<Self>
    public typealias EpsArg4 = KvNumericalToleranceVectorArgument4<Self>

    public typealias EpsArg2x2 = KvNumericalToleranceVectorArgument2x2<Self>
    public typealias EpsArg3x3 = KvNumericalToleranceVectorArgument3x3<Self>
    public typealias EpsArg4x4 = KvNumericalToleranceVectorArgument4x4<Self>

}



// MARK: Random Vectors

extension KvMathScope where Scalar.RawSignificand : FixedWidthInteger {

    /// - Returns: A vector of random values within the specified range.
    @inlinable
    public static func random2(in range: Range<Scalar>) -> Vector2 {
        Vector2(.random(in: range), .random(in: range))
    }

    /// - Returns: A vector of random values within the specified range.
    @inlinable
    public static func random3(in range: Range<Scalar>) -> Vector3 {
        Vector3(.random(in: range), .random(in: range), .random(in: range))
    }

    /// - Returns: A vector of random values within the specified range.
    @inlinable
    public static func random4(in range: Range<Scalar>) -> Vector4 {
        Vector4(.random(in: range), .random(in: range), .random(in: range), .random(in: range))
    }


    /// - Returns: A vector of random values within the specified range.
    @inlinable
    public static func random2(in range: ClosedRange<Scalar>) -> Vector2 {
        Vector2(.random(in: range), .random(in: range))
    }

    /// - Returns: A vector of random values within the specified range.
    @inlinable
    public static func random3(in range: ClosedRange<Scalar>) -> Vector3 {
        Vector3(.random(in: range), .random(in: range), .random(in: range))
    }

    /// - Returns: A vector of random values within the specified range.
    @inlinable
    public static func random4(in range: ClosedRange<Scalar>) -> Vector4 {
        Vector4(.random(in: range), .random(in: range), .random(in: range), .random(in: range))
    }


    /// - Returns: A vector of random values within the specified range, using the given generator as a source for randomness.
    @inlinable
    public static func random2<G : RandomNumberGenerator>(in range: Range<Scalar>, using generator: inout G) -> Vector2 {
        Vector2(.random(in: range, using: &generator), .random(in: range, using: &generator))
    }

    /// - Returns: A vector of random values within the specified range, using the given generator as a source for randomness.
    @inlinable
    public static func random3<G : RandomNumberGenerator>(in range: Range<Scalar>, using generator: inout G) -> Vector3 {
        Vector3(.random(in: range, using: &generator), .random(in: range, using: &generator), .random(in: range, using: &generator))
    }

    /// - Returns: A vector of random values within the specified range, using the given generator as a source for randomness.
    @inlinable
    public static func random4<G : RandomNumberGenerator>(in range: Range<Scalar>, using generator: inout G) -> Vector4 {
        Vector4(.random(in: range, using: &generator), .random(in: range, using: &generator), .random(in: range, using: &generator), .random(in: range, using: &generator))
    }


    /// - Returns: A vector of random values within the specified range, using the given generator as a source for randomness.
    @inlinable
    public static func random2<G : RandomNumberGenerator>(in range: ClosedRange<Scalar>, using generator: inout G) -> Vector2 {
        Vector2(.random(in: range, using: &generator), .random(in: range, using: &generator))
    }

    /// - Returns: A vector of random values within the specified range, using the given generator as a source for randomness.
    @inlinable
    public static func random3<G : RandomNumberGenerator>(in range: ClosedRange<Scalar>, using generator: inout G) -> Vector3 {
        Vector3(.random(in: range, using: &generator), .random(in: range, using: &generator), .random(in: range, using: &generator))
    }

    /// - Returns: A vector of random values within the specified range, using the given generator as a source for randomness.
    @inlinable
    public static func random4<G : RandomNumberGenerator>(in range: ClosedRange<Scalar>, using generator: inout G) -> Vector4 {
        Vector4(.random(in: range, using: &generator), .random(in: range, using: &generator), .random(in: range, using: &generator), .random(in: range, using: &generator))
    }


    /// - Returns: Random nonzero value within the specified range.
    @usableFromInline
    internal static func randomNonzero(in range: Range<Scalar>) -> Scalar {
        let s = Scalar.random(in: range)
        let eps = 2 * Eps.default.value

        return s.sign == .plus ? Swift.max(s, eps) : Swift.min(s, -eps)
    }

    /// - Returns: Random nonzero value within the specified range.
    @usableFromInline
    internal static func randomNonzero(in range: ClosedRange<Scalar>) -> Scalar {
        let s = Scalar.random(in: range)
        let eps = 2 * Eps.default.value

        return s.sign == .plus ? Swift.max(s, eps) : Swift.min(s, -eps)
    }


    /// - Returns: A nonzero vector of random values within the specified range.
    @inlinable
    public static func randomNonzero2(in range: Range<Scalar>) -> Vector2 {
        // Case of all-zero flags (0b11) is excluded.
        let zeroFlags = Int.random(in: 0...2)
        return Vector2((zeroFlags & 1) != 0 ? .random(in: range) : randomNonzero(in: range),
                       (zeroFlags & 2) != 0 ? .random(in: range) : randomNonzero(in: range))
    }

    /// - Returns: A nonzero vector of random values within the specified range.
    @inlinable
    public static func randomNonzero3(in range: Range<Scalar>) -> Vector3 {
        // Case of all-zero flags (0b111) is excluded.
        let zeroFlags = Int.random(in: 0...6)
        return Vector3((zeroFlags & 1) != 0 ? .random(in: range) : randomNonzero(in: range),
                       (zeroFlags & 2) != 0 ? .random(in: range) : randomNonzero(in: range),
                       (zeroFlags & 4) != 0 ? .random(in: range) : randomNonzero(in: range))
    }

    /// - Returns: A nonzero vector of random values within the specified range.
    @inlinable
    public static func randomNonzero4(in range: Range<Scalar>) -> Vector4 {
        // Case of all-zero flags (0b1111) is excluded.
        let zeroFlags = Int.random(in: 0...14)
        return Vector4((zeroFlags & 1) != 0 ? .random(in: range) : randomNonzero(in: range),
                       (zeroFlags & 2) != 0 ? .random(in: range) : randomNonzero(in: range),
                       (zeroFlags & 4) != 0 ? .random(in: range) : randomNonzero(in: range),
                       (zeroFlags & 8) != 0 ? .random(in: range) : randomNonzero(in: range))
    }


    /// - Returns: A nonzero vector of random values within the specified range.
    @inlinable
    public static func randomNonzero2(in range: ClosedRange<Scalar>) -> Vector2 {
        // Case of all-zero flags (0b11) is excluded.
        let zeroFlags = Int.random(in: 0...2)
        return Vector2((zeroFlags & 1) != 0 ? .random(in: range) : randomNonzero(in: range),
                       (zeroFlags & 2) != 0 ? .random(in: range) : randomNonzero(in: range))
    }

    /// - Returns: A nonzero vector of random values within the specified range.
    @inlinable
    public static func randomNonzero3(in range: ClosedRange<Scalar>) -> Vector3 {
        // Case of all-zero flags (0b111) is excluded.
        let zeroFlags = Int.random(in: 0...6)
        return Vector3((zeroFlags & 1) != 0 ? .random(in: range) : randomNonzero(in: range),
                       (zeroFlags & 2) != 0 ? .random(in: range) : randomNonzero(in: range),
                       (zeroFlags & 4) != 0 ? .random(in: range) : randomNonzero(in: range))
    }

    /// - Returns: A nonzero vector of random values within the specified range.
    @inlinable
    public static func randomNonzero4(in range: ClosedRange<Scalar>) -> Vector4 {
        // Case of all-zero flags (0b1111) is excluded.
        let zeroFlags = Int.random(in: 0...14)
        return Vector4((zeroFlags & 1) != 0 ? .random(in: range) : randomNonzero(in: range),
                       (zeroFlags & 2) != 0 ? .random(in: range) : randomNonzero(in: range),
                       (zeroFlags & 4) != 0 ? .random(in: range) : randomNonzero(in: range),
                       (zeroFlags & 8) != 0 ? .random(in: range) : randomNonzero(in: range))
    }

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


    /// - Returns: Tolerance argument for numerical comparisons depending on a vector value.
    @inlinable public static func epsArg(_ v: Vector2) -> EpsArg2 { EpsArg2(v) }

    /// - Returns: Tolerance argument for numerical comparisons depending on a vector value.
    @inlinable public static func epsArg(_ v: Vector3) -> EpsArg3 { EpsArg3(v) }

    /// - Returns: Tolerance argument for numerical comparisons depending on a vector value.
    @inlinable public static func epsArg(_ v: Vector4) -> EpsArg4 { EpsArg4(v) }

    /// - Returns: Tolerance argument for numerical comparisons depending on a matrix value.
    @inlinable public static func epsArg(_ m: Matrix2x2) -> EpsArg2x2 { EpsArg2x2(m) }

    /// - Returns: Tolerance argument for numerical comparisons depending on a matrix value.
    @inlinable public static func epsArg(_ m: Matrix3x3) -> EpsArg3x3 { EpsArg3x3(m) }

    /// - Returns: Tolerance argument for numerical comparisons depending on a matrix value.
    @inlinable public static func epsArg(_ m: Matrix4x4) -> EpsArg4x4 { EpsArg4x4(m) }


    /// - Returns: A boolean value indicating wheather given vectors are co-directional.
    ///
    /// - Note: Two zero vectors are not co-directional.
    @inlinable
    public static func isCoDirectional(_ lhs: Vector2, _ rhs: Vector2) -> Bool {
        KvIsPositive(simd_dot(lhs, rhs), eps: epsArg(lhs).dot(epsArg(rhs)).tolerance)
        && KvIsZero(cross(lhs, rhs).z, eps: epsArg(lhs).cross(epsArg(rhs)).tolerance)
    }

    /// - Returns: A boolean value indicating wheather given vectors are co-directional.
    ///
    /// - Note: Two zero vectors are not co-directional.
    @inlinable
    public static func isCoDirectional(_ lhs: Vector3, _ rhs: Vector3) -> Bool {
        KvIsPositive(simd_dot(lhs, rhs), eps: epsArg(lhs).dot(epsArg(rhs)).tolerance)
        && isZero(cross(lhs, rhs), eps: epsArg(lhs).cross(epsArg(rhs)).tolerance)
    }

    /// - Returns: A boolean value indicating wheather given vectors are co-directional.
    ///
    /// - Note: Two zero vectors are not co-directional.
    @inlinable
    public static func isCoDirectional(_ lhs: Vector4, _ rhs: Vector4) -> Bool {
        guard let lhs = safeNormalize(lhs),
              let rhs = safeNormalize(rhs)
        else { return false }

        return isEqual(lhs, rhs)
    }


    /// - Returns: A boolean value indicating wheather given vectors are collinear.
    ///
    /// - Note: *False* is returned if any of given vectors is zero.
    @inlinable
    public static func isCollinear(_ lhs: Vector2, _ rhs: Vector2) -> Bool {
        KvIsNonzero(simd_dot(lhs, rhs), eps: epsArg(lhs).dot(epsArg(rhs)).tolerance)    // Both vectors are nonzero
        && KvIsZero(cross(lhs, rhs).z, eps: epsArg(lhs).cross(epsArg(rhs)).tolerance)
    }

    /// - Returns: A boolean value indicating wheather given vectors are collinear.
    ///
    /// - Note: *False* is returned if any of given vectors is zero.
    @inlinable
    public static func isCollinear(_ lhs: Vector3, _ rhs: Vector3) -> Bool {
        KvIsNonzero(simd_dot(lhs, rhs), eps: epsArg(lhs).dot(epsArg(rhs)).tolerance)    // Both vectors are nonzero
        && isZero(cross(lhs, rhs), eps: epsArg(lhs).cross(epsArg(rhs)).tolerance)
    }

    /// - Returns: A boolean value indicating wheather given vectors are collinear.
    ///
    /// - Note: *False* is returned if any of given vectors is zero.
    @inlinable
    public static func isCollinear(_ lhs: Vector4, _ rhs: Vector4) -> Bool {
        guard let lhs = safeNormalize(lhs),
              let rhs = safeNormalize(rhs)
        else { return false }

        return isEqual(lhs, rhs) || isEqual(lhs, -rhs)
    }


    /// - Returns: A boolean value indicating wheather given vectors are inequal.
    @inlinable
    public static func isInequal(_ lhs: Vector2, _ rhs: Vector2) -> Bool {
        isInequal(lhs, rhs, eps: (epsArg(lhs) - epsArg(rhs)).tolerance)
    }

    /// - Returns: A boolean value indicating wheather given vectors are inequal.
    @inlinable
    public static func isInequal(_ lhs: Vector2, _ rhs: Vector2, eps: Eps) -> Bool {
        KvIsNonzero(abs(rhs - lhs).max(), eps: eps)
    }

    /// - Returns: A boolean value indicating wheather given vectors are inequal.
    @inlinable
    public static func isInequal(_ lhs: Vector3, _ rhs: Vector3) -> Bool {
        isInequal(lhs, rhs, eps: (epsArg(lhs) - epsArg(rhs)).tolerance)
    }

    /// - Returns: A boolean value indicating wheather given vectors are inequal.
    @inlinable
    public static func isInequal(_ lhs: Vector3, _ rhs: Vector3, eps: Eps) -> Bool {
        KvIsNonzero(abs(rhs - lhs).max(), eps: eps)
    }

    /// - Returns: A boolean value indicating wheather given vectors are inequal.
    @inlinable
    public static func isInequal(_ lhs: Vector4, _ rhs: Vector4) -> Bool {
        isInequal(lhs, rhs, eps: (epsArg(lhs) - epsArg(rhs)).tolerance)
    }

    /// - Returns: A boolean value indicating wheather given vectors are inequal.
    @inlinable
    public static func isInequal(_ lhs: Vector4, _ rhs: Vector4, eps: Eps) -> Bool {
        KvIsNonzero(abs(rhs - lhs).max(), eps: eps)
    }

    /// - Returns: A boolean value indicating wheather given quaternions are inequal.
    @inlinable public static func isInequal(_ lhs: Quaternion, _ rhs: Quaternion) -> Bool { isInequal(lhs.vector, rhs.vector) }

    /// - Returns: A boolean value indicating wheather given quaternions are inequal.
    @inlinable public static func isInequal(_ lhs: Quaternion, _ rhs: Quaternion, eps: Eps) -> Bool { isInequal(lhs.vector, rhs.vector, eps: eps) }

    /// - Returns: A boolean value indicating wheather given matrices are inequal.
    @inlinable
    public static func isInequal(_ lhs: Matrix2x2, _ rhs: Matrix2x2) -> Bool {
        isInequal(lhs, rhs, eps: EpsArg(max(abs(lhs)), max(abs(rhs))).tolerance)
    }

    /// - Returns: A boolean value indicating wheather given matrices are inequal.
    @inlinable
    public static func isInequal(_ lhs: Matrix2x2, _ rhs: Matrix2x2, eps: Eps) -> Bool {
        isInequal(lhs[0], rhs[0], eps: eps)
        || isInequal(lhs[1], rhs[1], eps: eps)
    }

    /// - Returns: A boolean value indicating wheather given matrices are inequal.
    @inlinable
    public static func isInequal(_ lhs: Matrix3x3, _ rhs: Matrix3x3) -> Bool {
        isInequal(lhs, rhs, eps: EpsArg(max(abs(lhs)), max(abs(rhs))).tolerance)
    }

    /// - Returns: A boolean value indicating wheather given matrices are inequal.
    @inlinable
    public static func isInequal(_ lhs: Matrix3x3, _ rhs: Matrix3x3, eps: Eps) -> Bool {
        isInequal(lhs[0], rhs[0], eps: eps)
        || isInequal(lhs[1], rhs[1], eps: eps)
        || isInequal(lhs[2], rhs[2], eps: eps)
    }

    /// - Returns: A boolean value indicating wheather given matrices are inequal.
    @inlinable
    public static func isInequal(_ lhs: Matrix4x4, _ rhs: Matrix4x4) -> Bool {
        isInequal(lhs, rhs, eps: EpsArg(max(abs(lhs)), max(abs(rhs))).tolerance)
    }

    /// - Returns: A boolean value indicating wheather given matrices are inequal.
    @inlinable
    public static func isInequal(_ lhs: Matrix4x4, _ rhs: Matrix4x4, eps: Eps) -> Bool {
        isInequal(lhs[0], rhs[0], eps: eps)
        || isInequal(lhs[1], rhs[1], eps: eps)
        || isInequal(lhs[2], rhs[2], eps: eps)
        || isInequal(lhs[3], rhs[3], eps: eps)
    }


    /// - Returns: A boolean value indicating wheather given vectors are equal.
    @inlinable
    public static func isEqual(_ lhs: Vector2, _ rhs: Vector2) -> Bool {
        isEqual(lhs, rhs, eps: (epsArg(lhs) - epsArg(rhs)).tolerance)
    }

    /// - Returns: A boolean value indicating wheather given vectors are equal.
    @inlinable
    public static func isEqual(_ lhs: Vector2, _ rhs: Vector2, eps: Eps) -> Bool {
        KvIsZero(abs(rhs - lhs).max(), eps: eps)
    }

    /// - Returns: A boolean value indicating wheather given vectors are equal.
    @inlinable
    public static func isEqual(_ lhs: Vector3, _ rhs: Vector3) -> Bool {
        isEqual(lhs, rhs, eps: (epsArg(lhs) - epsArg(rhs)).tolerance)
    }

    /// - Returns: A boolean value indicating wheather given vectors are equal.
    @inlinable
    public static func isEqual(_ lhs: Vector3, _ rhs: Vector3, eps: Eps) -> Bool {
        KvIsZero(abs(rhs - lhs).max(), eps: eps)
    }

    /// - Returns: A boolean value indicating wheather given vectors are equal.
    @inlinable
    public static func isEqual(_ lhs: Vector4, _ rhs: Vector4) -> Bool {
        isEqual(lhs, rhs, eps: (epsArg(lhs) - epsArg(rhs)).tolerance)
    }

    /// - Returns: A boolean value indicating wheather given vectors are equal.
    @inlinable
    public static func isEqual(_ lhs: Vector4, _ rhs: Vector4, eps: Eps) -> Bool {
        KvIsZero(abs(rhs - lhs).max(), eps: eps)
    }

    /// - Returns: A boolean value indicating wheather given quaternions are equal.
    @inlinable public static func isEqual(_ lhs: Quaternion, _ rhs: Quaternion) -> Bool { isEqual(lhs.vector, rhs.vector) }

    /// - Returns: A boolean value indicating wheather given quaternions are equal.
    @inlinable public static func isEqual(_ lhs: Quaternion, _ rhs: Quaternion, eps: Eps) -> Bool { isEqual(lhs.vector, rhs.vector, eps: eps) }

    /// - Returns: A boolean value indicating wheather given matrices are equal.
    @inlinable
    public static func isEqual(_ lhs: Matrix2x2, _ rhs: Matrix2x2) -> Bool {
        isEqual(lhs, rhs, eps: EpsArg(max(abs(lhs)), max(abs(rhs))).tolerance)
    }

    /// - Returns: A boolean value indicating wheather given matrices are equal.
    @inlinable
    public static func isEqual(_ lhs: Matrix2x2, _ rhs: Matrix2x2, eps: Eps) -> Bool {
        isEqual(lhs[0], rhs[0], eps: eps)
        && isEqual(lhs[1], rhs[1], eps: eps)
    }

    /// - Returns: A boolean value indicating wheather given matrices are equal.
    @inlinable
    public static func isEqual(_ lhs: Matrix3x3, _ rhs: Matrix3x3) -> Bool {
        isEqual(lhs, rhs, eps: EpsArg(max(abs(lhs)), max(abs(rhs))).tolerance)
    }

    /// - Returns: A boolean value indicating wheather given matrices are equal.
    @inlinable
    public static func isEqual(_ lhs: Matrix3x3, _ rhs: Matrix3x3, eps: Eps) -> Bool {
        isEqual(lhs[0], rhs[0], eps: eps)
        && isEqual(lhs[1], rhs[1], eps: eps)
        && isEqual(lhs[2], rhs[2], eps: eps)
    }

    /// - Returns: A boolean value indicating wheather given matrices are equal.
    @inlinable
    public static func isEqual(_ lhs: Matrix4x4, _ rhs: Matrix4x4) -> Bool {
        isEqual(lhs, rhs, eps: EpsArg(max(abs(lhs)), max(abs(rhs))).tolerance)
    }

    /// - Returns: A boolean value indicating wheather given matrices are equal.
    @inlinable
    public static func isEqual(_ lhs: Matrix4x4, _ rhs: Matrix4x4, eps: Eps) -> Bool {
        isEqual(lhs[0], rhs[0], eps: eps)
        && isEqual(lhs[1], rhs[1], eps: eps)
        && isEqual(lhs[2], rhs[2], eps: eps)
        && isEqual(lhs[3], rhs[3], eps: eps)
    }


    /// - Returns: A boolean value indicating whether given vectors are both nonzero and are not orthogonal.
    @inlinable
    public static func isNonOrthogonal(_ lhs: Vector2, _ rhs: Vector2) -> Bool {
        KvIsNonzero(simd_dot(lhs, rhs), eps: epsArg(lhs).dot(epsArg(rhs)).tolerance)
    }

    /// - Returns: A boolean value indicating whether given vectors are both nonzero and are not orthogonal.
    @inlinable
    public static func isNonOrthogonal(_ lhs: Vector2, _ rhs: Vector2, eps: Eps) -> Bool {
        KvIsNonzero(simd_dot(lhs, rhs), eps: eps)
    }

    /// - Returns: A boolean value indicating whether given vectors are both nonzero and are not orthogonal.
    @inlinable
    public static func isNonOrthogonal(_ lhs: Vector3, _ rhs: Vector3) -> Bool {
        KvIsNonzero(simd_dot(lhs, rhs), eps: epsArg(lhs).dot(epsArg(rhs)).tolerance)
    }

    /// - Returns: A boolean value indicating whether given vectors are both nonzero and are not orthogonal.
    @inlinable
    public static func isNonOrthogonal(_ lhs: Vector3, _ rhs: Vector3, eps: Eps) -> Bool {
        KvIsNonzero(simd_dot(lhs, rhs), eps: eps)
    }

    /// - Returns: A boolean value indicating whether given vectors are both nonzero and are not orthogonal.
    @inlinable
    public static func isNonOrthogonal(_ lhs: Vector4, _ rhs: Vector4) -> Bool {
        KvIsNonzero(simd_dot(lhs, rhs), eps: epsArg(lhs).dot(epsArg(rhs)).tolerance)
    }

    /// - Returns: A boolean value indicating whether given vectors are both nonzero and are not orthogonal.
    @inlinable
    public static func isNonOrthogonal(_ lhs: Vector4, _ rhs: Vector4, eps: Eps) -> Bool {
        KvIsNonzero(simd_dot(lhs, rhs), eps: eps)
    }


    /// - Returns: A boolean value indicating whether given vectors are both nonzero and orthogonal.
    @inlinable
    public static func isOrthogonal(_ lhs: Vector2, _ rhs: Vector2) -> Bool {
        KvIsZero(simd_dot(lhs, rhs), eps: epsArg(lhs).dot(epsArg(rhs)).tolerance) && isNonzero(lhs) && isNonzero(rhs)
    }

    /// - Returns: A boolean value indicating whether given vectors are both nonzero and orthogonal.
    @inlinable
    public static func isOrthogonal(_ lhs: Vector2, _ rhs: Vector2, eps: Eps) -> Bool {
        KvIsZero(simd_dot(lhs, rhs), eps: eps) && isNonzero(lhs) && isNonzero(rhs)
    }

    /// - Returns: A boolean value indicating whether given vectors are both nonzero and orthogonal.
    @inlinable
    public static func isOrthogonal(_ lhs: Vector3, _ rhs: Vector3) -> Bool {
        KvIsZero(simd_dot(lhs, rhs), eps: epsArg(lhs).dot(epsArg(rhs)).tolerance) && isNonzero(lhs) && isNonzero(rhs)
    }

    /// - Returns: A boolean value indicating whether given vectors are both nonzero and orthogonal.
    @inlinable
    public static func isOrthogonal(_ lhs: Vector3, _ rhs: Vector3, eps: Eps) -> Bool {
        KvIsZero(simd_dot(lhs, rhs), eps: eps) && isNonzero(lhs) && isNonzero(rhs)
    }

    /// - Returns: A boolean value indicating whether given vectors are both nonzero and orthogonal.
    @inlinable
    public static func isOrthogonal(_ lhs: Vector4, _ rhs: Vector4) -> Bool {
        KvIsZero(simd_dot(lhs, rhs), eps: epsArg(lhs).dot(epsArg(rhs)).tolerance) && isNonzero(lhs) && isNonzero(rhs)
    }

    /// - Returns: A boolean value indicating whether given vectors are both nonzero and orthogonal.
    @inlinable
    public static func isOrthogonal(_ lhs: Vector4, _ rhs: Vector4, eps: Eps) -> Bool {
        KvIsZero(simd_dot(lhs, rhs), eps: eps) && isNonzero(lhs) && isNonzero(rhs)
    }


    /// - Returns: A boolean value indicating wheather given vector is numerically inequal to zero.
    @inlinable public static func isNonzero(_ v: Vector2) -> Bool { KvIsNonzero(abs(v).max()) }

    /// - Returns: A boolean value indicating wheather given vector is numerically inequal to zero.
    @inlinable public static func isNonzero(_ v: Vector2, eps: Eps) -> Bool { KvIsNonzero(abs(v).max(), eps: eps) }

    /// - Returns: A boolean value indicating wheather given vector is numerically inequal to zero.
    @inlinable public static func isNonzero(_ v: Vector3) -> Bool { KvIsNonzero(abs(v).max()) }

    /// - Returns: A boolean value indicating wheather given vector is numerically inequal to zero.
    @inlinable public static func isNonzero(_ v: Vector3, eps: Eps) -> Bool { KvIsNonzero(abs(v).max(), eps: eps) }

    /// - Returns: A boolean value indicating wheather given vector is numerically inequal to zero.
    @inlinable public static func isNonzero(_ v: Vector4) -> Bool { KvIsNonzero(abs(v).max()) }

    /// - Returns: A boolean value indicating wheather given vector is numerically inequal to zero.
    @inlinable public static func isNonzero(_ v: Vector4, eps: Eps) -> Bool { KvIsNonzero(abs(v).max(), eps: eps) }

    /// - Returns: A boolean value indicating wheather given quaternion is numerically inequal to zero quaternion.
    @inlinable public static func isNonzero(_ q: Quaternion) -> Bool { isNonzero(q.vector) }

    /// - Returns: A boolean value indicating wheather given quaternion is numerically inequal to zero quaternion.
    @inlinable public static func isNonzero(_ q: Quaternion, eps: Eps) -> Bool { isNonzero(q.vector, eps: eps) }

    /// - Returns: A boolean value indicating wheather given matrix is numerically inequal to zero matrix.
    @inlinable public static func isNonzero(_ m: Matrix2x2) -> Bool { KvIsNonzero(max(abs(m))) }

    /// - Returns: A boolean value indicating wheather given matrix is numerically inequal to zero matrix.
    @inlinable public static func isNonzero(_ m: Matrix2x2, eps: Eps) -> Bool { KvIsNonzero(max(abs(m)), eps: eps) }

    /// - Returns: A boolean value indicating wheather given matrix is numerically inequal to zero matrix.
    @inlinable public static func isNonzero(_ m: Matrix3x3) -> Bool { KvIsNonzero(max(abs(m))) }

    /// - Returns: A boolean value indicating wheather given matrix is numerically inequal to zero matrix.
    @inlinable public static func isNonzero(_ m: Matrix3x3, eps: Eps) -> Bool { KvIsNonzero(max(abs(m)), eps: eps) }

    /// - Returns: A boolean value indicating wheather given matrix is numerically inequal to zero matrix.
    @inlinable public static func isNonzero(_ m: Matrix4x4) -> Bool { KvIsNonzero(max(abs(m))) }

    /// - Returns: A boolean value indicating wheather given matrix is numerically inequal to zero matrix.
    @inlinable public static func isNonzero(_ m: Matrix4x4, eps: Eps) -> Bool { KvIsNonzero(max(abs(m)), eps: eps) }


    /// - Returns: A boolean value indicating whether given vector is of unit length.
    @inlinable public static func isUnit(_ v: Vector2) -> Bool { KvIs(length²(v), equalTo: 1) }

    /// - Returns: A boolean value indicating whether given vector is of unit length.
    @inlinable public static func isUnit(_ v: Vector2, eps: Eps) -> Bool { KvIs(length²(v), equalTo: 1, eps: eps) }

    /// - Returns: A boolean value indicating whether given vector is of unit length.
    @inlinable public static func isUnit(_ v: Vector3) -> Bool { KvIs(length²(v), equalTo: 1) }

    /// - Returns: A boolean value indicating whether given vector is of unit length.
    @inlinable public static func isUnit(_ v: Vector3, eps: Eps) -> Bool { KvIs(length²(v), equalTo: 1, eps: eps) }

    /// - Returns: A boolean value indicating whether given vector is of unit length.
    @inlinable public static func isUnit(_ v: Vector4) -> Bool { KvIs(length²(v), equalTo: 1) }

    /// - Returns: A boolean value indicating whether given vector is of unit length.
    @inlinable public static func isUnit(_ v: Vector4, eps: Eps) -> Bool { KvIs(length²(v), equalTo: 1, eps: eps) }


    /// - Returns: A boolean value indicating wheather given vector is numerically equal to zero.
    @inlinable public static func isZero(_ v: Vector2) -> Bool { KvIsZero(abs(v).max()) }

    /// - Returns: A boolean value indicating wheather given vector is numerically equal to zero.
    @inlinable public static func isZero(_ v: Vector2, eps: Eps) -> Bool { KvIsZero(abs(v).max(), eps: eps) }

    /// - Returns: A boolean value indicating wheather given vector is numerically equal to zero.
    @inlinable public static func isZero(_ v: Vector3) -> Bool { KvIsZero(abs(v).max()) }

    /// - Returns: A boolean value indicating wheather given vector is numerically equal to zero.
    @inlinable public static func isZero(_ v: Vector3, eps: Eps) -> Bool { KvIsZero(abs(v).max(), eps: eps) }

    /// - Returns: A boolean value indicating wheather given vector is numerically equal to zero.
    @inlinable public static func isZero(_ v: Vector4) -> Bool { KvIsZero(abs(v).max()) }

    /// - Returns: A boolean value indicating wheather given vector is numerically equal to zero.
    @inlinable public static func isZero(_ v: Vector4, eps: Eps) -> Bool { KvIsZero(abs(v).max(), eps: eps) }

    /// - Returns: A boolean value indicating wheather given vector is numerically equal to zero quaternion.
    @inlinable public static func isZero(_ q: Quaternion) -> Bool { isZero(q.vector) }

    /// - Returns: A boolean value indicating wheather given vector is numerically equal to zero quaternion.
    @inlinable public static func isZero(_ q: Quaternion, eps: Eps) -> Bool { isZero(q.vector, eps: eps) }

    /// - Returns: A boolean value indicating wheather given matrix is numerically equal to zero matrix.
    @inlinable public static func isZero(_ m: Matrix2x2) -> Bool { KvIsZero(max(abs(m))) }

    /// - Returns: A boolean value indicating wheather given matrix is numerically equal to zero matrix.
    @inlinable public static func isZero(_ m: Matrix2x2, eps: Eps) -> Bool { KvIsZero(max(abs(m)), eps: eps) }

    /// - Returns: A boolean value indicating wheather given matrix is numerically equal to zero matrix.
    @inlinable public static func isZero(_ m: Matrix3x3) -> Bool { KvIsZero(max(abs(m))) }

    /// - Returns: A boolean value indicating wheather given matrix is numerically equal to zero matrix.
    @inlinable public static func isZero(_ m: Matrix3x3, eps: Eps) -> Bool { KvIsZero(max(abs(m)), eps: eps) }

    /// - Returns: A boolean value indicating wheather given matrix is numerically equal to zero matrix.
    @inlinable public static func isZero(_ m: Matrix4x4) -> Bool { KvIsZero(max(abs(m))) }

    /// - Returns: A boolean value indicating wheather given matrix is numerically equal to zero matrix.
    @inlinable public static func isZero(_ m: Matrix4x4, eps: Eps) -> Bool { KvIsZero(max(abs(m)), eps: eps) }


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

    @inlinable public static func max(_ lhs: Matrix2x2, _ rhs: Matrix2x2) -> Matrix2x2 { Matrix2x2(max(lhs[0], rhs[0]), max(lhs[1], rhs[1])) }

    @inlinable public static func max(_ lhs: Matrix3x3, _ rhs: Matrix3x3) -> Matrix3x3 { Matrix3x3(max(lhs[0], rhs[0]), max(lhs[1], rhs[1]), max(lhs[2], rhs[2])) }

    @inlinable public static func max(_ lhs: Matrix4x4, _ rhs: Matrix4x4) -> Matrix4x4 { Matrix4x4(max(lhs[0], rhs[0]), max(lhs[1], rhs[1]), max(lhs[2], rhs[2]), max(lhs[3], rhs[3])) }


    /// - Returns: Minimum element in the receiver.
    @inlinable public static func min(_ m: Matrix2x2) -> Scalar { Swift.min(m[0].min(), m[1].min()) }

    /// - Returns: Minimum element in the receiver.
    @inlinable public static func min(_ m: Matrix3x3) -> Scalar { Swift.min(m[0].min(), m[1].min(), m[2].min()) }

    /// - Returns: Minimum element in the receiver.
    @inlinable public static func min(_ m: Matrix4x4) -> Scalar { Swift.min(m[0].min(), m[1].min(), m[2].min(), m[3].min()) }


    @inlinable public static func min(_ lhs: Vector2, _ rhs: Vector2) -> Vector2 { simd_min(lhs, rhs) }

    @inlinable public static func min(_ lhs: Vector3, _ rhs: Vector3) -> Vector3 { simd_min(lhs, rhs) }

    @inlinable public static func min(_ lhs: Vector4, _ rhs: Vector4) -> Vector4 { simd_min(lhs, rhs) }

    @inlinable public static func min(_ lhs: Matrix2x2, _ rhs: Matrix2x2) -> Matrix2x2 { Matrix2x2(min(lhs[0], rhs[0]), min(lhs[1], rhs[1])) }

    @inlinable public static func min(_ lhs: Matrix3x3, _ rhs: Matrix3x3) -> Matrix3x3 { Matrix3x3(min(lhs[0], rhs[0]), min(lhs[1], rhs[1]), min(lhs[2], rhs[2])) }

    @inlinable public static func min(_ lhs: Matrix4x4, _ rhs: Matrix4x4) -> Matrix4x4 { Matrix4x4(min(lhs[0], rhs[0]), min(lhs[1], rhs[1]), min(lhs[2], rhs[2]), min(lhs[3], rhs[3])) }


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


    @inlinable public static func rsqrt(_ x: Scalar) -> Scalar { simd_rsqrt(x) }

    @inlinable public static func rsqrt(_ v: Vector2) -> Vector2 { simd_rsqrt(v) }

    @inlinable public static func rsqrt(_ v: Vector3) -> Vector3 { simd_rsqrt(v) }

    @inlinable public static func rsqrt(_ v: Vector4) -> Vector4 { simd_rsqrt(v) }


    /// - Returns: Normalized vector or *nil* whether *v* is nondegenerate.
    @inlinable
    public static func safeNormalize(_ v: Vector2) -> Vector2? {
        guard isNonzero(v) else { return nil }
        return normalize(v)
    }

    /// - Returns: Normalized vector or *nil* whether *v* is nondegenerate.
    @inlinable
    public static func safeNormalize(_ v: Vector3) -> Vector3? {
        guard isNonzero(v) else { return nil }
        return normalize(v)
    }

    /// - Returns: Normalized vector or *nil* whether *v* is nondegenerate.
    @inlinable
    public static func safeNormalize(_ v: Vector4) -> Vector4? {
        guard isNonzero(v) else { return nil }
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


    /// - Returns: Tolerance argument for numerical comparisons depending on a vector value.
    @inlinable public static func epsArg(_ v: Vector2) -> EpsArg2 { EpsArg2(v) }

    /// - Returns: Tolerance argument for numerical comparisons depending on a vector value.
    @inlinable public static func epsArg(_ v: Vector3) -> EpsArg3 { EpsArg3(v) }

    /// - Returns: Tolerance argument for numerical comparisons depending on a vector value.
    @inlinable public static func epsArg(_ v: Vector4) -> EpsArg4 { EpsArg4(v) }

    /// - Returns: Tolerance argument for numerical comparisons depending on a matrix value.
    @inlinable public static func epsArg(_ m: Matrix2x2) -> EpsArg2x2 { EpsArg2x2(m) }

    /// - Returns: Tolerance argument for numerical comparisons depending on a matrix value.
    @inlinable public static func epsArg(_ m: Matrix3x3) -> EpsArg3x3 { EpsArg3x3(m) }

    /// - Returns: Tolerance argument for numerical comparisons depending on a matrix value.
    @inlinable public static func epsArg(_ m: Matrix4x4) -> EpsArg4x4 { EpsArg4x4(m) }


    /// - Returns: A boolean value indicating wheather given vectors are co-directional.
    ///
    /// - Note: Two zero vectors are not co-directional.
    @inlinable
    public static func isCoDirectional(_ lhs: Vector2, _ rhs: Vector2) -> Bool {
        KvIsPositive(simd_dot(lhs, rhs), eps: epsArg(lhs).dot(epsArg(rhs)).tolerance)
        && KvIsZero(cross(lhs, rhs).z, eps: epsArg(lhs).cross(epsArg(rhs)).tolerance)
    }

    /// - Returns: A boolean value indicating wheather given vectors are co-directional.
    ///
    /// - Note: Two zero vectors are not co-directional.
    @inlinable
    public static func isCoDirectional(_ lhs: Vector3, _ rhs: Vector3) -> Bool {
        KvIsPositive(simd_dot(lhs, rhs), eps: epsArg(lhs).dot(epsArg(rhs)).tolerance)
        && isZero(cross(lhs, rhs), eps: epsArg(lhs).cross(epsArg(rhs)).tolerance)
    }

    /// - Returns: A boolean value indicating wheather given vectors are co-directional.
    ///
    /// - Note: Two zero vectors are not co-directional.
    @inlinable
    public static func isCoDirectional(_ lhs: Vector4, _ rhs: Vector4) -> Bool {
        guard let lhs = safeNormalize(lhs),
              let rhs = safeNormalize(rhs)
        else { return false }

        return isEqual(lhs, rhs)
    }


    /// - Returns: A boolean value indicating wheather given vectors are collinear.
    ///
    /// - Note: *False* is returned if any of given vectors is zero.
    @inlinable
    public static func isCollinear(_ lhs: Vector2, _ rhs: Vector2) -> Bool {
        KvIsNonzero(simd_dot(lhs, rhs), eps: epsArg(lhs).dot(epsArg(rhs)).tolerance)    // Both vectors are nonzero
        && KvIsZero(cross(lhs, rhs).z, eps: epsArg(lhs).cross(epsArg(rhs)).tolerance)
    }

    /// - Returns: A boolean value indicating wheather given vectors are collinear.
    ///
    /// - Note: *False* is returned if any of given vectors is zero.
    @inlinable
    public static func isCollinear(_ lhs: Vector3, _ rhs: Vector3) -> Bool {
        KvIsNonzero(simd_dot(lhs, rhs), eps: epsArg(lhs).dot(epsArg(rhs)).tolerance)    // Both vectors are nonzero
        && isZero(cross(lhs, rhs), eps: epsArg(lhs).cross(epsArg(rhs)).tolerance)
    }

    /// - Returns: A boolean value indicating wheather given vectors are collinear.
    ///
    /// - Note: *False* is returned if any of given vectors is zero.
    @inlinable
    public static func isCollinear(_ lhs: Vector4, _ rhs: Vector4) -> Bool {
        guard let lhs = safeNormalize(lhs),
              let rhs = safeNormalize(rhs)
        else { return false }

        return isEqual(lhs, rhs) || isEqual(lhs, -rhs)
    }


    /// - Returns: A boolean value indicating wheather given vectors are inequal.
    @inlinable
    public static func isInequal(_ lhs: Vector2, _ rhs: Vector2) -> Bool {
        isInequal(lhs, rhs, eps: (epsArg(lhs) - epsArg(rhs)).tolerance)
    }

    /// - Returns: A boolean value indicating wheather given vectors are inequal.
    @inlinable
    public static func isInequal(_ lhs: Vector2, _ rhs: Vector2, eps: Eps) -> Bool {
        KvIsNonzero(abs(rhs - lhs).max(), eps: eps)
    }

    /// - Returns: A boolean value indicating wheather given vectors are inequal.
    @inlinable
    public static func isInequal(_ lhs: Vector3, _ rhs: Vector3) -> Bool {
        isInequal(lhs, rhs, eps: (epsArg(lhs) - epsArg(rhs)).tolerance)
    }

    /// - Returns: A boolean value indicating wheather given vectors are inequal.
    @inlinable
    public static func isInequal(_ lhs: Vector3, _ rhs: Vector3, eps: Eps) -> Bool {
        KvIsNonzero(abs(rhs - lhs).max(), eps: eps)
    }

    /// - Returns: A boolean value indicating wheather given vectors are inequal.
    @inlinable
    public static func isInequal(_ lhs: Vector4, _ rhs: Vector4) -> Bool {
        isInequal(lhs, rhs, eps: (epsArg(lhs) - epsArg(rhs)).tolerance)
    }

    /// - Returns: A boolean value indicating wheather given vectors are inequal.
    @inlinable
    public static func isInequal(_ lhs: Vector4, _ rhs: Vector4, eps: Eps) -> Bool {
        KvIsNonzero(abs(rhs - lhs).max(), eps: eps)
    }

    /// - Returns: A boolean value indicating wheather given quaternions are inequal.
    @inlinable public static func isInequal(_ lhs: Quaternion, _ rhs: Quaternion) -> Bool { isInequal(lhs.vector, rhs.vector) }

    /// - Returns: A boolean value indicating wheather given quaternions are inequal.
    @inlinable public static func isInequal(_ lhs: Quaternion, _ rhs: Quaternion, eps: Eps) -> Bool { isInequal(lhs.vector, rhs.vector, eps: eps) }

    /// - Returns: A boolean value indicating wheather given matrices are inequal.
    @inlinable
    public static func isInequal(_ lhs: Matrix2x2, _ rhs: Matrix2x2) -> Bool {
        isInequal(lhs, rhs, eps: EpsArg(max(abs(lhs)), max(abs(rhs))).tolerance)
    }

    /// - Returns: A boolean value indicating wheather given matrices are inequal.
    @inlinable
    public static func isInequal(_ lhs: Matrix2x2, _ rhs: Matrix2x2, eps: Eps) -> Bool {
        isInequal(lhs[0], rhs[0], eps: eps)
        || isInequal(lhs[1], rhs[1], eps: eps)
    }

    /// - Returns: A boolean value indicating wheather given matrices are inequal.
    @inlinable
    public static func isInequal(_ lhs: Matrix3x3, _ rhs: Matrix3x3) -> Bool {
        isInequal(lhs, rhs, eps: EpsArg(max(abs(lhs)), max(abs(rhs))).tolerance)
    }

    /// - Returns: A boolean value indicating wheather given matrices are inequal.
    @inlinable
    public static func isInequal(_ lhs: Matrix3x3, _ rhs: Matrix3x3, eps: Eps) -> Bool {
        isInequal(lhs[0], rhs[0], eps: eps)
        || isInequal(lhs[1], rhs[1], eps: eps)
        || isInequal(lhs[2], rhs[2], eps: eps)
    }

    /// - Returns: A boolean value indicating wheather given matrices are inequal.
    @inlinable
    public static func isInequal(_ lhs: Matrix4x4, _ rhs: Matrix4x4) -> Bool {
        isInequal(lhs, rhs, eps: EpsArg(max(abs(lhs)), max(abs(rhs))).tolerance)
    }

    /// - Returns: A boolean value indicating wheather given matrices are inequal.
    @inlinable
    public static func isInequal(_ lhs: Matrix4x4, _ rhs: Matrix4x4, eps: Eps) -> Bool {
        isInequal(lhs[0], rhs[0], eps: eps)
        || isInequal(lhs[1], rhs[1], eps: eps)
        || isInequal(lhs[2], rhs[2], eps: eps)
        || isInequal(lhs[3], rhs[3], eps: eps)
    }


    /// - Returns: A boolean value indicating wheather given vectors are equal.
    @inlinable
    public static func isEqual(_ lhs: Vector2, _ rhs: Vector2) -> Bool {
        isEqual(lhs, rhs, eps: (epsArg(lhs) - epsArg(rhs)).tolerance)
    }

    /// - Returns: A boolean value indicating wheather given vectors are equal.
    @inlinable
    public static func isEqual(_ lhs: Vector2, _ rhs: Vector2, eps: Eps) -> Bool {
        KvIsZero(abs(rhs - lhs).max(), eps: eps)
    }

    /// - Returns: A boolean value indicating wheather given vectors are equal.
    @inlinable
    public static func isEqual(_ lhs: Vector3, _ rhs: Vector3) -> Bool {
        isEqual(lhs, rhs, eps: (epsArg(lhs) - epsArg(rhs)).tolerance)
    }

    /// - Returns: A boolean value indicating wheather given vectors are equal.
    @inlinable
    public static func isEqual(_ lhs: Vector3, _ rhs: Vector3, eps: Eps) -> Bool {
        KvIsZero(abs(rhs - lhs).max(), eps: eps)
    }

    /// - Returns: A boolean value indicating wheather given vectors are equal.
    @inlinable
    public static func isEqual(_ lhs: Vector4, _ rhs: Vector4) -> Bool {
        isEqual(lhs, rhs, eps: (epsArg(lhs) - epsArg(rhs)).tolerance)
    }

    /// - Returns: A boolean value indicating wheather given vectors are equal.
    @inlinable
    public static func isEqual(_ lhs: Vector4, _ rhs: Vector4, eps: Eps) -> Bool {
        KvIsZero(abs(rhs - lhs).max(), eps: eps)
    }

    /// - Returns: A boolean value indicating wheather given quaternions are equal.
    @inlinable public static func isEqual(_ lhs: Quaternion, _ rhs: Quaternion) -> Bool { isEqual(lhs.vector, rhs.vector) }

    /// - Returns: A boolean value indicating wheather given quaternions are equal.
    @inlinable public static func isEqual(_ lhs: Quaternion, _ rhs: Quaternion, eps: Eps) -> Bool { isEqual(lhs.vector, rhs.vector, eps: eps) }

    /// - Returns: A boolean value indicating wheather given matrices are equal.
    @inlinable
    public static func isEqual(_ lhs: Matrix2x2, _ rhs: Matrix2x2) -> Bool {
        isEqual(lhs, rhs, eps: EpsArg(max(abs(lhs)), max(abs(rhs))).tolerance)
    }

    /// - Returns: A boolean value indicating wheather given matrices are equal.
    @inlinable
    public static func isEqual(_ lhs: Matrix2x2, _ rhs: Matrix2x2, eps: Eps) -> Bool {
        isEqual(lhs[0], rhs[0], eps: eps)
        && isEqual(lhs[1], rhs[1], eps: eps)
    }

    /// - Returns: A boolean value indicating wheather given matrices are equal.
    @inlinable
    public static func isEqual(_ lhs: Matrix3x3, _ rhs: Matrix3x3) -> Bool {
        isEqual(lhs, rhs, eps: EpsArg(max(abs(lhs)), max(abs(rhs))).tolerance)
    }

    /// - Returns: A boolean value indicating wheather given matrices are equal.
    @inlinable
    public static func isEqual(_ lhs: Matrix3x3, _ rhs: Matrix3x3, eps: Eps) -> Bool {
        isEqual(lhs[0], rhs[0], eps: eps)
        && isEqual(lhs[1], rhs[1], eps: eps)
        && isEqual(lhs[2], rhs[2], eps: eps)
    }

    /// - Returns: A boolean value indicating wheather given matrices are equal.
    @inlinable
    public static func isEqual(_ lhs: Matrix4x4, _ rhs: Matrix4x4) -> Bool {
        isEqual(lhs, rhs, eps: EpsArg(max(abs(lhs)), max(abs(rhs))).tolerance)
    }

    /// - Returns: A boolean value indicating wheather given matrices are equal.
    @inlinable
    public static func isEqual(_ lhs: Matrix4x4, _ rhs: Matrix4x4, eps: Eps) -> Bool {
        isEqual(lhs[0], rhs[0], eps: eps)
        && isEqual(lhs[1], rhs[1], eps: eps)
        && isEqual(lhs[2], rhs[2], eps: eps)
        && isEqual(lhs[3], rhs[3], eps: eps)
    }


    /// - Returns: A boolean value indicating whether given vectors are both nonzero and are not orthogonal.
    @inlinable
    public static func isNonOrthogonal(_ lhs: Vector2, _ rhs: Vector2) -> Bool {
        KvIsNonzero(simd_dot(lhs, rhs), eps: epsArg(lhs).dot(epsArg(rhs)).tolerance)
    }

    /// - Returns: A boolean value indicating whether given vectors are both nonzero and are not orthogonal.
    @inlinable
    public static func isNonOrthogonal(_ lhs: Vector2, _ rhs: Vector2, eps: Eps) -> Bool {
        KvIsNonzero(simd_dot(lhs, rhs), eps: eps)
    }

    /// - Returns: A boolean value indicating whether given vectors are both nonzero and are not orthogonal.
    @inlinable
    public static func isNonOrthogonal(_ lhs: Vector3, _ rhs: Vector3) -> Bool {
        KvIsNonzero(simd_dot(lhs, rhs), eps: epsArg(lhs).dot(epsArg(rhs)).tolerance)
    }

    /// - Returns: A boolean value indicating whether given vectors are both nonzero and are not orthogonal.
    @inlinable
    public static func isNonOrthogonal(_ lhs: Vector3, _ rhs: Vector3, eps: Eps) -> Bool {
        KvIsNonzero(simd_dot(lhs, rhs), eps: eps)
    }

    /// - Returns: A boolean value indicating whether given vectors are both nonzero and are not orthogonal.
    @inlinable
    public static func isNonOrthogonal(_ lhs: Vector4, _ rhs: Vector4) -> Bool {
        KvIsNonzero(simd_dot(lhs, rhs), eps: epsArg(lhs).dot(epsArg(rhs)).tolerance)
    }

    /// - Returns: A boolean value indicating whether given vectors are both nonzero and are not orthogonal.
    @inlinable
    public static func isNonOrthogonal(_ lhs: Vector4, _ rhs: Vector4, eps: Eps) -> Bool {
        KvIsNonzero(simd_dot(lhs, rhs), eps: eps)
    }


    /// - Returns: A boolean value indicating whether given vectors are both nonzero and orthogonal.
    @inlinable
    public static func isOrthogonal(_ lhs: Vector2, _ rhs: Vector2) -> Bool {
        KvIsZero(simd_dot(lhs, rhs), eps: epsArg(lhs).dot(epsArg(rhs)).tolerance) && isNonzero(lhs) && isNonzero(rhs)
    }

    /// - Returns: A boolean value indicating whether given vectors are both nonzero and orthogonal.
    @inlinable
    public static func isOrthogonal(_ lhs: Vector2, _ rhs: Vector2, eps: Eps) -> Bool {
        KvIsZero(simd_dot(lhs, rhs), eps: eps) && isNonzero(lhs) && isNonzero(rhs)
    }

    /// - Returns: A boolean value indicating whether given vectors are both nonzero and orthogonal.
    @inlinable
    public static func isOrthogonal(_ lhs: Vector3, _ rhs: Vector3) -> Bool {
        KvIsZero(simd_dot(lhs, rhs), eps: epsArg(lhs).dot(epsArg(rhs)).tolerance) && isNonzero(lhs) && isNonzero(rhs)
    }

    /// - Returns: A boolean value indicating whether given vectors are both nonzero and orthogonal.
    @inlinable
    public static func isOrthogonal(_ lhs: Vector3, _ rhs: Vector3, eps: Eps) -> Bool {
        KvIsZero(simd_dot(lhs, rhs), eps: eps) && isNonzero(lhs) && isNonzero(rhs)
    }

    /// - Returns: A boolean value indicating whether given vectors are both nonzero and orthogonal.
    @inlinable
    public static func isOrthogonal(_ lhs: Vector4, _ rhs: Vector4) -> Bool {
        KvIsZero(simd_dot(lhs, rhs), eps: epsArg(lhs).dot(epsArg(rhs)).tolerance) && isNonzero(lhs) && isNonzero(rhs)
    }

    /// - Returns: A boolean value indicating whether given vectors are both nonzero and orthogonal.
    @inlinable
    public static func isOrthogonal(_ lhs: Vector4, _ rhs: Vector4, eps: Eps) -> Bool {
        KvIsZero(simd_dot(lhs, rhs), eps: eps) && isNonzero(lhs) && isNonzero(rhs)
    }


    /// - Returns: A boolean value indicating wheather given vector is numerically inequal to zero.
    @inlinable public static func isNonzero(_ v: Vector2) -> Bool { KvIsNonzero(abs(v).max()) }

    /// - Returns: A boolean value indicating wheather given vector is numerically inequal to zero.
    @inlinable public static func isNonzero(_ v: Vector2, eps: Eps) -> Bool { KvIsNonzero(abs(v).max(), eps: eps) }

    /// - Returns: A boolean value indicating wheather given vector is numerically inequal to zero.
    @inlinable public static func isNonzero(_ v: Vector3) -> Bool { KvIsNonzero(abs(v).max()) }

    /// - Returns: A boolean value indicating wheather given vector is numerically inequal to zero.
    @inlinable public static func isNonzero(_ v: Vector3, eps: Eps) -> Bool { KvIsNonzero(abs(v).max(), eps: eps) }

    /// - Returns: A boolean value indicating wheather given vector is numerically inequal to zero.
    @inlinable public static func isNonzero(_ v: Vector4) -> Bool { KvIsNonzero(abs(v).max()) }

    /// - Returns: A boolean value indicating wheather given vector is numerically inequal to zero.
    @inlinable public static func isNonzero(_ v: Vector4, eps: Eps) -> Bool { KvIsNonzero(abs(v).max(), eps: eps) }

    /// - Returns: A boolean value indicating wheather given quaternion is numerically inequal to zero quaternion.
    @inlinable public static func isNonzero(_ q: Quaternion) -> Bool { isNonzero(q.vector) }

    /// - Returns: A boolean value indicating wheather given quaternion is numerically inequal to zero quaternion.
    @inlinable public static func isNonzero(_ q: Quaternion, eps: Eps) -> Bool { isNonzero(q.vector, eps: eps) }

    /// - Returns: A boolean value indicating wheather given matrix is numerically inequal to zero matrix.
    @inlinable public static func isNonzero(_ m: Matrix2x2) -> Bool { KvIsNonzero(max(abs(m))) }

    /// - Returns: A boolean value indicating wheather given matrix is numerically inequal to zero matrix.
    @inlinable public static func isNonzero(_ m: Matrix2x2, eps: Eps) -> Bool { KvIsNonzero(max(abs(m)), eps: eps) }

    /// - Returns: A boolean value indicating wheather given matrix is numerically inequal to zero matrix.
    @inlinable public static func isNonzero(_ m: Matrix3x3) -> Bool { KvIsNonzero(max(abs(m))) }

    /// - Returns: A boolean value indicating wheather given matrix is numerically inequal to zero matrix.
    @inlinable public static func isNonzero(_ m: Matrix3x3, eps: Eps) -> Bool { KvIsNonzero(max(abs(m)), eps: eps) }

    /// - Returns: A boolean value indicating wheather given matrix is numerically inequal to zero matrix.
    @inlinable public static func isNonzero(_ m: Matrix4x4) -> Bool { KvIsNonzero(max(abs(m))) }

    /// - Returns: A boolean value indicating wheather given matrix is numerically inequal to zero matrix.
    @inlinable public static func isNonzero(_ m: Matrix4x4, eps: Eps) -> Bool { KvIsNonzero(max(abs(m)), eps: eps) }


    /// - Returns: A boolean value indicating whether given vector is of unit length.
    @inlinable public static func isUnit(_ v: Vector2) -> Bool { KvIs(length²(v), equalTo: 1) }

    /// - Returns: A boolean value indicating whether given vector is of unit length.
    @inlinable public static func isUnit(_ v: Vector2, eps: Eps) -> Bool { KvIs(length²(v), equalTo: 1, eps: eps) }

    /// - Returns: A boolean value indicating whether given vector is of unit length.
    @inlinable public static func isUnit(_ v: Vector3) -> Bool { KvIs(length²(v), equalTo: 1) }

    /// - Returns: A boolean value indicating whether given vector is of unit length.
    @inlinable public static func isUnit(_ v: Vector3, eps: Eps) -> Bool { KvIs(length²(v), equalTo: 1, eps: eps) }

    /// - Returns: A boolean value indicating whether given vector is of unit length.
    @inlinable public static func isUnit(_ v: Vector4) -> Bool { KvIs(length²(v), equalTo: 1) }

    /// - Returns: A boolean value indicating whether given vector is of unit length.
    @inlinable public static func isUnit(_ v: Vector4, eps: Eps) -> Bool { KvIs(length²(v), equalTo: 1, eps: eps) }


    /// - Returns: A boolean value indicating wheather given vector is numerically equal to zero.
    @inlinable public static func isZero(_ v: Vector2) -> Bool { KvIsZero(abs(v).max()) }

    /// - Returns: A boolean value indicating wheather given vector is numerically equal to zero.
    @inlinable public static func isZero(_ v: Vector2, eps: Eps) -> Bool { KvIsZero(abs(v).max(), eps: eps) }

    /// - Returns: A boolean value indicating wheather given vector is numerically equal to zero.
    @inlinable public static func isZero(_ v: Vector3) -> Bool { KvIsZero(abs(v).max()) }

    /// - Returns: A boolean value indicating wheather given vector is numerically equal to zero.
    @inlinable public static func isZero(_ v: Vector3, eps: Eps) -> Bool { KvIsZero(abs(v).max(), eps: eps) }

    /// - Returns: A boolean value indicating wheather given vector is numerically equal to zero.
    @inlinable public static func isZero(_ v: Vector4) -> Bool { KvIsZero(abs(v).max()) }

    /// - Returns: A boolean value indicating wheather given vector is numerically equal to zero.
    @inlinable public static func isZero(_ v: Vector4, eps: Eps) -> Bool { KvIsZero(abs(v).max(), eps: eps) }

    /// - Returns: A boolean value indicating wheather given vector is numerically equal to zero quaternion.
    @inlinable public static func isZero(_ q: Quaternion) -> Bool { isZero(q.vector) }

    /// - Returns: A boolean value indicating wheather given vector is numerically equal to zero quaternion.
    @inlinable public static func isZero(_ q: Quaternion, eps: Eps) -> Bool { isZero(q.vector, eps: eps) }

    /// - Returns: A boolean value indicating wheather given matrix is numerically equal to zero matrix.
    @inlinable public static func isZero(_ m: Matrix2x2) -> Bool { KvIsZero(max(abs(m))) }

    /// - Returns: A boolean value indicating wheather given matrix is numerically equal to zero matrix.
    @inlinable public static func isZero(_ m: Matrix2x2, eps: Eps) -> Bool { KvIsZero(max(abs(m)), eps: eps) }

    /// - Returns: A boolean value indicating wheather given matrix is numerically equal to zero matrix.
    @inlinable public static func isZero(_ m: Matrix3x3) -> Bool { KvIsZero(max(abs(m))) }

    /// - Returns: A boolean value indicating wheather given matrix is numerically equal to zero matrix.
    @inlinable public static func isZero(_ m: Matrix3x3, eps: Eps) -> Bool { KvIsZero(max(abs(m)), eps: eps) }

    /// - Returns: A boolean value indicating wheather given matrix is numerically equal to zero matrix.
    @inlinable public static func isZero(_ m: Matrix4x4) -> Bool { KvIsZero(max(abs(m))) }

    /// - Returns: A boolean value indicating wheather given matrix is numerically equal to zero matrix.
    @inlinable public static func isZero(_ m: Matrix4x4, eps: Eps) -> Bool { KvIsZero(max(abs(m)), eps: eps) }


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

    @inlinable public static func max(_ lhs: Matrix2x2, _ rhs: Matrix2x2) -> Matrix2x2 { Matrix2x2(max(lhs[0], rhs[0]), max(lhs[1], rhs[1])) }

    @inlinable public static func max(_ lhs: Matrix3x3, _ rhs: Matrix3x3) -> Matrix3x3 { Matrix3x3(max(lhs[0], rhs[0]), max(lhs[1], rhs[1]), max(lhs[2], rhs[2])) }

    @inlinable public static func max(_ lhs: Matrix4x4, _ rhs: Matrix4x4) -> Matrix4x4 { Matrix4x4(max(lhs[0], rhs[0]), max(lhs[1], rhs[1]), max(lhs[2], rhs[2]), max(lhs[3], rhs[3])) }


    /// - Returns: Minimum element in the receiver.
    @inlinable public static func min(_ m: Matrix2x2) -> Scalar { Swift.min(m[0].min(), m[1].min()) }

    /// - Returns: Minimum element in the receiver.
    @inlinable public static func min(_ m: Matrix3x3) -> Scalar { Swift.min(m[0].min(), m[1].min(), m[2].min()) }

    /// - Returns: Minimum element in the receiver.
    @inlinable public static func min(_ m: Matrix4x4) -> Scalar { Swift.min(m[0].min(), m[1].min(), m[2].min(), m[3].min()) }


    @inlinable public static func min(_ lhs: Vector2, _ rhs: Vector2) -> Vector2 { simd_min(lhs, rhs) }

    @inlinable public static func min(_ lhs: Vector3, _ rhs: Vector3) -> Vector3 { simd_min(lhs, rhs) }

    @inlinable public static func min(_ lhs: Vector4, _ rhs: Vector4) -> Vector4 { simd_min(lhs, rhs) }

    @inlinable public static func min(_ lhs: Matrix2x2, _ rhs: Matrix2x2) -> Matrix2x2 { Matrix2x2(min(lhs[0], rhs[0]), min(lhs[1], rhs[1])) }

    @inlinable public static func min(_ lhs: Matrix3x3, _ rhs: Matrix3x3) -> Matrix3x3 { Matrix3x3(min(lhs[0], rhs[0]), min(lhs[1], rhs[1]), min(lhs[2], rhs[2])) }

    @inlinable public static func min(_ lhs: Matrix4x4, _ rhs: Matrix4x4) -> Matrix4x4 { Matrix4x4(min(lhs[0], rhs[0]), min(lhs[1], rhs[1]), min(lhs[2], rhs[2]), min(lhs[3], rhs[3])) }


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


    @inlinable public static func rsqrt(_ x: Scalar) -> Scalar { simd_rsqrt(x) }

    @inlinable public static func rsqrt(_ v: Vector2) -> Vector2 { simd_rsqrt(v) }

    @inlinable public static func rsqrt(_ v: Vector3) -> Vector3 { simd_rsqrt(v) }

    @inlinable public static func rsqrt(_ v: Vector4) -> Vector4 { simd_rsqrt(v) }


    /// - Returns: Normalized vector or *nil* whether *v* is nondegenerate.
    @inlinable
    public static func safeNormalize(_ v: Vector2) -> Vector2? {
        guard isNonzero(v) else { return nil }
        return normalize(v)
    }

    /// - Returns: Normalized vector or *nil* whether *v* is nondegenerate.
    @inlinable
    public static func safeNormalize(_ v: Vector3) -> Vector3? {
        guard isNonzero(v) else { return nil }
        return normalize(v)
    }

    /// - Returns: Normalized vector or *nil* whether *v* is nondegenerate.
    @inlinable
    public static func safeNormalize(_ v: Vector4) -> Vector4? {
        guard isNonzero(v) else { return nil }
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



// MARK: - .KvNumericalToleranceVectorArgument2

/// Vector tolerance argument.
public struct KvNumericalToleranceVectorArgument2<Math : KvMathScope> : Hashable {

    public typealias Tolerance = Math.Eps

    public typealias Vector = Math.Vector2


    public let value: Vector


    /// Memerwise initializer.
    @usableFromInline
    internal init(value: Vector) {
        Swift.assert(value.min() >= 0, "Invalid argument: all components of a tolerance argument value (\(value)) must be positive")

        self.value = value
    }

    @usableFromInline
    internal init(values v1: Vector, _ v2: Vector) {
        Swift.assert(v1.min() >= 0, "Invalid argument: all components of a tolerance argument value (\(v1)) must be positive")
        Swift.assert(v2.min() >= 0, "Invalid argument: all components of a tolerance argument value (\(v2)) must be positive")

        self.value = Math.max(v1, v2)
    }

    @usableFromInline
    internal init(values v1: Vector, _ v2: Vector, _ v3: Vector) {
        Swift.assert(v1.min() >= 0, "Invalid argument: all components of a tolerance argument value (\(v1)) must be positive")
        Swift.assert(v2.min() >= 0, "Invalid argument: all components of a tolerance argument value (\(v2)) must be positive")
        Swift.assert(v3.min() >= 0, "Invalid argument: all components of a tolerance argument value (\(v3)) must be positive")

        self.value = Math.max(Math.max(v1, v2), v3)
    }

    @usableFromInline
    internal init(values v1: Vector, _ v2: Vector, _ v3: Vector, _ v4: Vector) {
        Swift.assert(v1.min() >= 0, "Invalid argument: all components of a tolerance argument value (\(v1)) must be positive")
        Swift.assert(v2.min() >= 0, "Invalid argument: all components of a tolerance argument value (\(v2)) must be positive")
        Swift.assert(v3.min() >= 0, "Invalid argument: all components of a tolerance argument value (\(v3)) must be positive")
        Swift.assert(v4.min() >= 0, "Invalid argument: all components of a tolerance argument value (\(v4)) must be positive")

        self.value = Math.max(Math.max(v1, v2), Math.max(v3, v4))
    }

    /// Zero argument initializer.
    @inlinable public init() { value = .zero }

    /// Initializes single argument tolerance.
    @inlinable public init(_ arg: Vector) { self.init(value: Math.abs(arg)) }

    /// Initializes tolerance by simple combination of two arguments.
    @inlinable public init(_ a1: Vector, _ a2: Vector) { self.init(values: Math.abs(a1), Math.abs(a2)) }

    /// Initializes tolerance by simple combination of three arguments.
    @inlinable public init(_ a1: Vector, _ a2: Vector, _ a3: Vector) { self.init(values: Math.abs(a1), Math.abs(a2), Math.abs(a3)) }

    /// Initializes tolerance by simple combination of three arguments.
    @inlinable public init(_ a1: Vector, _ a2: Vector, _ a3: Vector, _ a4: Vector) { self.init(values: Math.abs(a1), Math.abs(a2), Math.abs(a3), Math.abs(a4)) }


    // MARK: Auxiliaries

    @inlinable public static var zero: Self { Self() }


    // MARK: Operations

    @inlinable public var scalar: Math.EpsArg { Math.EpsArg(value: value.max()) }

    @inlinable public var tolerance: Tolerance { Tolerance(scalar) }


    /// - Returns: A tolerance of a sum.
    @inlinable public static func +(lhs: Self, rhs: Self) -> Self { Self(value: lhs.value + rhs.value) }

    /// - Returns: A tolerance of a subtraction.
    @inlinable public static func -(lhs: Self, rhs: Self) -> Self { Self(value: lhs.value + rhs.value) }

    /// - Returns: A tolerance of a memberwise product.
    @inlinable public static func *(lhs: Self, rhs: Self) -> Self { Self(value: 2 * lhs.value * rhs.value) }

    /// - Returns: A tolerance of a division.
    @inlinable public static func /(lhs: Self, rhs: Self) -> Self { Self(value: 2 * lhs.value / rhs.value) }

    /// - Returns: A tolerance of a dot product.
    @inlinable public func dot(_ rhs: Self) -> Math.EpsArg { Math.EpsArg(values: value.max(), rhs.value.max(), 2 * Math.dot(value, rhs.value)) }

    /// - Returns: A tolerance of a cross product Z coordinate.
    @inlinable
    public func cross(_ rhs: Self) -> Math.EpsArg {
        Math.EpsArg(values: value.max(), rhs.value.max(), 2 * (value.x * rhs.value.y + value.y * rhs.value.x))
    }

}



// MARK: - .KvNumericalToleranceVectorArgument3

/// Vector tolerance argument.
public struct KvNumericalToleranceVectorArgument3<Math : KvMathScope> : Hashable {

    public typealias Tolerance = Math.Eps

    public typealias Vector = Math.Vector3


    public let value: Vector


    /// Memerwise initializer.
    @usableFromInline
    internal init(value: Vector) {
        Swift.assert(value.min() >= 0, "Invalid argument: all components of a tolerance argument value (\(value)) must be positive")

        self.value = value
    }

    @usableFromInline
    internal init(values v1: Vector, _ v2: Vector) {
        Swift.assert(v1.min() >= 0, "Invalid argument: all components of a tolerance argument value (\(v1)) must be positive")
        Swift.assert(v2.min() >= 0, "Invalid argument: all components of a tolerance argument value (\(v2)) must be positive")

        self.value = Math.max(v1, v2)
    }

    @usableFromInline
    internal init(values v1: Vector, _ v2: Vector, _ v3: Vector) {
        Swift.assert(v1.min() >= 0, "Invalid argument: all components of a tolerance argument value (\(v1)) must be positive")
        Swift.assert(v2.min() >= 0, "Invalid argument: all components of a tolerance argument value (\(v2)) must be positive")
        Swift.assert(v3.min() >= 0, "Invalid argument: all components of a tolerance argument value (\(v3)) must be positive")

        self.value = Math.max(Math.max(v1, v2), v3)
    }

    @usableFromInline
    internal init(values v1: Vector, _ v2: Vector, _ v3: Vector, _ v4: Vector) {
        Swift.assert(v1.min() >= 0, "Invalid argument: all components of a tolerance argument value (\(v1)) must be positive")
        Swift.assert(v2.min() >= 0, "Invalid argument: all components of a tolerance argument value (\(v2)) must be positive")
        Swift.assert(v3.min() >= 0, "Invalid argument: all components of a tolerance argument value (\(v3)) must be positive")
        Swift.assert(v4.min() >= 0, "Invalid argument: all components of a tolerance argument value (\(v4)) must be positive")

        self.value = Math.max(Math.max(v1, v2), Math.max(v3, v4))
    }

    /// Zero argument initializer.
    @inlinable public init() { value = .zero }

    /// Initializes single argument tolerance.
    @inlinable public init(_ arg: Vector) { self.init(value: Math.abs(arg)) }

    /// Initializes tolerance by simple combination of two arguments.
    @inlinable public init(_ a1: Vector, _ a2: Vector) { self.init(values: Math.abs(a1), Math.abs(a2)) }

    /// Initializes tolerance by simple combination of three arguments.
    @inlinable public init(_ a1: Vector, _ a2: Vector, _ a3: Vector) { self.init(values: Math.abs(a1), Math.abs(a2), Math.abs(a3)) }

    /// Initializes tolerance by simple combination of three arguments.
    @inlinable public init(_ a1: Vector, _ a2: Vector, _ a3: Vector, _ a4: Vector) { self.init(values: Math.abs(a1), Math.abs(a2), Math.abs(a3), Math.abs(a4)) }


    // MARK: Auxiliaries

    @inlinable public static var zero: Self { Self() }


    // MARK: Operations

    @inlinable public var scalar: Math.EpsArg { Math.EpsArg(value: value.max()) }

    @inlinable public var tolerance: Tolerance { Tolerance(scalar) }


    /// - Returns: A tolerance of a sum.
    @inlinable public static func +(lhs: Self, rhs: Self) -> Self { Self(value: lhs.value + rhs.value) }

    /// - Returns: A tolerance of a subtraction.
    @inlinable public static func -(lhs: Self, rhs: Self) -> Self { Self(value: lhs.value + rhs.value) }

    /// - Returns: A tolerance of a memberwise product.
    @inlinable public static func *(lhs: Self, rhs: Self) -> Self { Self(value: 2 * lhs.value * rhs.value) }

    /// - Returns: A tolerance of a division.
    @inlinable public static func /(lhs: Self, rhs: Self) -> Self { Self(value: 2 * lhs.value / rhs.value) }

    /// - Returns: A tolerance of a dot product.
    @inlinable public func dot(_ rhs: Self) -> Math.EpsArg { Math.EpsArg(values: value.max(), rhs.value.max(), 2 * Math.dot(value, rhs.value)) }

    /// - Returns: A tolerance of a cross product.
    @inlinable
    public func cross(_ rhs: Self) -> Self {
        Self(values: value, rhs.value,
             2 * Vector(x: value.y * rhs.value.z + value.z * rhs.value.y,
                        y: value.z * rhs.value.x + value.x * rhs.value.z,
                        z: value.x * rhs.value.y + value.y * rhs.value.x))
    }

}



// MARK: - .KvNumericalToleranceVectorArgument4

/// Vector tolerance argument.
public struct KvNumericalToleranceVectorArgument4<Math : KvMathScope> : Hashable {

    public typealias Tolerance = Math.Eps

    public typealias Vector = Math.Vector4


    public let value: Vector


    /// Memerwise initializer.
    @usableFromInline
    internal init(value: Vector) {
        Swift.assert(value.min() >= 0, "Invalid argument: all components of a tolerance argument value (\(value)) must be positive")

        self.value = value
    }

    @usableFromInline
    internal init(values v1: Vector, _ v2: Vector) {
        Swift.assert(v1.min() >= 0, "Invalid argument: all components of a tolerance argument value (\(v1)) must be positive")
        Swift.assert(v2.min() >= 0, "Invalid argument: all components of a tolerance argument value (\(v2)) must be positive")

        self.value = Math.max(v1, v2)
    }

    @usableFromInline
    internal init(values v1: Vector, _ v2: Vector, _ v3: Vector) {
        Swift.assert(v1.min() >= 0, "Invalid argument: all components of a tolerance argument value (\(v1)) must be positive")
        Swift.assert(v2.min() >= 0, "Invalid argument: all components of a tolerance argument value (\(v2)) must be positive")
        Swift.assert(v3.min() >= 0, "Invalid argument: all components of a tolerance argument value (\(v3)) must be positive")

        self.value = Math.max(Math.max(v1, v2), v3)
    }

    @usableFromInline
    internal init(values v1: Vector, _ v2: Vector, _ v3: Vector, _ v4: Vector) {
        Swift.assert(v1.min() >= 0, "Invalid argument: all components of a tolerance argument value (\(v1)) must be positive")
        Swift.assert(v2.min() >= 0, "Invalid argument: all components of a tolerance argument value (\(v2)) must be positive")
        Swift.assert(v3.min() >= 0, "Invalid argument: all components of a tolerance argument value (\(v3)) must be positive")
        Swift.assert(v4.min() >= 0, "Invalid argument: all components of a tolerance argument value (\(v4)) must be positive")

        self.value = Math.max(Math.max(v1, v2), Math.max(v3, v4))
    }

    /// Zero argument initializer.
    @inlinable public init() { value = .zero }

    /// Initializes single argument tolerance.
    @inlinable public init(_ arg: Vector) { self.init(value: Math.abs(arg)) }

    /// Initializes tolerance by simple combination of two arguments.
    @inlinable public init(_ a1: Vector, _ a2: Vector) { self.init(values: Math.abs(a1), Math.abs(a2)) }

    /// Initializes tolerance by simple combination of three arguments.
    @inlinable public init(_ a1: Vector, _ a2: Vector, _ a3: Vector) { self.init(values: Math.abs(a1), Math.abs(a2), Math.abs(a3)) }

    /// Initializes tolerance by simple combination of three arguments.
    @inlinable public init(_ a1: Vector, _ a2: Vector, _ a3: Vector, _ a4: Vector) { self.init(values: Math.abs(a1), Math.abs(a2), Math.abs(a3), Math.abs(a4)) }


    // MARK: Auxiliaries

    @inlinable public static var zero: Self { Self() }


    // MARK: Operations

    @inlinable public var scalar: Math.EpsArg { Math.EpsArg(value: value.max()) }

    @inlinable public var tolerance: Tolerance { Tolerance(scalar) }


    /// - Returns: A tolerance of a sum.
    @inlinable public static func +(lhs: Self, rhs: Self) -> Self { Self(value: lhs.value + rhs.value) }

    /// - Returns: A tolerance of a subtraction.
    @inlinable public static func -(lhs: Self, rhs: Self) -> Self { Self(value: lhs.value + rhs.value) }

    /// - Returns: A tolerance of a memberwise product.
    @inlinable public static func *(lhs: Self, rhs: Self) -> Self { Self(value: 2 * lhs.value * rhs.value) }

    /// - Returns: A tolerance of a division.
    @inlinable public static func /(lhs: Self, rhs: Self) -> Self { Self(value: 2 * lhs.value / rhs.value) }

    /// - Returns: A tolerance of a dot product.
    @inlinable public func dot(_ rhs: Self) -> Math.EpsArg { Math.EpsArg(values: value.max(), rhs.value.max(), 2 * Math.dot(value, rhs.value)) }

}



// MARK: - .KvNumericalToleranceVectorArgument2x2

/// Vector tolerance argument.
public struct KvNumericalToleranceVectorArgument2x2<Math : KvMathScope> {

    public typealias Tolerance = Math.Eps

    public typealias Matrix = Math.Matrix2x2


    public let value: Matrix


    /// Memerwise initializer.
    @usableFromInline
    internal init(value: Matrix) {
        Swift.assert(Math.min(value) >= 0, "Invalid argument: all components of a tolerance argument value (\(value)) must be positive")

        self.value = value
    }

    @usableFromInline
    internal init(values v1: Matrix, _ v2: Matrix) {
        Swift.assert(Math.min(v1) >= 0, "Invalid argument: all components of a tolerance argument value (\(v1)) must be positive")
        Swift.assert(Math.min(v2) >= 0, "Invalid argument: all components of a tolerance argument value (\(v2)) must be positive")

        self.value = Math.max(v1, v2)
    }

    @usableFromInline
    internal init(values v1: Matrix, _ v2: Matrix, _ v3: Matrix) {
        Swift.assert(Math.min(v1) >= 0, "Invalid argument: all components of a tolerance argument value (\(v1)) must be positive")
        Swift.assert(Math.min(v2) >= 0, "Invalid argument: all components of a tolerance argument value (\(v2)) must be positive")
        Swift.assert(Math.min(v3) >= 0, "Invalid argument: all components of a tolerance argument value (\(v3)) must be positive")

        self.value = Math.max(Math.max(v1, v2), v3)
    }

    @usableFromInline
    internal init(values v1: Matrix, _ v2: Matrix, _ v3: Matrix, _ v4: Matrix) {
        Swift.assert(Math.min(v1) >= 0, "Invalid argument: all components of a tolerance argument value (\(v1)) must be positive")
        Swift.assert(Math.min(v2) >= 0, "Invalid argument: all components of a tolerance argument value (\(v2)) must be positive")
        Swift.assert(Math.min(v3) >= 0, "Invalid argument: all components of a tolerance argument value (\(v3)) must be positive")
        Swift.assert(Math.min(v4) >= 0, "Invalid argument: all components of a tolerance argument value (\(v4)) must be positive")

        self.value = Math.max(Math.max(v1, v2), Math.max(v3, v4))
    }

    /// Zero argument initializer.
    @inlinable public init() { value = .zero }

    /// Initializes single argument tolerance.
    @inlinable public init(_ arg: Matrix) { self.init(value: Math.abs(arg)) }

    /// Initializes tolerance by simple combination of two arguments.
    @inlinable public init(_ a1: Matrix, _ a2: Matrix) { self.init(values: Math.abs(a1), Math.abs(a2)) }

    /// Initializes tolerance by simple combination of three arguments.
    @inlinable public init(_ a1: Matrix, _ a2: Matrix, _ a3: Matrix) { self.init(values: Math.abs(a1), Math.abs(a2), Math.abs(a3)) }

    /// Initializes tolerance by simple combination of three arguments.
    @inlinable public init(_ a1: Matrix, _ a2: Matrix, _ a3: Matrix, _ a4: Matrix) { self.init(values: Math.abs(a1), Math.abs(a2), Math.abs(a3), Math.abs(a4)) }


    // MARK: Auxiliaries

    @inlinable public static var zero: Self { Self() }


    // MARK: Operations

    @inlinable public var scalar: Math.EpsArg { Math.EpsArg(value: Math.max(value)) }

    @inlinable public var tolerance: Tolerance { Tolerance(scalar) }


    /// - Returns: A tolerance of a sum.
    @inlinable public static func +(lhs: Self, rhs: Self) -> Self { Self(value: lhs.value + rhs.value) }

    /// - Returns: A tolerance of a subtraction.
    @inlinable public static func -(lhs: Self, rhs: Self) -> Self { Self(value: lhs.value + rhs.value) }

    /// - Returns: A tolerance of a product.
    @inlinable public static func *(lhs: Self, rhs: Self) -> Self { Self(value: 2 * lhs.value * rhs.value) }

}



// MARK: - .KvNumericalToleranceVectorArgument3x3

/// Vector tolerance argument.
public struct KvNumericalToleranceVectorArgument3x3<Math : KvMathScope> {

    public typealias Tolerance = Math.Eps

    public typealias Matrix = Math.Matrix3x3


    public let value: Matrix


    /// Memerwise initializer.
    @usableFromInline
    internal init(value: Matrix) {
        Swift.assert(Math.min(value) >= 0, "Invalid argument: all components of a tolerance argument value (\(value)) must be positive")

        self.value = value
    }

    @usableFromInline
    internal init(values v1: Matrix, _ v2: Matrix) {
        Swift.assert(Math.min(v1) >= 0, "Invalid argument: all components of a tolerance argument value (\(v1)) must be positive")
        Swift.assert(Math.min(v2) >= 0, "Invalid argument: all components of a tolerance argument value (\(v2)) must be positive")

        self.value = Math.max(v1, v2)
    }

    @usableFromInline
    internal init(values v1: Matrix, _ v2: Matrix, _ v3: Matrix) {
        Swift.assert(Math.min(v1) >= 0, "Invalid argument: all components of a tolerance argument value (\(v1)) must be positive")
        Swift.assert(Math.min(v2) >= 0, "Invalid argument: all components of a tolerance argument value (\(v2)) must be positive")
        Swift.assert(Math.min(v3) >= 0, "Invalid argument: all components of a tolerance argument value (\(v3)) must be positive")

        self.value = Math.max(Math.max(v1, v2), v3)
    }

    @usableFromInline
    internal init(values v1: Matrix, _ v2: Matrix, _ v3: Matrix, _ v4: Matrix) {
        Swift.assert(Math.min(v1) >= 0, "Invalid argument: all components of a tolerance argument value (\(v1)) must be positive")
        Swift.assert(Math.min(v2) >= 0, "Invalid argument: all components of a tolerance argument value (\(v2)) must be positive")
        Swift.assert(Math.min(v3) >= 0, "Invalid argument: all components of a tolerance argument value (\(v3)) must be positive")
        Swift.assert(Math.min(v4) >= 0, "Invalid argument: all components of a tolerance argument value (\(v4)) must be positive")

        self.value = Math.max(Math.max(v1, v2), Math.max(v3, v4))
    }

    /// Zero argument initializer.
    @inlinable public init() { value = .zero }

    /// Initializes single argument tolerance.
    @inlinable public init(_ arg: Matrix) { self.init(value: Math.abs(arg)) }

    /// Initializes tolerance by simple combination of two arguments.
    @inlinable public init(_ a1: Matrix, _ a2: Matrix) { self.init(values: Math.abs(a1), Math.abs(a2)) }

    /// Initializes tolerance by simple combination of three arguments.
    @inlinable public init(_ a1: Matrix, _ a2: Matrix, _ a3: Matrix) { self.init(values: Math.abs(a1), Math.abs(a2), Math.abs(a3)) }

    /// Initializes tolerance by simple combination of three arguments.
    @inlinable public init(_ a1: Matrix, _ a2: Matrix, _ a3: Matrix, _ a4: Matrix) { self.init(values: Math.abs(a1), Math.abs(a2), Math.abs(a3), Math.abs(a4)) }


    // MARK: Auxiliaries

    @inlinable public static var zero: Self { Self() }


    // MARK: Operations

    @inlinable public var scalar: Math.EpsArg { Math.EpsArg(value: Math.max(value)) }

    @inlinable public var tolerance: Tolerance { Tolerance(scalar) }


    /// - Returns: A tolerance of a sum.
    @inlinable public static func +(lhs: Self, rhs: Self) -> Self { Self(value: lhs.value + rhs.value) }

    /// - Returns: A tolerance of a subtraction.
    @inlinable public static func -(lhs: Self, rhs: Self) -> Self { Self(value: lhs.value + rhs.value) }

    /// - Returns: A tolerance of a product.
    @inlinable public static func *(lhs: Self, rhs: Self) -> Self { Self(value: 2 * lhs.value * rhs.value) }

}



// MARK: - .KvNumericalToleranceVectorArgument4x4

/// Vector tolerance argument.
public struct KvNumericalToleranceVectorArgument4x4<Math : KvMathScope> {

    public typealias Tolerance = Math.Eps

    public typealias Matrix = Math.Matrix4x4


    public let value: Matrix


    /// Memerwise initializer.
    @usableFromInline
    internal init(value: Matrix) {
        Swift.assert(Math.min(value) >= 0, "Invalid argument: all components of a tolerance argument value (\(value)) must be positive")

        self.value = value
    }

    @usableFromInline
    internal init(values v1: Matrix, _ v2: Matrix) {
        Swift.assert(Math.min(v1) >= 0, "Invalid argument: all components of a tolerance argument value (\(v1)) must be positive")
        Swift.assert(Math.min(v2) >= 0, "Invalid argument: all components of a tolerance argument value (\(v2)) must be positive")

        self.value = Math.max(v1, v2)
    }

    @usableFromInline
    internal init(values v1: Matrix, _ v2: Matrix, _ v3: Matrix) {
        Swift.assert(Math.min(v1) >= 0, "Invalid argument: all components of a tolerance argument value (\(v1)) must be positive")
        Swift.assert(Math.min(v2) >= 0, "Invalid argument: all components of a tolerance argument value (\(v2)) must be positive")
        Swift.assert(Math.min(v3) >= 0, "Invalid argument: all components of a tolerance argument value (\(v3)) must be positive")

        self.value = Math.max(Math.max(v1, v2), v3)
    }

    @usableFromInline
    internal init(values v1: Matrix, _ v2: Matrix, _ v3: Matrix, _ v4: Matrix) {
        Swift.assert(Math.min(v1) >= 0, "Invalid argument: all components of a tolerance argument value (\(v1)) must be positive")
        Swift.assert(Math.min(v2) >= 0, "Invalid argument: all components of a tolerance argument value (\(v2)) must be positive")
        Swift.assert(Math.min(v3) >= 0, "Invalid argument: all components of a tolerance argument value (\(v3)) must be positive")
        Swift.assert(Math.min(v4) >= 0, "Invalid argument: all components of a tolerance argument value (\(v4)) must be positive")

        self.value = Math.max(Math.max(v1, v2), Math.max(v3, v4))
    }

    /// Zero argument initializer.
    @inlinable public init() { value = .zero }

    /// Initializes single argument tolerance.
    @inlinable public init(_ arg: Matrix) { self.init(value: Math.abs(arg)) }

    /// Initializes tolerance by simple combination of two arguments.
    @inlinable public init(_ a1: Matrix, _ a2: Matrix) { self.init(values: Math.abs(a1), Math.abs(a2)) }

    /// Initializes tolerance by simple combination of three arguments.
    @inlinable public init(_ a1: Matrix, _ a2: Matrix, _ a3: Matrix) { self.init(values: Math.abs(a1), Math.abs(a2), Math.abs(a3)) }

    /// Initializes tolerance by simple combination of three arguments.
    @inlinable public init(_ a1: Matrix, _ a2: Matrix, _ a3: Matrix, _ a4: Matrix) { self.init(values: Math.abs(a1), Math.abs(a2), Math.abs(a3), Math.abs(a4)) }


    // MARK: Auxiliaries

    @inlinable public static var zero: Self { Self() }


    // MARK: Operations

    @inlinable public var scalar: Math.EpsArg { Math.EpsArg(value: Math.max(value)) }

    @inlinable public var tolerance: Tolerance { Tolerance(scalar) }


    /// - Returns: A tolerance of a sum.
    @inlinable public static func +(lhs: Self, rhs: Self) -> Self { Self(value: lhs.value + rhs.value) }

    /// - Returns: A tolerance of a subtraction.
    @inlinable public static func -(lhs: Self, rhs: Self) -> Self { Self(value: lhs.value + rhs.value) }

    /// - Returns: A tolerance of a product.
    @inlinable public static func *(lhs: Self, rhs: Self) -> Self { Self(value: 2 * lhs.value * rhs.value) }

}
