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
//  KvSimdMatrix.swift
//  kvKit
//
//  Created by Svyatoslav Popov on 14.09.2022.
//
//===----------------------------------------------------------------------===//
//
//  Collection of convenient protocols for standard SIMD matrices,
//  helping to provide scalar type independent generic code.
//

import simd



// MARK: - KvSimdMatrix

/// Common protocol for standard SIMD matrix types with additional conformance to *Hashable* and *Codable* protocols.
///
/// Conformance to *Hashable* is implemented as standard combination of column hashes.
///
/// Conformance to *Codable*. Matrices are encoded as plain arrays of it's scalars.
public protocol KvSimdMatrix : Equatable, Hashable, Codable, CustomDebugStringConvertible {

    associatedtype Scalar : SIMDScalar & BinaryFloatingPoint

    associatedtype Row
    associatedtype Column
    associatedtype Diagonal

    associatedtype Transpose


    // MARK: Properties

    static var zero: Self { get }


    var transpose: Transpose { get }


    // MARK: Initialization

    init()

    init(_ scalar: Scalar)

    init(diagonal: Diagonal)

    init(_ columns: [Column])

    init(rows: [Row])


    // MARK: Subscripts

    subscript(column: Int) -> Column { get set }

    subscript(column: Int, row: Int) -> Scalar { get set }


    // MARK: Operators

    prefix static func -(rhs: Self) -> Self

    static func +(lhs: Self, rhs: Self) -> Self

    static func -(lhs: Self, rhs: Self) -> Self

    static func +=(lhs: inout Self, rhs: Self)

    static func -=(lhs: inout Self, rhs: Self)

    static func *(lhs: Scalar, rhs: Self) -> Self

    static func *(lhs: Self, rhs: Scalar) -> Self

    static func *=(lhs: inout Self, rhs: Scalar)

    static func *(lhs: Self, rhs: Row) -> Column

    static func *(lhs: Column, rhs: Self) -> Row

}



// MARK: - KvSimdSquareMatrix

public protocol KvSimdSquareMatrix : KvSimdMatrix
where Row == Column, Diagonal == Row, Transpose == Self
{

    static var identity: Self { get }


    var determinant: Scalar { get }

    @available(macOS 10.10, iOS 8.0, tvOS 10.0, watchOS 3.0, *)
    var inverse: Self { get }


    // MARK: Operators

    static func *(lhs: Self, rhs: Self) -> Self

    static func *=(lhs: inout Self, rhs: Self)

}



// MARK: - KvSimd2xN

/// Common protocol for standard SIMD 2×N matrix types.
public protocol KvSimd2xN : KvSimdMatrix
where Row == SIMD2<Scalar>
{

    var columns: (Column, Column) { get set }


    // MARK: Initialization

    init(_ col0: Column, _ col1: Column)

    init(columns: (Column, Column))

}



// MARK: - KvSimd3xN

/// Common protocol for standard SIMD 3×N matrix types.
public protocol KvSimd3xN : KvSimdMatrix
where Row == SIMD3<Scalar>
{

    var columns: (Column, Column, Column) { get set }


    // MARK: Initialization

    init(_ col0: Column, _ col1: Column, _ col2: Column)

    init(columns: (Column, Column, Column))

}



// MARK: - KvSimd4xN

/// Common protocol for standard SIMD 4×N matrix types.
public protocol KvSimd4xN : KvSimdMatrix
where Row == SIMD4<Scalar>
{

    var columns: (Column, Column, Column, Column) { get set }


    // MARK: Initialization

    init(_ col0: Column, _ col1: Column, _ col2: Column, _ col3: Column)

    init(columns: (Column, Column, Column, Column))

}



// MARK: - KvSimd2x2

/// Common protocol for standard SIMD 2×2 matrix types.
public protocol KvSimd2x2 : KvSimd2xN, KvSimdSquareMatrix {

    init(angle: Scalar)

}


extension KvSimd2x2 {

    // MARK: : Hashable

    @inlinable
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self[0])
        hasher.combine(self[1])
    }


    // MARK: : Codable

    @inlinable
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()


        func DecodeScalar() throws -> Scalar { try container.decode(Scalar.self) }

        func DecodeColumn() throws -> Column { try Column(DecodeScalar(), DecodeScalar()) }


        try self.init(DecodeColumn(), DecodeColumn())
    }


    @inlinable
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()


        func EncodeColumn(_ column: Column) throws {
            try container.encode(column.x)
            try container.encode(column.y)
        }


        try EncodeColumn(self[0])
        try EncodeColumn(self[1])
    }

}



// MARK: - KvSimd2x3

/// Common protocol for standard SIMD 2×3 matrix types.
public protocol KvSimd2x3 : KvSimd2xN
where Column == SIMD3<Scalar>, Diagonal == SIMD2<Scalar>, Transpose : KvSimd3x2
{ }


extension KvSimd2x3 {

    // MARK: : Hashable

    @inlinable
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self[0])
        hasher.combine(self[1])
    }


    // MARK: : Codable

    @inlinable
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()


        func DecodeScalar() throws -> Scalar { try container.decode(Scalar.self) }

        func DecodeColumn() throws -> Column { try Column(DecodeScalar(), DecodeScalar(), DecodeScalar()) }


        try self.init(DecodeColumn(), DecodeColumn())
    }


    @inlinable
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()


        func EncodeColumn(_ column: Column) throws {
            try container.encode(column.x)
            try container.encode(column.y)
            try container.encode(column.z)
        }


        try EncodeColumn(self[0])
        try EncodeColumn(self[1])
    }

}



// MARK: - KvSimd2x4

/// Common protocol for standard SIMD 2×4 matrix types.
public protocol KvSimd2x4 : KvSimd2xN
where Column == SIMD4<Scalar>, Diagonal == SIMD2<Scalar>, Transpose : KvSimd4x2
{ }


extension KvSimd2x4 {

    // MARK: : Hashable

    @inlinable
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self[0])
        hasher.combine(self[1])
    }


    // MARK: : Codable

    @inlinable
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()


        func DecodeScalar() throws -> Scalar { try container.decode(Scalar.self) }

        func DecodeColumn() throws -> Column { try Column(DecodeScalar(), DecodeScalar(), DecodeScalar(), DecodeScalar()) }


        try self.init(DecodeColumn(), DecodeColumn())
    }


    @inlinable
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()


        func EncodeColumn(_ column: Column) throws {
            try container.encode(column.x)
            try container.encode(column.y)
            try container.encode(column.z)
            try container.encode(column.w)
        }


        try EncodeColumn(self[0])
        try EncodeColumn(self[1])
    }

}



// MARK: - KvSimd3x2

/// Common protocol for standard SIMD 3×2 matrix types.
public protocol KvSimd3x2 : KvSimd3xN
where Column == SIMD2<Scalar>, Diagonal == SIMD2<Scalar>, Transpose : KvSimd2x3
{ }


extension KvSimd3x2 {

    // MARK: : Hashable

    @inlinable
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self[0])
        hasher.combine(self[1])
        hasher.combine(self[2])
    }


    // MARK: : Codable

    @inlinable
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()


        func DecodeScalar() throws -> Scalar { try container.decode(Scalar.self) }

        func DecodeColumn() throws -> Column { try Column(DecodeScalar(), DecodeScalar()) }


        try self.init(DecodeColumn(), DecodeColumn(), DecodeColumn())
    }


    @inlinable
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()


        func EncodeColumn(_ column: Column) throws {
            try container.encode(column.x)
            try container.encode(column.y)
        }


        try EncodeColumn(self[0])
        try EncodeColumn(self[1])
        try EncodeColumn(self[2])
    }

}



// MARK: - KvSimd3x3

/// Common protocol for standard SIMD 3×3 matrix types.
public protocol KvSimd3x3 : KvSimd3xN, KvSimdSquareMatrix {

    associatedtype Quaternion


    // MARK: Initialization

    init(_ quaternion: Quaternion)

}


extension KvSimd3x3 {

    // MARK: : Hashable

    @inlinable
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self[0])
        hasher.combine(self[1])
        hasher.combine(self[2])
    }


    // MARK: : Codable

    @inlinable
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()


        func DecodeScalar() throws -> Scalar { try container.decode(Scalar.self) }

        func DecodeColumn() throws -> Column { try Column(DecodeScalar(), DecodeScalar(), DecodeScalar()) }


        try self.init(DecodeColumn(), DecodeColumn(), DecodeColumn())
    }


    @inlinable
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()


        func EncodeColumn(_ column: Column) throws {
            try container.encode(column.x)
            try container.encode(column.y)
            try container.encode(column.z)
        }


        try EncodeColumn(self[0])
        try EncodeColumn(self[1])
        try EncodeColumn(self[2])
    }

}



// MARK: - KvSimd3x4

/// Common protocol for standard SIMD 3×4 matrix types.
public protocol KvSimd3x4 : KvSimd3xN
where Column == SIMD4<Scalar>, Diagonal == SIMD3<Scalar>, Transpose : KvSimd4x3
{ }


extension KvSimd3x4 {

    // MARK: : Hashable

    @inlinable
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self[0])
        hasher.combine(self[1])
        hasher.combine(self[2])
    }


    // MARK: : Codable

    @inlinable
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()


        func DecodeScalar() throws -> Scalar { try container.decode(Scalar.self) }

        func DecodeColumn() throws -> Column { try Column(DecodeScalar(), DecodeScalar(), DecodeScalar(), DecodeScalar()) }


        try self.init(DecodeColumn(), DecodeColumn(), DecodeColumn())
    }


    @inlinable
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()


        func EncodeColumn(_ column: Column) throws {
            try container.encode(column.x)
            try container.encode(column.y)
            try container.encode(column.z)
            try container.encode(column.w)
        }


        try EncodeColumn(self[0])
        try EncodeColumn(self[1])
        try EncodeColumn(self[2])
    }

}



// MARK: - KvSimd4x2

/// Common protocol for standard SIMD 4×2 matrix types.
public protocol KvSimd4x2 : KvSimd4xN
where Column == SIMD2<Scalar>, Diagonal == SIMD2<Scalar>, Transpose : KvSimd2x4
{ }


extension KvSimd4x2 {

    // MARK: : Hashable

    @inlinable
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self[0])
        hasher.combine(self[1])
        hasher.combine(self[2])
        hasher.combine(self[3])
    }


    // MARK: : Codable

    @inlinable
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()


        func DecodeScalar() throws -> Scalar { try container.decode(Scalar.self) }

        func DecodeColumn() throws -> Column { try Column(DecodeScalar(), DecodeScalar()) }


        try self.init(DecodeColumn(), DecodeColumn(), DecodeColumn(), DecodeColumn())
    }


    @inlinable
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()


        func EncodeColumn(_ column: Column) throws {
            try container.encode(column.x)
            try container.encode(column.y)
        }


        try EncodeColumn(self[0])
        try EncodeColumn(self[1])
        try EncodeColumn(self[2])
        try EncodeColumn(self[3])
    }

}



// MARK: - KvSimd4x3

/// Common protocol for standard SIMD 4×3 matrix types.
public protocol KvSimd4x3 : KvSimd4xN
where Column == SIMD3<Scalar>, Diagonal == SIMD3<Scalar>, Transpose : KvSimd3x4
{ }


extension KvSimd4x3 {

    // MARK: : Hashable

    @inlinable
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self[0])
        hasher.combine(self[1])
        hasher.combine(self[2])
        hasher.combine(self[3])
    }


    // MARK: : Codable

    @inlinable
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()


        func DecodeScalar() throws -> Scalar { try container.decode(Scalar.self) }

        func DecodeColumn() throws -> Column { try Column(DecodeScalar(), DecodeScalar(), DecodeScalar()) }


        try self.init(DecodeColumn(), DecodeColumn(), DecodeColumn(), DecodeColumn())
    }


    @inlinable
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()


        func EncodeColumn(_ column: Column) throws {
            try container.encode(column.x)
            try container.encode(column.y)
            try container.encode(column.z)
        }


        try EncodeColumn(self[0])
        try EncodeColumn(self[1])
        try EncodeColumn(self[2])
        try EncodeColumn(self[3])
    }

}



// MARK: - KvSimd4x4

/// Common protocol for standard SIMD 4×4 matrix types.
public protocol KvSimd4x4 : KvSimd4xN, KvSimdSquareMatrix {

    associatedtype Quaternion


    // MARK: Initialization

    init(_ quaternion: Quaternion)

}


extension KvSimd4x4 {

    // MARK: : Hashable

    @inlinable
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self[0])
        hasher.combine(self[1])
        hasher.combine(self[2])
        hasher.combine(self[3])
    }


    // MARK: : Codable

    @inlinable
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()


        func DecodeScalar() throws -> Scalar { try container.decode(Scalar.self) }

        func DecodeColumn() throws -> Column { try Column(DecodeScalar(), DecodeScalar(), DecodeScalar(), DecodeScalar()) }


        try self.init(DecodeColumn(), DecodeColumn(), DecodeColumn(), DecodeColumn())
    }


    @inlinable
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()


        func EncodeColumn(_ column: Column) throws {
            try container.encode(column.x)
            try container.encode(column.y)
            try container.encode(column.z)
            try container.encode(column.w)
        }


        try EncodeColumn(self[0])
        try EncodeColumn(self[1])
        try EncodeColumn(self[2])
        try EncodeColumn(self[3])
    }

}



// MARK: - simd_float2x2

extension simd_float2x2 : KvSimd2x2 {

    public static let zero = Self()

    @inlinable public static var identity: Self { matrix_identity_float2x2 }


    @inlinable
    public init(angle: Scalar) {
        let sincos = __sincosf_stret(angle)
        self.init(Column( sincos.__cosval, sincos.__sinval),
                  Column(-sincos.__sinval, sincos.__cosval))
    }

}


// MARK: - simd_double2x2

extension simd_double2x2 : KvSimd2x2 {

    public static let zero = Self()

    @inlinable public static var identity: Self { matrix_identity_double2x2 }


    @inlinable
    public init(angle: Scalar) {
        let sincos = __sincos_stret(angle)
        self.init(Column( sincos.__cosval, sincos.__sinval),
                  Column(-sincos.__sinval, sincos.__cosval))
    }

}


// MARK: - simd_float2x3

extension simd_float2x3 : KvSimd2x3 {

    public static let zero = Self()

}


// MARK: - simd_double2x3

extension simd_double2x3 : KvSimd2x3 {

    public static let zero = Self()

}

// MARK: - simd_float2x4

extension simd_float2x4 : KvSimd2x4 {

    public static let zero = Self()

}


// MARK: - simd_double2x4

extension simd_double2x4 : KvSimd2x4 {

    public static let zero = Self()

}


// MARK: - simd_float3x2

extension simd_float3x2 : KvSimd3x2 {

    public static let zero = Self()

}


// MARK: - simd_double3x2

extension simd_double3x2 : KvSimd3x2 {

    public static let zero = Self()

}


// MARK: - simd_float3x3

extension simd_float3x3 : KvSimd3x3 {

    public typealias Quaternion = simd_quatf


    public static let zero = Self()

    @inlinable public static var identity: Self { matrix_identity_float3x3 }

}


// MARK: - simd_double3x3

extension simd_double3x3 : KvSimd3x3 {

    public typealias Quaternion = simd_quatd


    public static let zero = Self()

    @inlinable public static var identity: Self { matrix_identity_double3x3 }

}


// MARK: - simd_float3x4

extension simd_float3x4 : KvSimd3x4 {

    public static let zero = Self()

}


// MARK: - simd_double3x4

extension simd_double3x4 : KvSimd3x4 {

    public static let zero = Self()

}


// MARK: - simd_float4x2

extension simd_float4x2 : KvSimd4x2 {

    public static let zero = Self()

}


// MARK: - simd_double4x2

extension simd_double4x2 : KvSimd4x2 {

    public static let zero = Self()

}


// MARK: - simd_float4x3

extension simd_float4x3 : KvSimd4x3 {

    public static let zero = Self()

}


// MARK: - simd_double4x3

extension simd_double4x3 : KvSimd4x3 {

    public static let zero = Self()

}


// MARK: - simd_float4x4

extension simd_float4x4 : KvSimd4x4 {

    public typealias Quaternion = simd_quatf


    public static let zero = Self()

    @inlinable public static var identity: Self { matrix_identity_float4x4 }

}


// MARK: - simd_double4x4

extension simd_double4x4 : KvSimd4x4 {

    public typealias Quaternion = simd_quatd


    public static let zero = Self()

    @inlinable public static var identity: Self { matrix_identity_double4x4 }

}
