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
//  KvSimdMatrix.swift
//  kvKit
//
//  Created by Svyatoslav Popov on 14.09.2022.
//
//===----------------------------------------------------------------------===//
//
//  Collection of missing protocols and convenient wrappers for standard SIMD matrices.
//  These protocols and wrappers help to prevent coding overhead when dealing with «`\simd_(float|double)\d_\d`» types, duplication of code etc.
//

import simd



// MARK: - KvSimdMatrixScalar

public protocol KvSimdMatrixScalar : SIMDScalar, BinaryFloatingPoint, Codable {

    associatedtype Matrix2x2 : KvSimd2x2
    where Matrix2x2.Scalar == Self, Matrix2x2.Transpose == Matrix2x2

    associatedtype Matrix2x3 : KvSimd2x3
    where Matrix2x3.Scalar == Self, Matrix2x3.Transpose == Matrix3x2

    associatedtype Matrix2x4 : KvSimd2x4
    where Matrix2x4.Scalar == Self, Matrix2x4.Transpose == Matrix4x2

    associatedtype Matrix3x2 : KvSimd3x2
    where Matrix3x2.Scalar == Self, Matrix3x2.Transpose == Matrix2x3

    associatedtype Matrix3x3 : KvSimd3x3
    where Matrix3x3.Scalar == Self, Matrix3x3.Transpose == Matrix3x3

    associatedtype Matrix3x4 : KvSimd3x4
    where Matrix3x4.Scalar == Self, Matrix3x4.Transpose == Matrix4x3

    associatedtype Matrix4x2 : KvSimd4x2
    where Matrix4x2.Scalar == Self, Matrix4x2.Transpose == Matrix2x4

    associatedtype Matrix4x3 : KvSimd4x3
    where Matrix4x3.Scalar == Self, Matrix4x3.Transpose == Matrix3x4

    associatedtype Matrix4x4 : KvSimd4x4
    where Matrix4x4.Scalar == Self, Matrix4x4.Transpose == Matrix4x4

}


extension Float : KvSimdMatrixScalar {

    public typealias Matrix2x2 = simd_float2x2
    public typealias Matrix2x3 = simd_float2x3
    public typealias Matrix2x4 = simd_float2x4

    public typealias Matrix3x2 = simd_float3x2
    public typealias Matrix3x3 = simd_float3x3
    public typealias Matrix3x4 = simd_float3x4

    public typealias Matrix4x2 = simd_float4x2
    public typealias Matrix4x3 = simd_float4x3
    public typealias Matrix4x4 = simd_float4x4

}

extension Double : KvSimdMatrixScalar {

    public typealias Matrix2x2 = simd_double2x2
    public typealias Matrix2x3 = simd_double2x3
    public typealias Matrix2x4 = simd_double2x4

    public typealias Matrix3x2 = simd_double3x2
    public typealias Matrix3x3 = simd_double3x3
    public typealias Matrix3x4 = simd_double3x4

    public typealias Matrix4x2 = simd_double4x2
    public typealias Matrix4x3 = simd_double4x3
    public typealias Matrix4x4 = simd_double4x4

}






// MARK: - KvSimdMatrix

/// Common protocol for standard SIMD matrix types.
public protocol KvSimdMatrix : Equatable {

    associatedtype Scalar : KvSimdMatrixScalar

    associatedtype Row : KvSimdVectorF where Row.Scalar == Scalar
    associatedtype Column : KvSimdVectorF where Column.Scalar == Scalar
    associatedtype Diagonal : KvSimdVectorF where Diagonal.Scalar == Scalar

    associatedtype Transpose : KvSimdMatrix where Transpose.Scalar == Scalar


    // MARK: Properties

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
where Transpose == Self
{

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
where Row : KvSimd2F
{

    var columns: (Column, Column) { get set }


    // MARK: Initialization

    init(_ col0: Column, _ col1: Column)

    init(columns: (Column, Column))

}



// MARK: - KvSimdNx2

/// Common protocol for standard SIMD N×2 matrix types.
public protocol KvSimdNx2 : KvSimdMatrix
where Column : KvSimd2F
{ }



// MARK: - KvSimd3xN

/// Common protocol for standard SIMD 3×N matrix types.
public protocol KvSimd3xN : KvSimdMatrix
where Row : KvSimd3F
{

    var columns: (Column, Column, Column) { get set }


    // MARK: Initialization

    init(_ col0: Column, _ col1: Column, _ col2: Column)

    init(columns: (Column, Column, Column))

}



// MARK: - KvSimdNx3

/// Common protocol for standard SIMD N×3 matrix types.
public protocol KvSimdNx3 : KvSimdMatrix
where Column : KvSimd3F
{ }



// MARK: - KvSimd4xN

/// Common protocol for standard SIMD 4×N matrix types.
public protocol KvSimd4xN : KvSimdMatrix
where Row : KvSimd4F
{

    var columns: (Column, Column, Column, Column) { get set }


    // MARK: Initialization

    init(_ col0: Column, _ col1: Column, _ col2: Column, _ col3: Column)

    init(columns: (Column, Column, Column, Column))

}



// MARK: - KvSimdNx4

/// Common protocol for standard SIMD N×4 matrix types.
public protocol KvSimdNx4 : KvSimdMatrix
where Column : KvSimd4F
{ }



// MARK: - KvSimd2x2

/// Common protocol for standard SIMD 2×2 matrix types.
public protocol KvSimd2x2 : KvSimd2xN, KvSimdNx2, KvSimdSquareMatrix
where Diagonal : KvSimd2F, Transpose : KvSimd2x2
{ }



// MARK: - KvSimd2x3

/// Common protocol for standard SIMD 2×3 matrix types.
public protocol KvSimd2x3 : KvSimd2xN, KvSimdNx3
where Diagonal : KvSimd2F, Transpose : KvSimd3x2
{ }



// MARK: - KvSimd2x4

/// Common protocol for standard SIMD 2×4 matrix types.
public protocol KvSimd2x4 : KvSimd2xN, KvSimdNx4
where Diagonal : KvSimd2F, Transpose : KvSimd4x2
{ }



// MARK: - KvSimd3x2

/// Common protocol for standard SIMD 3×2 matrix types.
public protocol KvSimd3x2 : KvSimd3xN, KvSimdNx2
where Diagonal : KvSimd2F, Transpose : KvSimd2x3
{ }



// MARK: - KvSimd3x3

/// Common protocol for standard SIMD 3×3 matrix types.
public protocol KvSimd3x3 : KvSimd3xN, KvSimdNx3, KvSimdSquareMatrix
where Diagonal : KvSimd3F, Transpose : KvSimd3x3
{ }



// MARK: - KvSimd3x4

/// Common protocol for standard SIMD 3×4 matrix types.
public protocol KvSimd3x4 : KvSimd3xN, KvSimdNx4
where Diagonal : KvSimd3F, Transpose : KvSimd4x3
{ }



// MARK: - KvSimd4x2

/// Common protocol for standard SIMD 4×2 matrix types.
public protocol KvSimd4x2 : KvSimd4xN, KvSimdNx2
where Diagonal : KvSimd2F, Transpose : KvSimd2x4
{ }



// MARK: - KvSimd4x3

/// Common protocol for standard SIMD 4×3 matrix types.
public protocol KvSimd4x3 : KvSimd4xN, KvSimdNx3
where Diagonal : KvSimd3F, Transpose : KvSimd3x4
{ }



// MARK: - KvSimd4x4

/// Common protocol for standard SIMD 4×4 matrix types.
public protocol KvSimd4x4 : KvSimd4xN, KvSimdNx4, KvSimdSquareMatrix
where Diagonal : KvSimd4F, Transpose : KvSimd4x4
{ }



// MARK: - KvSimdAnyMatrix

public protocol KvSimdAnyMatrix : Equatable {

    associatedtype Scalar : KvSimdMatrixScalar

    associatedtype Wrapped : KvSimdMatrix where Wrapped.Scalar == Scalar


    var wrapped: Wrapped { get set }


    init(_ wrapped: Wrapped)

}


extension KvSimdAnyMatrix {

    @inlinable
    public prefix static func -(rhs: Self) -> Self { .init(-rhs.wrapped) }


    @inlinable
    public static func +(lhs: Self, rhs: Self) -> Self { .init(lhs.wrapped + rhs.wrapped) }

    @inlinable
    public static func +(lhs: Wrapped, rhs: Self) -> Wrapped { lhs + rhs.wrapped }

    @inlinable
    public static func +(lhs: Self, rhs: Wrapped) -> Wrapped { lhs.wrapped + rhs }


    @inlinable
    public static func -(lhs: Self, rhs: Self) -> Self { .init(lhs.wrapped - rhs.wrapped) }

    @inlinable
    public static func -(lhs: Wrapped, rhs: Self) -> Wrapped { lhs - rhs.wrapped }

    @inlinable
    public static func -(lhs: Self, rhs: Wrapped) -> Wrapped { lhs.wrapped - rhs }


    @inlinable
    public static func +=(lhs: inout Self, rhs: Self) { lhs.wrapped += rhs.wrapped }

    @inlinable
    public static func +=(lhs: inout Wrapped, rhs: Self) { lhs += rhs.wrapped }

    @inlinable
    public static func +=(lhs: inout Self, rhs: Wrapped) { lhs.wrapped += rhs }


    @inlinable
    public static func -=(lhs: inout Self, rhs: Self) { lhs.wrapped -= rhs.wrapped }

    @inlinable
    public static func -=(lhs: inout Wrapped, rhs: Self) { lhs -= rhs.wrapped }
    @inlinable
    public static func -=(lhs: inout Self, rhs: Wrapped) { lhs.wrapped -= rhs }


    @inlinable
    public static func *(lhs: Scalar, rhs: Self) -> Self { .init(lhs * rhs.wrapped) }


    @inlinable
    public static func *(lhs: Self, rhs: Scalar) -> Self { .init(lhs.wrapped * rhs) }


    @inlinable
    public static func *=(lhs: inout Self, rhs: Scalar) { lhs.wrapped *= rhs }


    @inlinable
    public static func *(lhs: Self, rhs: Wrapped.Row) -> Wrapped.Column { lhs.wrapped * rhs }


    @inlinable
    public static func *(lhs: Wrapped.Column, rhs: Self) -> Wrapped.Row { lhs * rhs.wrapped }

}



// MARK: - KvSimdAnySquareMatrix

public protocol KvSimdAnySquareMatrix : KvSimdAnyMatrix
where Wrapped : KvSimdSquareMatrix
{ }


extension KvSimdAnySquareMatrix {

    @inlinable
    public static func *(lhs: Self, rhs: Self) -> Self { .init(lhs.wrapped * rhs.wrapped) }

    @inlinable
    public static func *(lhs: Wrapped, rhs: Self) -> Wrapped { lhs * rhs.wrapped }

    @inlinable
    public static func *(lhs: Self, rhs: Wrapped) -> Wrapped { lhs.wrapped * rhs }


    @inlinable
    public static func *=(lhs: inout Self, rhs: Self) { lhs.wrapped *= rhs.wrapped }

    @inlinable
    public static func *=(lhs: inout Self, rhs: Wrapped) { lhs.wrapped *= rhs }

}



// MARK: - KvSimdAny2x2

/// Lightweight wrapper for standard SIMD 2×2 matrix types.
public struct KvSimdAny2x2<Scalar> : KvSimd2x2, KvSimdAnySquareMatrix
where Scalar : KvSimdMatrixScalar
{
    public typealias Scalar = Scalar

    public typealias Row = Wrapped.Row
    public typealias Column = Wrapped.Column
    public typealias Diagonal = Wrapped.Diagonal

    public typealias Transpose = Self

    public typealias Wrapped = Scalar.Matrix2x2


    public var columns: (Column, Column) {
        @inlinable
        get { wrapped.columns }
        @inlinable
        set { wrapped.columns = newValue }
    }

    @inlinable
    public var transpose: Transpose { .init(wrapped.transpose) }

    @inlinable
    public var determinant: Scalar { wrapped.determinant }

    @inlinable
    public var inverse: Self { .init(wrapped.inverse) }


    public var wrapped: Wrapped


    @inlinable
    public init() { wrapped = .init() }

    @inlinable
    public init(_ wrapped: Wrapped) {
        self.wrapped = wrapped
    }

    @inlinable
    public init(_ scalar: Scalar) { wrapped = .init(scalar) }

    @inlinable
    public init(diagonal: Diagonal) { wrapped = .init(diagonal: diagonal) }

    @inlinable
    public init(_ columns: [Column]) { wrapped = .init(columns) }

    @inlinable
    public init(rows: [Row]) { wrapped = .init(rows: rows) }

    @inlinable
    public init(_ col0: Column, _ col1: Column) { wrapped = .init(col0, col1) }

    @inlinable
    public init(columns: (Column, Column)) { wrapped = .init(columns: columns) }


    // MARK: Subscripts

    public subscript(column: Int) -> Column {
        @inlinable
        get { wrapped[column] }
        @inlinable
        set { wrapped[column] = newValue }
    }

    public subscript(column: Int, row: Int) -> Scalar {
        @inlinable
        get { wrapped[column, row] }
        @inlinable
        set { wrapped[column, row] = newValue }
    }


    // MARK: Operators

    @inlinable
    public static func * <RHS>(lhs: Self, rhs: RHS) -> Column
    where RHS : KvSimd2F, RHS.Scalar == Scalar, RHS.SimdView == Row.SimdView
    {
        lhs.wrapped * Row(simdView: rhs.simdView)
    }


    @inlinable
    public static func * <LHS>(lhs: LHS, rhs: Self) -> Row
    where LHS : KvSimd2F, LHS.Scalar == Scalar, LHS.SimdView == Column.SimdView
    {
        Column(simdView: lhs.simdView) * rhs.wrapped
    }

}



// MARK: - KvSimdAny2x3

/// Lightweight wrapper for standard SIMD 2×3 matrix types.
public struct KvSimdAny2x3<Scalar> : KvSimd2x3, KvSimdAnyMatrix
where Scalar : KvSimdMatrixScalar
{

    public typealias Scalar = Scalar

    public typealias Row = Wrapped.Row
    public typealias Column = Wrapped.Column
    public typealias Diagonal = Wrapped.Diagonal

    public typealias Transpose = KvSimdAny3x2<Scalar>

    public typealias Wrapped = Scalar.Matrix2x3


    public var columns: (Column, Column) {
        @inlinable
        get { wrapped.columns }
        @inlinable
        set { wrapped.columns = newValue }
    }

    @inlinable
    public var transpose: Transpose { .init(wrapped.transpose) }


    public var wrapped: Wrapped


    @inlinable
    public init() { wrapped = .init() }

    @inlinable
    public init(_ wrapped: Wrapped) {
        self.wrapped = wrapped
    }

    @inlinable
    public init(_ scalar: Scalar) { wrapped = .init(scalar) }

    @inlinable
    public init(diagonal: Diagonal) { wrapped = .init(diagonal: diagonal) }

    @inlinable
    public init(_ columns: [Column]) { wrapped = .init(columns) }

    @inlinable
    public init(rows: [Row]) { wrapped = .init(rows: rows) }

    @inlinable
    public init(_ col0: Column, _ col1: Column) { wrapped = .init(col0, col1) }

    @inlinable
    public init(columns: (Column, Column)) { wrapped = .init(columns: columns) }


    // MARK: Subscripts

    public subscript(column: Int) -> Column {
        @inlinable
        get { wrapped[column] }
        @inlinable
        set { wrapped[column] = newValue }
    }

    public subscript(column: Int, row: Int) -> Scalar {
        @inlinable
        get { wrapped[column, row] }
        @inlinable
        set { wrapped[column, row] = newValue }
    }


    // MARK: Operators

    @inlinable
    public static func * <RHS>(lhs: Self, rhs: RHS) -> Column
    where RHS : KvSimd2F, RHS.Scalar == Scalar, RHS.SimdView == Row.SimdView
    {
        lhs.wrapped * Row(simdView: rhs.simdView)
    }


    @inlinable
    public static func * <LHS>(lhs: LHS, rhs: Self) -> Row
    where LHS : KvSimd3F, LHS.Scalar == Scalar, LHS.SimdView == Column.SimdView
    {
        Column(simdView: lhs.simdView) * rhs.wrapped
    }

}



// MARK: - KvSimdAny2x4

/// Lightweight wrapper for standard SIMD 2×4 matrix types.
public struct KvSimdAny2x4<Scalar> : KvSimd2x4, KvSimdAnyMatrix
where Scalar : KvSimdMatrixScalar
{

    public typealias Scalar = Scalar

    public typealias Row = Wrapped.Row
    public typealias Column = Wrapped.Column
    public typealias Diagonal = Wrapped.Diagonal

    public typealias Transpose = KvSimdAny4x2<Scalar>

    public typealias Wrapped = Scalar.Matrix2x4


    public var columns: (Column, Column) {
        @inlinable
        get { wrapped.columns }
        @inlinable
        set { wrapped.columns = newValue }
    }

    @inlinable
    public var transpose: Transpose { .init(wrapped.transpose) }


    public var wrapped: Wrapped


    @inlinable
    public init() { wrapped = .init() }

    @inlinable
    public init(_ wrapped: Wrapped) {
        self.wrapped = wrapped
    }

    @inlinable
    public init(_ scalar: Scalar) { wrapped = .init(scalar) }

    @inlinable
    public init(diagonal: Diagonal) { wrapped = .init(diagonal: diagonal) }

    @inlinable
    public init(_ columns: [Column]) { wrapped = .init(columns) }

    @inlinable
    public init(rows: [Row]) { wrapped = .init(rows: rows) }

    @inlinable
    public init(_ col0: Column, _ col1: Column) { wrapped = .init(col0, col1) }

    @inlinable
    public init(columns: (Column, Column)) { wrapped = .init(columns: columns) }


    // MARK: Subscripts

    public subscript(column: Int) -> Column {
        @inlinable
        get { wrapped[column] }
        @inlinable
        set { wrapped[column] = newValue }
    }

    public subscript(column: Int, row: Int) -> Scalar {
        @inlinable
        get { wrapped[column, row] }
        @inlinable
        set { wrapped[column, row] = newValue }
    }


    // MARK: Operators

    @inlinable
    public static func * <RHS>(lhs: Self, rhs: RHS) -> Column
    where RHS : KvSimd2F, RHS.Scalar == Scalar, RHS.SimdView == Row.SimdView
    {
        lhs.wrapped * Row(simdView: rhs.simdView)
    }


    @inlinable
    public static func * <LHS>(lhs: LHS, rhs: Self) -> Row
    where LHS : KvSimd4F, LHS.Scalar == Scalar, LHS.SimdView == Column.SimdView
    {
        Column(simdView: lhs.simdView) * rhs.wrapped
    }

}



// MARK: - KvSimdAny3x2

/// Lightweight wrapper for standard SIMD 3×2 matrix types.
public struct KvSimdAny3x2<Scalar> : KvSimd3x2, KvSimdAnyMatrix
where Scalar : KvSimdMatrixScalar
{

    public typealias Scalar = Scalar

    public typealias Row = Wrapped.Row
    public typealias Column = Wrapped.Column
    public typealias Diagonal = Wrapped.Diagonal

    public typealias Transpose = KvSimdAny2x3<Scalar>

    public typealias Wrapped = Scalar.Matrix3x2


    public var columns: (Column, Column, Column) {
        @inlinable
        get { wrapped.columns }
        @inlinable
        set { wrapped.columns = newValue }
    }

    @inlinable
    public var transpose: Transpose { .init(wrapped.transpose) }


    public var wrapped: Wrapped


    @inlinable
    public init() { wrapped = .init() }

    @inlinable
    public init(_ wrapped: Wrapped) {
        self.wrapped = wrapped
    }

    @inlinable
    public init(_ scalar: Scalar) { wrapped = .init(scalar) }

    @inlinable
    public init(diagonal: Diagonal) { wrapped = .init(diagonal: diagonal) }

    @inlinable
    public init(_ columns: [Column]) { wrapped = .init(columns) }

    @inlinable
    public init(rows: [Row]) { wrapped = .init(rows: rows) }

    @inlinable
    public init(_ col0: Column, _ col1: Column, _ col2: Column) { wrapped = .init(col0, col1, col2) }

    @inlinable
    public init(columns: (Column, Column, Column)) { wrapped = .init(columns: columns) }


    // MARK: Subscripts

    public subscript(column: Int) -> Column {
        @inlinable
        get { wrapped[column] }
        @inlinable
        set { wrapped[column] = newValue }
    }

    public subscript(column: Int, row: Int) -> Scalar {
        @inlinable
        get { wrapped[column, row] }
        @inlinable
        set { wrapped[column, row] = newValue }
    }


    // MARK: Operators

    @inlinable
    public static func * <RHS>(lhs: Self, rhs: RHS) -> Column
    where RHS : KvSimd3F, RHS.Scalar == Scalar, RHS.SimdView == Row.SimdView
    {
        lhs.wrapped * Row(simdView: rhs.simdView)
    }


    @inlinable
    public static func * <LHS>(lhs: LHS, rhs: Self) -> Row
    where LHS : KvSimd2F, LHS.Scalar == Scalar, LHS.SimdView == Column.SimdView
    {
        Column(simdView: lhs.simdView) * rhs.wrapped
    }

}



// MARK: - KvSimdAny3x3

/// Lightweight wrapper for standard SIMD 3×3 matrix types.
public struct KvSimdAny3x3<Scalar> : KvSimd3x3, KvSimdAnySquareMatrix
where Scalar : KvSimdMatrixScalar
{

    public typealias Scalar = Scalar

    public typealias Row = Wrapped.Row
    public typealias Column = Wrapped.Column
    public typealias Diagonal = Wrapped.Diagonal

    public typealias Transpose = Self

    public typealias Wrapped = Scalar.Matrix3x3


    public var columns: (Column, Column, Column) {
        @inlinable
        get { wrapped.columns }
        @inlinable
        set { wrapped.columns = newValue }
    }

    @inlinable
    public var transpose: Transpose { .init(wrapped.transpose) }

    @inlinable
    public var determinant: Scalar { wrapped.determinant }

    @inlinable
    public var inverse: Self { .init(wrapped.inverse) }


    public var wrapped: Wrapped


    @inlinable
    public init() { wrapped = .init() }

    @inlinable
    public init(_ wrapped: Wrapped) {
        self.wrapped = wrapped
    }

    @inlinable
    public init(_ scalar: Scalar) { wrapped = .init(scalar) }

    @inlinable
    public init(diagonal: Diagonal) { wrapped = .init(diagonal: diagonal) }

    @inlinable
    public init(_ columns: [Column]) { wrapped = .init(columns) }

    @inlinable
    public init(rows: [Row]) { wrapped = .init(rows: rows) }

    @inlinable
    public init(_ col0: Column, _ col1: Column, _ col2: Column) { wrapped = .init(col0, col1, col2) }

    @inlinable
    public init(columns: (Column, Column, Column)) { wrapped = .init(columns: columns) }


    // MARK: Subscripts

    public subscript(column: Int) -> Column {
        @inlinable
        get { wrapped[column] }
        @inlinable
        set { wrapped[column] = newValue }
    }

    public subscript(column: Int, row: Int) -> Scalar {
        @inlinable
        get { wrapped[column, row] }
        @inlinable
        set { wrapped[column, row] = newValue }
    }


    // MARK: Operators

    @inlinable
    public static func * <RHS>(lhs: Self, rhs: RHS) -> Column
    where RHS : KvSimd3F, RHS.Scalar == Scalar, RHS.SimdView == Row.SimdView
    {
        lhs.wrapped * Row(simdView: rhs.simdView)
    }


    @inlinable
    public static func * <LHS>(lhs: LHS, rhs: Self) -> Row
    where LHS : KvSimd3F, LHS.Scalar == Scalar, LHS.SimdView == Column.SimdView
    {
        Column(simdView: lhs.simdView) * rhs.wrapped
    }

}



// MARK: - KvSimdAny3x4

/// Lightweight wrapper for standard SIMD 3×4 matrix types.
public struct KvSimdAny3x4<Scalar> : KvSimd3x4, KvSimdAnyMatrix
where Scalar : KvSimdMatrixScalar
{

    public typealias Scalar = Scalar

    public typealias Row = Wrapped.Row
    public typealias Column = Wrapped.Column
    public typealias Diagonal = Wrapped.Diagonal

    public typealias Transpose = KvSimdAny4x3<Scalar>

    public typealias Wrapped = Scalar.Matrix3x4


    public var columns: (Column, Column, Column) {
        @inlinable
        get { wrapped.columns }
        @inlinable
        set { wrapped.columns = newValue }
    }

    @inlinable
    public var transpose: Transpose { .init(wrapped.transpose) }


    public var wrapped: Wrapped


    @inlinable
    public init() { wrapped = .init() }

    @inlinable
    public init(_ wrapped: Wrapped) {
        self.wrapped = wrapped
    }

    @inlinable
    public init(_ scalar: Scalar) { wrapped = .init(scalar) }

    @inlinable
    public init(diagonal: Diagonal) { wrapped = .init(diagonal: diagonal) }

    @inlinable
    public init(_ columns: [Column]) { wrapped = .init(columns) }

    @inlinable
    public init(rows: [Row]) { wrapped = .init(rows: rows) }

    @inlinable
    public init(_ col0: Column, _ col1: Column, _ col2: Column) { wrapped = .init(col0, col1, col2) }

    @inlinable
    public init(columns: (Column, Column, Column)) { wrapped = .init(columns: columns) }


    // MARK: Subscripts

    public subscript(column: Int) -> Column {
        @inlinable
        get { wrapped[column] }
        @inlinable
        set { wrapped[column] = newValue }
    }

    public subscript(column: Int, row: Int) -> Scalar {
        @inlinable
        get { wrapped[column, row] }
        @inlinable
        set { wrapped[column, row] = newValue }
    }


    // MARK: Operators

    @inlinable
    public static func * <RHS>(lhs: Self, rhs: RHS) -> Column
    where RHS : KvSimd3F, RHS.Scalar == Scalar, RHS.SimdView == Row.SimdView
    {
        lhs.wrapped * Row(simdView: rhs.simdView)
    }


    @inlinable
    public static func * <LHS>(lhs: LHS, rhs: Self) -> Row
    where LHS : KvSimd4F, LHS.Scalar == Scalar, LHS.SimdView == Column.SimdView
    {
        Column(simdView: lhs.simdView) * rhs.wrapped
    }

}



// MARK: - KvSimdAny4x2

/// Lightweight wrapper for standard SIMD 4×2 matrix types.
public struct KvSimdAny4x2<Scalar> : KvSimd4x2, KvSimdAnyMatrix
where Scalar : KvSimdMatrixScalar
{

    public typealias Scalar = Scalar

    public typealias Row = Wrapped.Row
    public typealias Column = Wrapped.Column
    public typealias Diagonal = Wrapped.Diagonal

    public typealias Transpose = KvSimdAny2x4<Scalar>

    public typealias Wrapped = Scalar.Matrix4x2


    public var columns: (Column, Column, Column, Column) {
        @inlinable
        get { wrapped.columns }
        @inlinable
        set { wrapped.columns = newValue }
    }

    @inlinable
    public var transpose: Transpose { .init(wrapped.transpose) }


    public var wrapped: Wrapped


    @inlinable
    public init() { wrapped = .init() }

    @inlinable
    public init(_ wrapped: Wrapped) {
        self.wrapped = wrapped
    }

    @inlinable
    public init(_ scalar: Scalar) { wrapped = .init(scalar) }

    @inlinable
    public init(diagonal: Diagonal) { wrapped = .init(diagonal: diagonal) }

    @inlinable
    public init(_ columns: [Column]) { wrapped = .init(columns) }

    @inlinable
    public init(rows: [Row]) { wrapped = .init(rows: rows) }

    @inlinable
    public init(_ col0: Column, _ col1: Column, _ col2: Column, _ col3: Column) { wrapped = .init(col0, col1, col2, col3) }

    @inlinable
    public init(columns: (Column, Column, Column, Column)) { wrapped = .init(columns: columns) }


    // MARK: Subscripts

    public subscript(column: Int) -> Column {
        @inlinable
        get { wrapped[column] }
        @inlinable
        set { wrapped[column] = newValue }
    }

    public subscript(column: Int, row: Int) -> Scalar {
        @inlinable
        get { wrapped[column, row] }
        @inlinable
        set { wrapped[column, row] = newValue }
    }


    // MARK: Operators

    @inlinable
    public static func * <RHS>(lhs: Self, rhs: RHS) -> Column
    where RHS : KvSimd4F, RHS.Scalar == Scalar, RHS.SimdView == Row.SimdView
    {
        lhs.wrapped * Row(simdView: rhs.simdView)
    }


    @inlinable
    public static func * <LHS>(lhs: LHS, rhs: Self) -> Row
    where LHS : KvSimd2F, LHS.Scalar == Scalar, LHS.SimdView == Column.SimdView
    {
        Column(simdView: lhs.simdView) * rhs.wrapped
    }

}



// MARK: - KvSimdAny4x3

/// Lightweight wrapper for standard SIMD 4×3 matrix types.
public struct KvSimdAny4x3<Scalar> : KvSimd4x3, KvSimdAnyMatrix
where Scalar : KvSimdMatrixScalar
{

    public typealias Scalar = Scalar

    public typealias Row = Wrapped.Row
    public typealias Column = Wrapped.Column
    public typealias Diagonal = Wrapped.Diagonal

    public typealias Transpose = KvSimdAny3x4<Scalar>

    public typealias Wrapped = Scalar.Matrix4x3


    public var columns: (Column, Column, Column, Column) {
        @inlinable
        get { wrapped.columns }
        @inlinable
        set { wrapped.columns = newValue }
    }

    @inlinable
    public var transpose: Transpose { .init(wrapped.transpose) }


    public var wrapped: Wrapped


    @inlinable
    public init() { wrapped = .init() }

    @inlinable
    public init(_ wrapped: Wrapped) {
        self.wrapped = wrapped
    }

    @inlinable
    public init(_ scalar: Scalar) { wrapped = .init(scalar) }

    @inlinable
    public init(diagonal: Diagonal) { wrapped = .init(diagonal: diagonal) }

    @inlinable
    public init(_ columns: [Column]) { wrapped = .init(columns) }

    @inlinable
    public init(rows: [Row]) { wrapped = .init(rows: rows) }

    @inlinable
    public init(_ col0: Column, _ col1: Column, _ col2: Column, _ col3: Column) { wrapped = .init(col0, col1, col2, col3) }

    @inlinable
    public init(columns: (Column, Column, Column, Column)) { wrapped = .init(columns: columns) }


    // MARK: Subscripts

    public subscript(column: Int) -> Column {
        @inlinable
        get { wrapped[column] }
        @inlinable
        set { wrapped[column] = newValue }
    }

    public subscript(column: Int, row: Int) -> Scalar {
        @inlinable
        get { wrapped[column, row] }
        @inlinable
        set { wrapped[column, row] = newValue }
    }


    // MARK: Operators

    @inlinable
    public static func * <RHS>(lhs: Self, rhs: RHS) -> Column
    where RHS : KvSimd4F, RHS.Scalar == Scalar, RHS.SimdView == Row.SimdView
    {
        lhs.wrapped * Row(simdView: rhs.simdView)
    }


    @inlinable
    public static func * <LHS>(lhs: LHS, rhs: Self) -> Row
    where LHS : KvSimd3F, LHS.Scalar == Scalar, LHS.SimdView == Column.SimdView
    {
        Column(simdView: lhs.simdView) * rhs.wrapped
    }

}



// MARK: - KvSimdAny4x4

/// Lightweight wrapper for standard SIMD 4×4 matrix types.
public struct KvSimdAny4x4<Scalar> : KvSimd4x4, KvSimdAnySquareMatrix
where Scalar : KvSimdMatrixScalar
{

    public typealias Scalar = Scalar

    public typealias Row = Wrapped.Row
    public typealias Column = Wrapped.Column
    public typealias Diagonal = Wrapped.Diagonal

    public typealias Transpose = Self

    public typealias Wrapped = Scalar.Matrix4x4


    public var columns: (Column, Column, Column, Column) {
        @inlinable
        get { wrapped.columns }
        @inlinable
        set { wrapped.columns = newValue }
    }

    @inlinable
    public var transpose: Transpose { .init(wrapped.transpose) }

    @inlinable
    public var determinant: Scalar { wrapped.determinant }

    @inlinable
    public var inverse: Self { .init(wrapped.inverse) }


    public var wrapped: Wrapped


    @inlinable
    public init() { wrapped = .init() }

    @inlinable
    public init(_ wrapped: Wrapped) {
        self.wrapped = wrapped
    }

    @inlinable
    public init(_ scalar: Scalar) { wrapped = .init(scalar) }

    @inlinable
    public init(diagonal: Diagonal) { wrapped = .init(diagonal: diagonal) }

    @inlinable
    public init(_ columns: [Column]) { wrapped = .init(columns) }

    @inlinable
    public init(rows: [Row]) { wrapped = .init(rows: rows) }

    @inlinable
    public init(_ col0: Column, _ col1: Column, _ col2: Column, _ col3: Column) { wrapped = .init(col0, col1, col2, col3) }

    @inlinable
    public init(columns: (Column, Column, Column, Column)) { wrapped = .init(columns: columns) }


    // MARK: Subscripts

    public subscript(column: Int) -> Column {
        @inlinable
        get { wrapped[column] }
        @inlinable
        set { wrapped[column] = newValue }
    }

    public subscript(column: Int, row: Int) -> Scalar {
        @inlinable
        get { wrapped[column, row] }
        @inlinable
        set { wrapped[column, row] = newValue }
    }


    // MARK: Operators

    @inlinable
    public static func * <RHS>(lhs: Self, rhs: RHS) -> Column
    where RHS : KvSimd4F, RHS.Scalar == Scalar, RHS.SimdView == Row.SimdView
    {
        lhs.wrapped * Row(simdView: rhs.simdView)
    }


    @inlinable
    public static func * <LHS>(lhs: LHS, rhs: Self) -> Row
    where LHS : KvSimd4F, LHS.Scalar == Scalar, LHS.SimdView == Column.SimdView
    {
        Column(simdView: lhs.simdView) * rhs.wrapped
    }

}



// MARK: - simd_float2x2

extension simd_float2x2 : KvSimd2x2 {

    public typealias Scalar = Float

    public typealias Row = SIMD2<Scalar>
    public typealias Column = SIMD2<Scalar>
    public typealias Diagonal = SIMD2<Scalar>

}


// MARK: - simd_double2x2

extension simd_double2x2 : KvSimd2x2 {

    public typealias Scalar = Double

    public typealias Row = SIMD2<Scalar>
    public typealias Column = SIMD2<Scalar>
    public typealias Diagonal = SIMD2<Scalar>

}


// MARK: - simd_float2x3

extension simd_float2x3 : KvSimd2x3 {

    public typealias Scalar = Float

    public typealias Row = SIMD2<Scalar>
    public typealias Column = SIMD3<Scalar>
    public typealias Diagonal = SIMD2<Scalar>

}


// MARK: - simd_double2x3

extension simd_double2x3 : KvSimd2x3 {

    public typealias Scalar = Double

    public typealias Row = SIMD2<Scalar>
    public typealias Column = SIMD3<Scalar>
    public typealias Diagonal = SIMD2<Scalar>

}


// MARK: - simd_float2x4

extension simd_float2x4 : KvSimd2x4 {

    public typealias Scalar = Float

    public typealias Row = SIMD2<Scalar>
    public typealias Column = SIMD4<Scalar>
    public typealias Diagonal = SIMD2<Scalar>

}


// MARK: - simd_double2x4

extension simd_double2x4 : KvSimd2x4 {

    public typealias Scalar = Double

    public typealias Row = SIMD2<Scalar>
    public typealias Column = SIMD4<Scalar>
    public typealias Diagonal = SIMD2<Scalar>

}


// MARK: - simd_float3x2

extension simd_float3x2 : KvSimd3x2 {

    public typealias Scalar = Float

    public typealias Row = SIMD3<Scalar>
    public typealias Column = SIMD2<Scalar>
    public typealias Diagonal = SIMD2<Scalar>

}


// MARK: - simd_double3x2

extension simd_double3x2 : KvSimd3x2 {

    public typealias Scalar = Double

    public typealias Row = SIMD3<Scalar>
    public typealias Column = SIMD2<Scalar>
    public typealias Diagonal = SIMD2<Scalar>

}


// MARK: - simd_float3x3

extension simd_float3x3 : KvSimd3x3 {

    public typealias Scalar = Float

    public typealias Row = SIMD3<Scalar>
    public typealias Column = SIMD3<Scalar>
    public typealias Diagonal = SIMD3<Scalar>

    public typealias Quaternion = simd_quatf

}


// MARK: - simd_double3x3

extension simd_double3x3 : KvSimd3x3 {

    public typealias Scalar = Double

    public typealias Row = SIMD3<Scalar>
    public typealias Column = SIMD3<Scalar>
    public typealias Diagonal = SIMD3<Scalar>

    public typealias Quaternion = simd_quatd

}


// MARK: - simd_float3x4

extension simd_float3x4 : KvSimd3x4 {

    public typealias Scalar = Float

    public typealias Row = SIMD3<Scalar>
    public typealias Column = SIMD4<Scalar>
    public typealias Diagonal = SIMD3<Scalar>

}


// MARK: - simd_double3x4

extension simd_double3x4 : KvSimd3x4 {

    public typealias Scalar = Double

    public typealias Row = SIMD3<Scalar>
    public typealias Column = SIMD4<Scalar>
    public typealias Diagonal = SIMD3<Scalar>

}


// MARK: - simd_float4x2

extension simd_float4x2 : KvSimd4x2 {

    public typealias Scalar = Float

    public typealias Row = SIMD4<Scalar>
    public typealias Column = SIMD2<Scalar>
    public typealias Diagonal = SIMD2<Scalar>

}


// MARK: - simd_double4x2

extension simd_double4x2 : KvSimd4x2 {

    public typealias Scalar = Double

    public typealias Row = SIMD4<Scalar>
    public typealias Column = SIMD2<Scalar>
    public typealias Diagonal = SIMD2<Scalar>

}


// MARK: - simd_float4x3

extension simd_float4x3 : KvSimd4x3 {

    public typealias Scalar = Float

    public typealias Row = SIMD4<Scalar>
    public typealias Column = SIMD3<Scalar>
    public typealias Diagonal = SIMD3<Scalar>

}


// MARK: - simd_double4x3

extension simd_double4x3 : KvSimd4x3 {

    public typealias Scalar = Double

    public typealias Row = SIMD4<Scalar>
    public typealias Column = SIMD3<Scalar>
    public typealias Diagonal = SIMD3<Scalar>

}


// MARK: - simd_float4x4

extension simd_float4x4 : KvSimd4x4 {

    public typealias Scalar = Float

    public typealias Row = SIMD4<Scalar>
    public typealias Column = SIMD4<Scalar>
    public typealias Diagonal = SIMD4<Scalar>

    public typealias Quaternion = simd_quatf

}


// MARK: - simd_double4x4

extension simd_double4x4 : KvSimd4x4 {

    public typealias Scalar = Double

    public typealias Row = SIMD4<Scalar>
    public typealias Column = SIMD4<Scalar>
    public typealias Diagonal = SIMD4<Scalar>

    public typealias Quaternion = simd_quatd

}
