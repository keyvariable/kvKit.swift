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



@available(*, deprecated, message: "Refactor related code to KvMathScope")
public typealias KvMathScalar4 = BinaryFloatingPoint & SIMDScalar



@available(*, deprecated, message: "Refactor related code to KvMathScope")
public enum KvMath4<Scalar> where Scalar : KvMathScalar4 {

    public typealias Scalar = Scalar

    public typealias Vector = SIMD4<Scalar>
    public typealias Position = Vector

}



// MARK: Matrix Fabrics <Float>

@available(*, deprecated, message: "Refactor related code to KvMathScope")
extension KvMath4 where Scalar == Float {

    @available(*, deprecated, message: "Refactor related code to KvMathScope")
    @inlinable public static func supplemented(_ base: simd_float2x2) -> simd_float4x4 {
        .init({ Vector($0.x, $0.y, 0, 0) }(base[0]),
              { Vector($0.x, $0.y, 0, 0) }(base[1]),
              [ 0, 0, 1, 0 ],
              [ 0, 0, 0, 1 ])
    }

    @available(*, deprecated, message: "Refactor related code to KvMathScope")
    @inlinable public static func supplemented(_ base: simd_float2x3) -> simd_float4x4 {
        .init(Vector(base[0], 0), Vector(base[1], 0), [ 0, 0, 1, 0 ], [ 0, 0, 0, 1 ])
    }

    @available(*, deprecated, message: "Refactor related code to KvMathScope")
    @inlinable public static func supplemented(_ base: simd_float2x4) -> simd_float4x4 {
        .init(base[0], base[1], [ 0, 0, 1, 0 ], [ 0, 0, 0, 1 ])
    }

    @available(*, deprecated, message: "Refactor related code to KvMathScope")
    @inlinable public static func supplemented(_ base: simd_float3x2) -> simd_float4x4 {
        .init({ Vector($0.x, $0.y, 0, 0) }(base[0]),
              { Vector($0.x, $0.y, 0, 0) }(base[1]),
              { Vector($0.x, $0.y, 1, 0) }(base[2]),
              [ 0, 0, 0, 1 ])
    }

    @available(*, deprecated, message: "Refactor related code to KvMathScope")
    @inlinable public static func supplemented(_ base: simd_float3x3) -> simd_float4x4 {
        .init(Vector(base[0], 0), Vector(base[1], 0), Vector(base[2], 0), [ 0, 0, 0, 1 ])
    }

    @available(*, deprecated, message: "Refactor related code to KvMathScope")
    @inlinable public static func supplemented(_ base: simd_float3x4) -> simd_float4x4 {
        .init(base[0], base[1], base[2], [ 0, 0, 0, 1 ])
    }

    @available(*, deprecated, message: "Refactor related code to KvMathScope")
    @inlinable public static func supplemented(_ base: simd_float4x2) -> simd_float4x4 {
        .init({ Vector($0.x, $0.y, 0, 0) }(base[0]),
              { Vector($0.x, $0.y, 0, 0) }(base[1]),
              { Vector($0.x, $0.y, 1, 0) }(base[2]),
              { Vector($0.x, $0.y, 0, 1) }(base[3]))
    }

    @available(*, deprecated, message: "Refactor related code to KvMathScope")
    @inlinable public static func supplemented(_ base: simd_float4x3) -> simd_float4x4 {
        .init(Vector(base[0], 0), Vector(base[1], 0), Vector(base[2], 0), Vector(base[3], 1))
    }

}



// MARK: Matrix Fabrics <Float>

@available(*, deprecated, message: "Refactor related code to KvMathScope")
extension KvMath4 where Scalar == Double {

    @available(*, deprecated, message: "Refactor related code to KvMathScope")
    @inlinable public static func supplemented(_ base: simd_double2x2) -> simd_double4x4 {
        .init({ Vector($0.x, $0.y, 0, 0) }(base[0]),
              { Vector($0.x, $0.y, 0, 0) }(base[1]),
              [ 0, 0, 1, 0 ],
              [ 0, 0, 0, 1 ])
    }

    @available(*, deprecated, message: "Refactor related code to KvMathScope")
    @inlinable public static func supplemented(_ base: simd_double2x3) -> simd_double4x4 {
        .init(Vector(base[0], 0), Vector(base[1], 0), [ 0, 0, 1, 0 ], [ 0, 0, 0, 1 ])
    }

    @available(*, deprecated, message: "Refactor related code to KvMathScope")
    @inlinable public static func supplemented(_ base: simd_double2x4) -> simd_double4x4 {
        .init(base[0], base[1], [ 0, 0, 1, 0 ], [ 0, 0, 0, 1 ])
    }

    @available(*, deprecated, message: "Refactor related code to KvMathScope")
    @inlinable public static func supplemented(_ base: simd_double3x2) -> simd_double4x4 {
        .init({ Vector($0.x, $0.y, 0, 0) }(base[0]),
              { Vector($0.x, $0.y, 0, 0) }(base[1]),
              { Vector($0.x, $0.y, 1, 0) }(base[2]),
              [ 0, 0, 0, 1 ])
    }

    @available(*, deprecated, message: "Refactor related code to KvMathScope")
    @inlinable public static func supplemented(_ base: simd_double3x3) -> simd_double4x4 {
        .init(Vector(base[0], 0), Vector(base[1], 0), Vector(base[2], 0), [ 0, 0, 0, 1 ])
    }

    @available(*, deprecated, message: "Refactor related code to KvMathScope")
    @inlinable public static func supplemented(_ base: simd_double3x4) -> simd_double4x4 {
        .init(base[0], base[1], base[2], [ 0, 0, 0, 1 ])
    }

    @available(*, deprecated, message: "Refactor related code to KvMathScope")
    @inlinable public static func supplemented(_ base: simd_double4x2) -> simd_double4x4 {
        .init({ Vector($0.x, $0.y, 0, 0) }(base[0]),
              { Vector($0.x, $0.y, 0, 0) }(base[1]),
              { Vector($0.x, $0.y, 1, 0) }(base[2]),
              { Vector($0.x, $0.y, 0, 1) }(base[3]))
    }

    @available(*, deprecated, message: "Refactor related code to KvMathScope")
    @inlinable public static func supplemented(_ base: simd_double4x3) -> simd_double4x4 {
        .init(Vector(base[0], 0), Vector(base[1], 0), Vector(base[2], 0), Vector(base[3], 1))
    }

}



// MARK: Martix Operations <Float>

@available(*, deprecated, message: "Refactor related code to KvMathScope")
extension KvMath4 where Scalar == Float {

    @available(*, deprecated, message: "Refactor related code to KvMathScope")
    @inlinable public static func abs(_ matrix: simd_float4x4) -> simd_float4x4 {
        .init(simd.abs(matrix[0]), simd.abs(matrix[1]), simd.abs(matrix[2]), simd.abs(matrix[3]))
    }

    @available(*, deprecated, message: "Refactor related code to KvMathScope")
    @inlinable public static func min(_ matrix: simd_float4x4) -> Scalar {
        Swift.min(matrix[0].min(), matrix[1].min(), matrix[2].min(), matrix[3].min())
    }

    @available(*, deprecated, message: "Refactor related code to KvMathScope")
    @inlinable public static func max(_ matrix: simd_float4x4) -> Scalar {
        Swift.max(matrix[0].max(), matrix[1].max(), matrix[2].max(), matrix[3].max())
    }

}



// MARK: Martix Operations <Double>

@available(*, deprecated, message: "Refactor related code to KvMathScope")
extension KvMath4 where Scalar == Double {

    @available(*, deprecated, message: "Refactor related code to KvMathScope")
    @inlinable public static func abs(_ matrix: simd_double4x4) -> simd_double4x4 {
        .init(simd.abs(matrix[0]), simd.abs(matrix[1]), simd.abs(matrix[2]), simd.abs(matrix[3]))
    }

    @available(*, deprecated, message: "Refactor related code to KvMathScope")
    @inlinable public static func min(_ matrix: simd_double4x4) -> Scalar {
        Swift.min(matrix[0].min(), matrix[1].min(), matrix[2].min(), matrix[3].min())
    }

    @available(*, deprecated, message: "Refactor related code to KvMathScope")
    @inlinable public static func max(_ matrix: simd_double4x4) -> Scalar {
        Swift.max(matrix[0].max(), matrix[1].max(), matrix[2].max(), matrix[3].max())
    }

}



// MARK: Transformations <Float>

@available(*, deprecated, message: "Refactor related code to KvMathScope")
extension KvMath4 where Scalar == Float {

    @available(*, deprecated, message: "Refactor related code to KvMathScope")
    @inlinable public static func scale(from matrix: simd_float4x4) -> Vector {
        .init(x: simd.length(matrix[0]) * (KvIsNotNegative(simd_determinant(matrix)) ? 1 : -1),
              y: simd.length(matrix[1]),
              z: simd.length(matrix[2]),
              w: simd.length(matrix[3]))
    }

    @available(*, deprecated, message: "Refactor related code to KvMathScope")
    @inlinable public static func scale²(from matrix: simd_float4x4) -> Vector {
        .init(x: simd.length_squared(matrix[0]),
              y: simd.length_squared(matrix[1]),
              z: simd.length_squared(matrix[2]),
              w: simd.length_squared(matrix[3]))
    }

    @available(*, deprecated, message: "Refactor related code to KvMathScope")
    @inlinable public static func setScale(_ scale: Vector, to matrix: inout simd_float4x4) {
        let s = scale * rsqrt(self.scale²(from: matrix))

        matrix[0] *= s.x * (KvIsNotNegative(simd_determinant(matrix)) ? 1 : -1)
        matrix[1] *= s.y
        matrix[2] *= s.z
        matrix[3] *= s.w
    }

}



// MARK: Transformations <Double>

@available(*, deprecated, message: "Refactor related code to KvMathScope")
extension KvMath4 where Scalar == Double {

    @available(*, deprecated, message: "Refactor related code to KvMathScope")
    @inlinable public static func scale(from matrix: simd_double4x4) -> Vector {
        .init(x: simd.length(matrix[0]) * (KvIsNotNegative(simd_determinant(matrix)) ? 1 : -1),
              y: simd.length(matrix[1]),
              z: simd.length(matrix[2]),
              w: simd.length(matrix[3]))
    }

    @available(*, deprecated, message: "Refactor related code to KvMathScope")
    @inlinable public static func scale²(from matrix: simd_double4x4) -> Vector {
        .init(x: simd.length_squared(matrix[0]),
              y: simd.length_squared(matrix[1]),
              z: simd.length_squared(matrix[2]),
              w: simd.length_squared(matrix[3]))
    }

    @available(*, deprecated, message: "Refactor related code to KvMathScope")
    @inlinable public static func setScale(_ scale: Vector, to matrix: inout simd_double4x4) {
        let s = scale * rsqrt(self.scale²(from: matrix))

        matrix[0] *= s.x * (KvIsNotNegative(simd_determinant(matrix)) ? 1 : -1)
        matrix[1] *= s.y
        matrix[2] *= s.z
        matrix[3] *= s.w
    }

}



// MARK: - Matrix Comparisons

@available(*, deprecated, message: "Refactor related code to KvMathScope")
@inlinable public func KvIs(_ lhs: simd_float4x4, equalTo rhs: simd_float4x4) -> Bool {
    KvIsZero(KvMath4.max(KvMath4.abs(lhs - rhs)))
}

@available(*, deprecated, message: "Refactor related code to KvMathScope")
@inlinable public func KvIs(_ lhs: simd_double4x4, equalTo rhs: simd_double4x4) -> Bool {
    KvIsZero(KvMath4.max(KvMath4.abs(lhs - rhs)))
}

@available(*, deprecated, message: "Refactor related code to KvMathScope")
@inlinable public func KvIs(_ lhs: simd_float4x4, inequalTo rhs: simd_float4x4) -> Bool {
    KvIsNonzero(KvMath4.max(KvMath4.abs(lhs - rhs)))
}

@available(*, deprecated, message: "Refactor related code to KvMathScope")
@inlinable public func KvIs(_ lhs: simd_double4x4, inequalTo rhs: simd_double4x4) -> Bool {
    KvIsNonzero(KvMath4.max(KvMath4.abs(lhs - rhs)))
}
