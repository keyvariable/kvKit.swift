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



public enum KvMath4<Scalar> where Scalar : BinaryFloatingPoint & Comparable & SIMDScalar {

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
