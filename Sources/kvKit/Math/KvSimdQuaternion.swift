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
//  KvSimdQuaternion.swift
//  kvKit
//
//  Created by Svyatoslav Popov on 19.09.2022.
//
//===----------------------------------------------------------------------===//
//
//  Collection of convinient protocols for SIMD quaternions to provide scalar independent generic math code.
//

import simd



// MARK: - KvSimdQuaternion

public protocol KvSimdQuaternion : Equatable, CustomDebugStringConvertible {

    associatedtype Scalar : SIMDScalar & BinaryFloatingPoint

    associatedtype Matrix3x3
    associatedtype Matrix4x4


    // MARK: Static Properties

    /// Rotation for zero angle.
    static var zeroAngle: Self { get }


    // MARK: Properties

    var vector: SIMD4<Scalar> { get set }

    var real: Scalar { get set }
    var imag: SIMD3<Scalar> { get set }

    var angle: Scalar { get }
    var axis: SIMD3<Scalar> { get }

    var conjugate: Self { get }
    var inverse: Self { get }

    var normalized: Self { get }

    var length: Scalar { get }


    // MARK: Initialization

    init()

    init(vector: SIMD4<Scalar>)

    init(ix: Scalar, iy: Scalar, iz: Scalar, r: Scalar)

    init(real: Scalar, imag: SIMD3<Scalar>)

    init(angle: Scalar, axis: SIMD3<Scalar>)

    init(from: SIMD3<Scalar>, to: SIMD3<Scalar>)

    init(_ rotationMatrix: Matrix3x3)

    init(_ rotationMatrix: Matrix4x4)


    // MARK: Operations

    func act(_ vector: SIMD3<Scalar>) -> SIMD3<Scalar>


    // MARK: Operators

    static func ==(lhs: Self, rhs: Self) -> Bool

    static prefix func -(rhs: Self) -> Self

    static func +(lhs: Self, rhs: Self) -> Self

    static func +=(lhs: inout Self, rhs: Self)

    static func -(lhs: Self, rhs: Self) -> Self

    static func -=(lhs: inout Self, rhs: Self)

    static func *(lhs: Self, rhs: Self) -> Self

    static func *(lhs: Scalar, rhs: Self) -> Self

    static func *(lhs: Self, rhs: Scalar) -> Self

    static func *=(lhs: inout Self, rhs: Self)

    static func *=(lhs: inout Self, rhs: Scalar)

    static func /(lhs: Self, rhs: Self) -> Self

    static func /(lhs: Self, rhs: Scalar) -> Self

    static func /=(lhs: inout Self, rhs: Self)

    static func /=(lhs: inout Self, rhs: Scalar)

}



// MARK: - simd_quatf

extension simd_quatf : KvSimdQuaternion {

    public typealias Matrix3x3 = simd_float3x3
    public typealias Matrix4x4 = simd_float4x4


    // MARK: Static Properties

    /// Rotation for zero angle.
    public static var zeroAngle: Self { Self(vector: [ 0, 0, 0, 1 ]) }

}



// MARK: - simd_quatd

extension simd_quatd : KvSimdQuaternion {

    public typealias Matrix3x3 = simd_double3x3
    public typealias Matrix4x4 = simd_double4x4


    // MARK: Static Properties

    /// Rotation for zero angle.
    public static var zeroAngle: Self { Self(vector: [ 0, 0, 0, 1 ]) }

}
