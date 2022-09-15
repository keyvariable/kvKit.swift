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
//  KvMath4.swift
//  kvKit
//
//  Created by Svyatoslav Popov on 25.09.2021.
//

import simd



public enum KvMath4<Scalar> where Scalar : KvMathFloatingPoint {

    public typealias Scalar = Scalar

    public typealias Vector = SIMD4<Scalar>
    public typealias Position = Vector

    public typealias Matrix = KvSimdMatrix4x4<Scalar>

}



public typealias KvMath4F = KvMath4<Float>
public typealias KvMath4D = KvMath4<Double>



// MARK: Matrix Fabrics

extension KvMath4 {

    /// - Returns: Result of replacement if the left top submatrix of identity matrix with given matrix.
    @inlinable
    public static func supplemented<M2x2>(_ base: M2x2) -> Matrix
    where M2x2 : KvSimdMatrix2xN & KvSimdMatrixNx2, M2x2.Scalar == Scalar, M2x2.Column == Matrix.Column.Sample2
    {
        Matrix(Matrix.Column(lowHalf: base[0], highHalf: M2x2.Column.zero),
               Matrix.Column(lowHalf: base[1], highHalf: M2x2.Column.zero),
               [ 0, 0, 1, 0 ],
               [ 0, 0, 0, 1 ])
    }

    /// - Returns: Result of replacement if the left top submatrix of identity matrix with given matrix.
    @inlinable
    public static func supplemented<M2x3>(_ base: M2x3) -> Matrix
    where M2x3 : KvSimdMatrix2xN & KvSimdMatrixNx3, M2x3.Scalar == Scalar, M2x3.Column == Matrix.Column.Sample3
    {
        Matrix(Matrix.Column(base[0], 0),
               Matrix.Column(base[1], 0),
               [ 0, 0, 1, 0 ],
               [ 0, 0, 0, 1 ])
    }

    /// - Returns: Result of replacement if the left top submatrix of identity matrix with given matrix.
    @inlinable
    public static func supplemented<M2x4>(_ base: M2x4) -> Matrix
    where M2x4 : KvSimdMatrix2xN & KvSimdMatrixNx4, M2x4.Scalar == Scalar, M2x4.Column == Matrix.Column
    {
        Matrix(base[0], base[1], [ 0, 0, 1, 0 ], [ 0, 0, 0, 1 ])
    }

    /// - Returns: Result of replacement if the left top submatrix of identity matrix with given matrix.
    @inlinable
    public static func supplemented<M3x2>(_ base: M3x2) -> Matrix
    where M3x2 : KvSimdMatrix3xN & KvSimdMatrixNx2, M3x2.Scalar == Scalar, M3x2.Column == Matrix.Column.Sample2
    {
        Matrix(Matrix.Column(lowHalf: base[0], highHalf: M3x2.Column.zero),
               Matrix.Column(lowHalf: base[1], highHalf: M3x2.Column.zero),
               Matrix.Column(lowHalf: base[2], highHalf: M3x2.Column.zero),
               [ 0, 0, 0, 1 ])
    }

    /// - Returns: Result of replacement if the left top submatrix of identity matrix with given matrix.
    @inlinable
    public static func supplemented<M3x3>(_ base: M3x3) -> Matrix
    where M3x3 : KvSimdMatrix3xN & KvSimdMatrixNx3, M3x3.Scalar == Scalar, M3x3.Column == Matrix.Column.Sample3
    {
        Matrix(Matrix.Column(base[0], 0),
               Matrix.Column(base[1], 0),
               Matrix.Column(base[2], 0),
               [ 0, 0, 0, 1 ])
    }

    /// - Returns: Result of replacement if the left top submatrix of identity matrix with given matrix.
    @inlinable
    public static func supplemented<M3x4>(_ base: M3x4) -> Matrix
    where M3x4 : KvSimdMatrix3xN & KvSimdMatrixNx4, M3x4.Scalar == Scalar, M3x4.Column == Matrix.Column
    {
        Matrix(base[0], base[1], base[2], [ 0, 0, 0, 1 ])
    }

    /// - Returns: Result of replacement if the left top submatrix of identity matrix with given matrix.
    @inlinable
    public static func supplemented<M4x2>(_ base: M4x2) -> Matrix
    where M4x2 : KvSimdMatrix4xN & KvSimdMatrixNx2, M4x2.Scalar == Scalar, M4x2.Column == Matrix.Column.Sample2
    {
        Matrix(Matrix.Column(lowHalf: base[0], highHalf: M4x2.Column.zero),
               Matrix.Column(lowHalf: base[1], highHalf: M4x2.Column.zero),
               Matrix.Column(lowHalf: base[2], highHalf: M4x2.Column.zero),
               Matrix.Column(lowHalf: base[3], highHalf: M4x2.Column.zero))
    }

    /// - Returns: Result of replacement if the left top submatrix of identity matrix with given matrix.
    @inlinable
    public static func supplemented<M4x3>(_ base: M4x3) -> Matrix
    where M4x3 : KvSimdMatrix4xN & KvSimdMatrixNx3, M4x3.Scalar == Scalar, M4x3.Column == Matrix.Column.Sample3
    {
        Matrix(Matrix.Column(base[0], 0),
               Matrix.Column(base[1], 0),
               Matrix.Column(base[2], 0),
               Matrix.Column(base[3], 1))
    }

}



// MARK: Matrix Operations

extension KvMath4 {

    /// - Returns: Elementwise absolute value.
    @inlinable
    public static func abs(_ matrix: Matrix) -> Matrix {
        Matrix(abs(matrix[0]),
               abs(matrix[1]),
               abs(matrix[2]),
               abs(matrix[3]))
    }


    /// - Returns: MInimum element of the receiver.
    @inlinable
    public static func min(_ matrix: Matrix) -> Scalar {
        Swift.min(matrix[0].min(), matrix[1].min(), matrix[2].min(), matrix[3].min())
    }


    /// - Returns: MInimum element of the receiver.
    @inlinable
    public static func max(_ matrix: Matrix) -> Scalar {
        Swift.max(matrix[0].max(), matrix[1].max(), matrix[2].max(), matrix[3].max())
    }

}



// MARK: Transformations

extension KvMath4 {

    /// - Returns: Scale component from given 4×4 matrix.
    @inlinable
    public static func scale<Matrix>(from matrix: Matrix) -> Vector
    where Matrix : KvSimdMatrix4xN & KvSimdMatrixNx4 & KvSimdSquareMatrix, Matrix.Scalar == Scalar
    {
        .init(x: length(matrix[0]) * (KvIsNotNegative(matrix.determinant) ? 1 : -1),
              y: length(matrix[1]),
              z: length(matrix[2]),
              w: length(matrix[3]))
    }

    /// - Returns: Sqaured scale component from given 4×4 matrix.
    @inlinable
    public static func scale²<Matrix>(from matrix: Matrix) -> Vector
    where Matrix : KvSimdMatrix4xN & KvSimdMatrixNx4 & KvSimdSquareMatrix, Matrix.Scalar == Scalar
    {
        .init(x: length_squared(matrix[0]),
              y: length_squared(matrix[1]),
              z: length_squared(matrix[2]),
              w: length_squared(matrix[3]))
    }

    /// Changes scale component of given 4×4 matrix to given value. If a column is zero then the result is undefined.
    @inlinable
    public static func setScale<Matrix>(_ scale: Vector, to matrix: inout Matrix)
    where Matrix : KvSimdMatrix4xN & KvSimdMatrixNx4 & KvSimdSquareMatrix, Matrix.Scalar == Scalar
    {
        let s = scale * rsqrt(self.scale²(from: matrix))

        matrix[0] *= s.x * (KvIsNotNegative(matrix.determinant) ? 1 : -1)
        matrix[1] *= s.y
        matrix[2] *= s.z
        matrix[3] *= s.w
    }

}



// MARK: Generalization of SIMD

extension KvMath4 {

    @inlinable
    public static func abs<V>(_ v: V) -> V where V : KvSimdVector4, V.Scalar == Scalar {
        V(Swift.abs(v.x), Swift.abs(v.y), Swift.abs(v.z), Swift.abs(v.w))
    }

    @inlinable
    public static func acos(_ x: Scalar) -> Scalar { fatalError("Incomplete implementation") }

    @inlinable
    public static func asin(_ x: Scalar) -> Scalar { fatalError("Incomplete implementation") }

    @inlinable
    public static func atan(_ x: Scalar) -> Scalar { fatalError("Incomplete implementation") }

    @inlinable
    public static func atan2(_ x: Scalar, _ y: Scalar) -> Scalar { fatalError("Incomplete implementation") }

    @inlinable
    public static func clamp<V>(_ v: V, _ min: V, _ max: V) -> V where V : KvSimdVector4, V.Scalar == Scalar {
        V(x: KvMath.clamp(v.x, min.x, max.x),
          y: KvMath.clamp(v.y, min.y, max.y),
          z: KvMath.clamp(v.z, min.z, max.z),
          w: KvMath.clamp(v.w, min.w, max.w))
    }

    @inlinable
    public static func cos(_ x: Scalar) -> Scalar { fatalError("Incomplete implementation") }

    @inlinable
    public static func cospi(_ x: Scalar) -> Scalar { fatalError("Incomplete implementation") }

    @inlinable
    public static func distance<V>(_ x: V, _ y: V) -> Scalar where V : KvSimdVector4, V.Scalar == Scalar {
        length(y - x)
    }

    @inlinable
    public static func dot<V>(_ x: V, _ y: V) -> Scalar where V : KvSimdVector4, V.Scalar == Scalar {
        x.x * y.x + x.y * y.y + x.z * y.z + x.w * y.w
    }

    @inlinable
    public static func length<V>(_ v: V) -> Scalar where V : KvSimdVector4, V.Scalar == Scalar {
        dot(v, v).squareRoot()
    }

    @inlinable
    public static func length_squared<V>(_ v: V) -> Scalar where V : KvSimdVector4, V.Scalar == Scalar {
        dot(v, v)
    }

    @inlinable
    public static func max<V>(_ x: Vector, _ y: V) -> V where V : KvSimdVector4, V.Scalar == Scalar {
        V(x: Swift.max(x.x, y.x),
          y: Swift.max(x.y, y.y),
          z: Swift.max(x.z, y.z),
          w: Swift.max(x.w, y.w))
    }

    @inlinable
    public static func min<V>(_ x: V, _ y: V) -> V where V : KvSimdVector4, V.Scalar == Scalar {
        .init(x: Swift.min(x.x, y.x),
              y: Swift.min(x.y, y.y),
              z: Swift.min(x.z, y.z),
              w: Swift.min(x.w, y.w))
    }

    @inlinable
    public static func mix<V>(_ x: V, _ y: V, t: Scalar) -> V where V : KvSimdVector4, V.Scalar == Scalar {
        let oneMinusT: Scalar = 1 - t

        return V(x: x.x * oneMinusT + y.x * t,
                 y: x.y * oneMinusT + y.y * t,
                 z: x.z * oneMinusT + y.z * t,
                 w: x.w * oneMinusT + y.w * t)
    }

    @inlinable
    public static func normalize<V>(_ v: V) -> V where V : KvSimdVector4, V.Scalar == Scalar {
        v / length(v)
    }

    @inlinable
    public static func rsqrt<V>(_ v: V) -> V where V : KvSimdVector4, V.Scalar == Scalar {
        1 / (v * v).squareRoot()
    }

    @inlinable
    public static func sin(_ x: Vector) -> Vector { fatalError("Incomplete implementation") }

    @inlinable
    public static func sinpi(_ x: Vector) -> Vector { fatalError("Incomplete implementation") }

    @inlinable
    public static func tan(_ x: Vector) -> Vector { fatalError("Incomplete implementation") }

    @inlinable
    public static func tanpi(_ x: Vector) -> Vector { fatalError("Incomplete implementation") }

}


// MARK: <Float> Generalization of SIMD

extension KvMath4 where Scalar == Float {

    @inlinable public static func abs(_ v: Vector) -> Vector { simd.abs(v) }

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    @inlinable public static func acos(_ x: Vector) -> Vector { simd.acos(x) }

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    @inlinable public static func asin(_ x: Vector) -> Vector { simd.asin(x) }

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    @inlinable public static func atan(_ x: Vector) -> Vector { simd.atan(x) }

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    @inlinable public static func atan2(_ x: Vector, _ y: Vector) -> Vector { simd.atan2(x, y) }

    @inlinable public static func clamp(_ v: Vector, _ min: Vector, _ max: Vector) -> Vector { simd_clamp(v, min, max) }

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    @inlinable public static func cos(_ x: Vector) -> Vector { simd.cos(x) }

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    @inlinable public static func cospi(_ x: Vector) -> Vector { simd.cospi(x) }

    @inlinable public static func distance(_ x: Vector, _ y: Vector) -> Scalar { simd.distance(x, y) }

    @inlinable public static func dot(_ x: Vector, _ y: Vector) -> Scalar { simd.dot(x, y) }

    @inlinable public static func length(_ v: Vector) -> Scalar { simd.length(v) }

    @inlinable public static func length_squared(_ v: Vector) -> Scalar { simd.length_squared(v) }

    @inlinable public static func max(_ x: Vector, _ y: Vector) -> Vector { simd_max(x, y) }

    @inlinable public static func min(_ x: Vector, _ y: Vector) -> Vector { simd_min(x, y) }

    @inlinable public static func mix(_ x: Vector, _ y: Vector, t: Scalar) -> Vector { simd.mix(x, y, t: t) }

    @inlinable public static func normalize(_ v: Vector) -> Vector { simd.normalize(v) }

    @inlinable public static func rsqrt(_ v: Vector) -> Vector { simd.rsqrt(v) }

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    @inlinable public static func sin(_ x: Vector) -> Vector { simd.sin(x) }

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    @inlinable public static func sinpi(_ x: Vector) -> Vector { simd.sinpi(x) }

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    @inlinable public static func tan(_ x: Vector) -> Vector { simd.tan(x) }

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    @inlinable public static func tanpi(_ x: Vector) -> Vector { simd.tanpi(x) }

}


// MARK: <Double> Generalization of SIMD

extension KvMath4 where Scalar == Double {

    @inlinable public static func abs(_ v: Vector) -> Vector { simd.abs(v) }

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    @inlinable public static func acos(_ x: Vector) -> Vector { simd.acos(x) }

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    @inlinable public static func asin(_ x: Vector) -> Vector { simd.asin(x) }

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    @inlinable public static func atan(_ x: Vector) -> Vector { simd.atan(x) }

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    @inlinable public static func atan2(_ x: Vector, _ y: Vector) -> Vector { simd.atan2(x, y) }

    @inlinable public static func clamp(_ v: Vector, _ min: Vector, _ max: Vector) -> Vector { simd_clamp(v, min, max) }

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    @inlinable public static func cos(_ x: Vector) -> Vector { simd.cos(x) }

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    @inlinable public static func cospi(_ x: Vector) -> Vector { simd.cospi(x) }

    @inlinable public static func distance(_ x: Vector, _ y: Vector) -> Scalar { simd.distance(x, y) }

    @inlinable public static func dot(_ x: Vector, _ y: Vector) -> Scalar { simd.dot(x, y) }

    @inlinable public static func length(_ v: Vector) -> Scalar { simd.length(v) }

    @inlinable public static func length_squared(_ v: Vector) -> Scalar { simd.length_squared(v) }

    @inlinable public static func max(_ x: Vector, _ y: Vector) -> Vector { simd_max(x, y) }

    @inlinable public static func min(_ x: Vector, _ y: Vector) -> Vector { simd_min(x, y) }

    @inlinable public static func mix(_ x: Vector, _ y: Vector, t: Scalar) -> Vector { simd.mix(x, y, t: t) }

    @inlinable public static func normalize(_ v: Vector) -> Vector { simd.normalize(v) }

    @inlinable public static func rsqrt(_ v: Vector) -> Vector { simd.rsqrt(v) }

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    @inlinable public static func sin(_ x: Vector) -> Vector { simd.sin(x) }

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    @inlinable public static func sinpi(_ x: Vector) -> Vector { simd.sinpi(x) }

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    @inlinable public static func tan(_ x: Vector) -> Vector { simd.tan(x) }

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    @inlinable public static func tanpi(_ x: Vector) -> Vector { simd.tanpi(x) }

}



// MARK: - Matrix Comparisons

@inlinable
public func KvIs<Scalar>(_ lhs: KvMath4<Scalar>.Matrix, equalTo rhs: KvMath4<Scalar>.Matrix) -> Bool
where Scalar : KvMathFloatingPoint
{
    KvIsZero(KvMath4.max(KvMath4.abs(lhs - rhs)))
}


@inlinable
public func KvIs<Scalar>(_ lhs: KvMath4<Scalar>.Matrix, inequalTo rhs: KvMath4<Scalar>.Matrix) -> Bool
where Scalar : KvMathFloatingPoint
{
    KvIsNonzero(KvMath4.max(KvMath4.abs(lhs - rhs)))
}



// MARK: - Legacy

@available(*, deprecated, renamed: "KvMathFloatingPoint")
public typealias KvMathScalar4 = KvMathFloatingPoint
