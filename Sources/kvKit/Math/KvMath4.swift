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

}



// MARK: Matrix Fabrics <Float>

extension KvMath4 where Scalar == Float {

    /// - Returns: Result of replacement if the left top submatix of identity matrix with given matrix.
    @inlinable
    public static func supplemented(_ base: simd_float2x2) -> simd_float4x4 {
        .init({ Vector($0.x, $0.y, 0, 0) }(base[0]),
              { Vector($0.x, $0.y, 0, 0) }(base[1]),
              [ 0, 0, 1, 0 ],
              [ 0, 0, 0, 1 ])
    }

    /// - Returns: Result of replacement if the left top submatix of identity matrix with given matrix.
    @inlinable
    public static func supplemented(_ base: simd_float2x3) -> simd_float4x4 {
        .init(Vector(base[0], 0), Vector(base[1], 0), [ 0, 0, 1, 0 ], [ 0, 0, 0, 1 ])
    }

    /// - Returns: Result of replacement if the left top submatix of identity matrix with given matrix.
    @inlinable
    public static func supplemented(_ base: simd_float2x4) -> simd_float4x4 {
        .init(base[0], base[1], [ 0, 0, 1, 0 ], [ 0, 0, 0, 1 ])
    }

    /// - Returns: Result of replacement if the left top submatix of identity matrix with given matrix.
    @inlinable
    public static func supplemented(_ base: simd_float3x2) -> simd_float4x4 {
        .init({ Vector($0.x, $0.y, 0, 0) }(base[0]),
              { Vector($0.x, $0.y, 0, 0) }(base[1]),
              { Vector($0.x, $0.y, 1, 0) }(base[2]),
              [ 0, 0, 0, 1 ])
    }

    /// - Returns: Result of replacement if the left top submatix of identity matrix with given matrix.
    @inlinable
    public static func supplemented(_ base: simd_float3x3) -> simd_float4x4 {
        .init(Vector(base[0], 0), Vector(base[1], 0), Vector(base[2], 0), [ 0, 0, 0, 1 ])
    }

    /// - Returns: Result of replacement if the left top submatix of identity matrix with given matrix.
    @inlinable
    public static func supplemented(_ base: simd_float3x4) -> simd_float4x4 {
        .init(base[0], base[1], base[2], [ 0, 0, 0, 1 ])
    }

    /// - Returns: Result of replacement if the left top submatix of identity matrix with given matrix.
    @inlinable
    public static func supplemented(_ base: simd_float4x2) -> simd_float4x4 {
        .init({ Vector($0.x, $0.y, 0, 0) }(base[0]),
              { Vector($0.x, $0.y, 0, 0) }(base[1]),
              { Vector($0.x, $0.y, 1, 0) }(base[2]),
              { Vector($0.x, $0.y, 0, 1) }(base[3]))
    }

    /// - Returns: Result of replacement if the left top submatix of identity matrix with given matrix.
    @inlinable
    public static func supplemented(_ base: simd_float4x3) -> simd_float4x4 {
        .init(Vector(base[0], 0), Vector(base[1], 0), Vector(base[2], 0), Vector(base[3], 1))
    }

}



// MARK: Matrix Fabrics <Float>

extension KvMath4 where Scalar == Double {

    /// - Returns: Result of replacement if the left top submatix of identity matrix with given matrix.
    @inlinable
    public static func supplemented(_ base: simd_double2x2) -> simd_double4x4 {
        .init({ Vector($0.x, $0.y, 0, 0) }(base[0]),
              { Vector($0.x, $0.y, 0, 0) }(base[1]),
              [ 0, 0, 1, 0 ],
              [ 0, 0, 0, 1 ])
    }

    /// - Returns: Result of replacement if the left top submatix of identity matrix with given matrix.
    @inlinable
    public static func supplemented(_ base: simd_double2x3) -> simd_double4x4 {
        .init(Vector(base[0], 0), Vector(base[1], 0), [ 0, 0, 1, 0 ], [ 0, 0, 0, 1 ])
    }

    /// - Returns: Result of replacement if the left top submatix of identity matrix with given matrix.
    @inlinable
    public static func supplemented(_ base: simd_double2x4) -> simd_double4x4 {
        .init(base[0], base[1], [ 0, 0, 1, 0 ], [ 0, 0, 0, 1 ])
    }

    /// - Returns: Result of replacement if the left top submatix of identity matrix with given matrix.
    @inlinable
    public static func supplemented(_ base: simd_double3x2) -> simd_double4x4 {
        .init({ Vector($0.x, $0.y, 0, 0) }(base[0]),
              { Vector($0.x, $0.y, 0, 0) }(base[1]),
              { Vector($0.x, $0.y, 1, 0) }(base[2]),
              [ 0, 0, 0, 1 ])
    }

    /// - Returns: Result of replacement if the left top submatix of identity matrix with given matrix.
    @inlinable
    public static func supplemented(_ base: simd_double3x3) -> simd_double4x4 {
        .init(Vector(base[0], 0), Vector(base[1], 0), Vector(base[2], 0), [ 0, 0, 0, 1 ])
    }

    /// - Returns: Result of replacement if the left top submatix of identity matrix with given matrix.
    @inlinable
    public static func supplemented(_ base: simd_double3x4) -> simd_double4x4 {
        .init(base[0], base[1], base[2], [ 0, 0, 0, 1 ])
    }

    /// - Returns: Result of replacement if the left top submatix of identity matrix with given matrix.
    @inlinable
    public static func supplemented(_ base: simd_double4x2) -> simd_double4x4 {
        .init({ Vector($0.x, $0.y, 0, 0) }(base[0]),
              { Vector($0.x, $0.y, 0, 0) }(base[1]),
              { Vector($0.x, $0.y, 1, 0) }(base[2]),
              { Vector($0.x, $0.y, 0, 1) }(base[3]))
    }

    /// - Returns: Result of replacement if the left top submatix of identity matrix with given matrix.
    @inlinable
    public static func supplemented(_ base: simd_double4x3) -> simd_double4x4 {
        .init(Vector(base[0], 0), Vector(base[1], 0), Vector(base[2], 0), Vector(base[3], 1))
    }

}



// MARK: Martix Operations <Float>

extension KvMath4 where Scalar == Float {

    @inlinable
    public static func abs(_ matrix: simd_float4x4) -> simd_float4x4 {
        .init(simd.abs(matrix[0]), simd.abs(matrix[1]), simd.abs(matrix[2]), simd.abs(matrix[3]))
    }


    @inlinable
    public static func min(_ matrix: simd_float4x4) -> Scalar {
        Swift.min(matrix[0].min(), matrix[1].min(), matrix[2].min(), matrix[3].min())
    }


    @inlinable
    public static func max(_ matrix: simd_float4x4) -> Scalar {
        Swift.max(matrix[0].max(), matrix[1].max(), matrix[2].max(), matrix[3].max())
    }

}



// MARK: Martix Operations <Double>

extension KvMath4 where Scalar == Double {

    @inlinable
    public static func abs(_ matrix: simd_double4x4) -> simd_double4x4 {
        .init(simd.abs(matrix[0]), simd.abs(matrix[1]), simd.abs(matrix[2]), simd.abs(matrix[3]))
    }


    @inlinable
    public static func min(_ matrix: simd_double4x4) -> Scalar {
        Swift.min(matrix[0].min(), matrix[1].min(), matrix[2].min(), matrix[3].min())
    }


    @inlinable
    public static func max(_ matrix: simd_double4x4) -> Scalar {
        Swift.max(matrix[0].max(), matrix[1].max(), matrix[2].max(), matrix[3].max())
    }

}



// MARK: Transformations <Float>

extension KvMath4 where Scalar == Float {

    /// - Returns: Scale component from given 4×4 matrix.
    @inlinable
    public static func scale(from matrix: simd_float4x4) -> Vector {
        .init(x: simd.length(matrix[0]) * (KvIsNotNegative(simd_determinant(matrix)) ? 1 : -1),
              y: simd.length(matrix[1]),
              z: simd.length(matrix[2]),
              w: simd.length(matrix[3]))
    }

    /// - Returns: Sqaured scale component from given 4×4 matrix.
    @inlinable
    public static func scale²(from matrix: simd_float4x4) -> Vector {
        .init(x: simd.length_squared(matrix[0]),
              y: simd.length_squared(matrix[1]),
              z: simd.length_squared(matrix[2]),
              w: simd.length_squared(matrix[3]))
    }

    /// Changes scale component of given 4×4 matrix to given value. If a column is zero then the result is undefined.
    @inlinable
    public static func setScale(_ scale: Vector, to matrix: inout simd_float4x4) {
        let s = scale * rsqrt(self.scale²(from: matrix))

        matrix[0] *= s.x * (KvIsNotNegative(simd_determinant(matrix)) ? 1 : -1)
        matrix[1] *= s.y
        matrix[2] *= s.z
        matrix[3] *= s.w
    }

}



// MARK: Transformations <Double>

extension KvMath4 where Scalar == Double {

    /// - Returns: Scale component from given 4×4 matrix.
    @inlinable
    public static func scale(from matrix: simd_double4x4) -> Vector {
        .init(x: simd.length(matrix[0]) * (KvIsNotNegative(simd_determinant(matrix)) ? 1 : -1),
              y: simd.length(matrix[1]),
              z: simd.length(matrix[2]),
              w: simd.length(matrix[3]))
    }

    /// - Returns: Sqaured scale component from given 4×4 matrix.
    @inlinable
    public static func scale²(from matrix: simd_double4x4) -> Vector {
        .init(x: simd.length_squared(matrix[0]),
              y: simd.length_squared(matrix[1]),
              z: simd.length_squared(matrix[2]),
              w: simd.length_squared(matrix[3]))
    }

    /// Changes scale component of given 4×4 matrix to given value. If a column is zero then the result is undefined.
    @inlinable
    public static func setScale(_ scale: Vector, to matrix: inout simd_double4x4) {
        let s = scale * rsqrt(self.scale²(from: matrix))

        matrix[0] *= s.x * (KvIsNotNegative(simd_determinant(matrix)) ? 1 : -1)
        matrix[1] *= s.y
        matrix[2] *= s.z
        matrix[3] *= s.w
    }

}



// MARK: Generalization of SIMD

extension KvMath4 {

    @inlinable public static func abs(_ v: Vector) -> Vector { .init(Swift.abs(v.x), Swift.abs(v.y), Swift.abs(v.z), Swift.abs(v.w)) }

    @inlinable public static func clamp(_ v: Vector, _ min: Vector, _ max: Vector) -> Vector {
        Vector(x: KvMath.clamp(v.x, min.x, max.x),
               y: KvMath.clamp(v.y, min.y, max.y),
               z: KvMath.clamp(v.z, min.z, max.z),
               w: KvMath.clamp(v.w, min.w, max.w))
    }

    @inlinable public static func distance(_ x: Vector, _ y: Vector) -> Scalar { length(y - x) }

    @inlinable public static func dot(_ x: Vector, _ y: Vector) -> Scalar { x.x * y.x + x.y * y.y + x.z * y.z + x.w * y.w }

    @inlinable public static func length(_ v: Vector) -> Scalar { sqrt(dot(v, v)) }

    @inlinable public static func length_squared(_ v: Vector) -> Scalar { dot(v, v) }

    @inlinable public static func max(_ x: Vector, _ y: Vector) -> Vector {
        Vector(x: Swift.max(x.x, y.x),
               y: Swift.max(x.y, y.y),
               z: Swift.max(x.z, y.z),
               w: Swift.max(x.w, y.w))
    }

    @inlinable public static func min(_ x: Vector, _ y: Vector) -> Vector {
        Vector(x: Swift.min(x.x, y.x),
               y: Swift.min(x.y, y.y),
               z: Swift.min(x.z, y.z),
               w: Swift.min(x.w, y.w))
    }

    @inlinable public static func mix(_ x: Vector, _ y: Vector, t: Scalar) -> Vector {
        let oneMinusT = 1 - t

        return Vector(x: x.x * oneMinusT + y.x * t,
                      y: x.y * oneMinusT + y.y * t,
                      z: x.z * oneMinusT + y.z * t,
                      w: x.w * oneMinusT + y.w * t)
    }

    @inlinable public static func normalize(_ v: Vector) -> Vector { v / sqrt(length_squared(v)) }

}



// MARK: SIMD where Scalar == Float

extension KvMath4 where Scalar == Float {

    @inlinable public static func abs(_ v: Vector) -> Vector { simd.abs(v) }

    @inlinable public static func clamp(_ v: Vector, _ min: Vector, _ max: Vector) -> Vector { simd_clamp(v, min, max) }

    @inlinable public static func distance(_ x: Vector, _ y: Vector) -> Scalar { simd.distance(x, y) }

    @inlinable public static func dot(_ x: Vector, _ y: Vector) -> Scalar { simd.dot(x, y) }

    @inlinable public static func length(_ v: Vector) -> Scalar { simd.length(v) }

    @inlinable public static func length_squared(_ v: Vector) -> Scalar { simd.length_squared(v) }

    @inlinable public static func max(_ x: Vector, _ y: Vector) -> Vector { simd_max(x, y) }

    @inlinable public static func min(_ x: Vector, _ y: Vector) -> Vector { simd_min(x, y) }

    @inlinable public static func mix(_ x: Vector, _ y: Vector, t: Scalar) -> Vector { simd.mix(x, y, t: t) }

    @inlinable public static func normalize(_ v: Vector) -> Vector { simd.normalize(v) }

}



// MARK: SIMD where Scalar == Double

extension KvMath4 where Scalar == Double {

    @inlinable public static func abs(_ v: Vector) -> Vector { simd.abs(v) }

    @inlinable public static func clamp(_ v: Vector, _ min: Vector, _ max: Vector) -> Vector { simd_clamp(v, min, max) }

    @inlinable public static func distance(_ x: Vector, _ y: Vector) -> Scalar { simd.distance(x, y) }

    @inlinable public static func dot(_ x: Vector, _ y: Vector) -> Scalar { simd.dot(x, y) }

    @inlinable public static func length(_ v: Vector) -> Scalar { simd.length(v) }

    @inlinable public static func length_squared(_ v: Vector) -> Scalar { simd.length_squared(v) }

    @inlinable public static func max(_ x: Vector, _ y: Vector) -> Vector { simd_max(x, y) }

    @inlinable public static func min(_ x: Vector, _ y: Vector) -> Vector { simd_min(x, y) }

    @inlinable public static func mix(_ x: Vector, _ y: Vector, t: Scalar) -> Vector { simd.mix(x, y, t: t) }

    @inlinable public static func normalize(_ v: Vector) -> Vector { simd.normalize(v) }

}



// MARK: - Matrix Comparisons

@inlinable
public func KvIs(_ lhs: simd_float4x4, equalTo rhs: simd_float4x4) -> Bool {
    KvIsZero(KvMath4.max(KvMath4.abs(lhs - rhs)))
}


@inlinable
public func KvIs(_ lhs: simd_double4x4, equalTo rhs: simd_double4x4) -> Bool {
    KvIsZero(KvMath4.max(KvMath4.abs(lhs - rhs)))
}


@inlinable
public func KvIs(_ lhs: simd_float4x4, inequalTo rhs: simd_float4x4) -> Bool {
    KvIsNonzero(KvMath4.max(KvMath4.abs(lhs - rhs)))
}


@inlinable
public func KvIs(_ lhs: simd_double4x4, inequalTo rhs: simd_double4x4) -> Bool {
    KvIsNonzero(KvMath4.max(KvMath4.abs(lhs - rhs)))
}



// MARK: - Legacy

@available(*, deprecated, renamed: "KvMathFloatingPoint")
public typealias KvMathScalar4 = KvMathFloatingPoint
