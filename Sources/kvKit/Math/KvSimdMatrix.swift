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

    associatedtype Matrix2x2 : KvSimdMatrix2xN, KvSimdMatrixNx2, KvSimdSquareMatrix
    where Matrix2x2.Scalar == Self, Matrix2x2.Transpose == Matrix2x2,
          Matrix2x2.Row : KvSimdVector2F, Matrix2x2.Column : KvSimdVector2F, Matrix2x2.Diagonal : KvSimdVector2F

    associatedtype Matrix2x3 : KvSimdMatrix2xN, KvSimdMatrixNx3
    where Matrix2x3.Scalar == Self, Matrix2x3.Transpose == Matrix3x2,
          Matrix2x3.Row : KvSimdVector2F, Matrix2x3.Column : KvSimdVector3F, Matrix3x2.Diagonal : KvSimdVector2F

    associatedtype Matrix2x4 : KvSimdMatrix2xN, KvSimdMatrixNx4
    where Matrix2x4.Scalar == Self, Matrix2x4.Transpose == Matrix4x2,
          Matrix2x4.Row : KvSimdVector2F, Matrix2x4.Column : KvSimdVector4F, Matrix4x2.Diagonal : KvSimdVector2F

    associatedtype Matrix3x2 : KvSimdMatrix3xN, KvSimdMatrixNx2
    where Matrix3x2.Scalar == Self, Matrix3x2.Transpose == Matrix2x3,
          Matrix3x2.Row : KvSimdVector3F, Matrix3x2.Column : KvSimdVector2F, Matrix3x2.Diagonal : KvSimdVector2F

    associatedtype Matrix3x3 : KvSimdMatrix3xN, KvSimdMatrixNx3, KvSimdSquareMatrix
    where Matrix3x3.Scalar == Self, Matrix3x3.Transpose == Matrix3x3,
          Matrix3x3.Row : KvSimdVector3F, Matrix3x3.Column : KvSimdVector3F, Matrix3x3.Diagonal : KvSimdVector3F

    associatedtype Matrix3x4 : KvSimdMatrix3xN, KvSimdMatrixNx4
    where Matrix3x4.Scalar == Self, Matrix3x4.Transpose == Matrix4x3,
          Matrix3x4.Row : KvSimdVector3F, Matrix3x4.Column : KvSimdVector4F, Matrix3x4.Diagonal : KvSimdVector3F

    associatedtype Matrix4x2 : KvSimdMatrix4xN, KvSimdMatrixNx2
    where Matrix4x2.Scalar == Self, Matrix4x2.Transpose == Matrix2x4,
          Matrix4x2.Row : KvSimdVector4F, Matrix4x2.Column : KvSimdVector2F, Matrix4x2.Diagonal : KvSimdVector2F

    associatedtype Matrix4x3 : KvSimdMatrix4xN, KvSimdMatrixNx3
    where Matrix4x3.Scalar == Self, Matrix4x3.Transpose == Matrix3x4,
          Matrix4x3.Row : KvSimdVector4F, Matrix4x3.Column : KvSimdVector3F, Matrix4x3.Diagonal : KvSimdVector3F

    associatedtype Matrix4x4 : KvSimdMatrix4xN, KvSimdMatrixNx4, KvSimdSquareMatrix
    where Matrix4x4.Scalar == Self, Matrix4x4.Transpose == Matrix4x4,
          Matrix4x4.Row : KvSimdVector4F, Matrix4x4.Column : KvSimdVector4F, Matrix4x4.Diagonal : KvSimdVector4F

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



// MARK: - KvSimdMatrix2xN

/// Common protocol for standard SIMD 2×N matrix types.
public protocol KvSimdMatrix2xN : KvSimdMatrix
where Row : KvSimdVector2F
{

    var columns: (Column, Column) { get set }


    // MARK: Initialization

    init(_ col0: Column, _ col1: Column)

    init(columns: (Column, Column))

}



// MARK: - KvSimdMatrixNx2

/// Common protocol for standard SIMD N×2 matrix types.
public protocol KvSimdMatrixNx2 : KvSimdMatrix
where Column : KvSimdVector2F
{ }



// MARK: - KvSimdMatrix3xN

/// Common protocol for standard SIMD 3×N matrix types.
public protocol KvSimdMatrix3xN : KvSimdMatrix
where Row : KvSimdVector3F
{

    var columns: (Column, Column, Column) { get set }


    // MARK: Initialization

    init(_ col0: Column, _ col1: Column, _ col2: Column)

    init(columns: (Column, Column, Column))

}



// MARK: - KvSimdMatrixNx3

/// Common protocol for standard SIMD N×3 matrix types.
public protocol KvSimdMatrixNx3 : KvSimdMatrix
where Column : KvSimdVector3F
{ }



// MARK: - KvSimdMatrix4xN

/// Common protocol for standard SIMD 4×N matrix types.
public protocol KvSimdMatrix4xN : KvSimdMatrix
where Row : KvSimdVector4F
{

    var columns: (Column, Column, Column, Column) { get set }


    // MARK: Initialization

    init(_ col0: Column, _ col1: Column, _ col2: Column, _ col3: Column)

    init(columns: (Column, Column, Column, Column))

}



// MARK: - KvSimdMatrixNx4

/// Common protocol for standard SIMD N×4 matrix types.
public protocol KvSimdMatrixNx4 : KvSimdMatrix
where Column : KvSimdVector4F
{ }



// MARK: - KvSimdMatrixWrapper

public protocol KvSimdMatrixWrapper : Equatable {

    associatedtype Scalar : KvSimdMatrixScalar

    associatedtype Wrapped : KvSimdMatrix where Wrapped.Scalar == Scalar


    var wrapped: Wrapped { get set }


    init(wrapping wrapped: Wrapped)

}


extension KvSimdMatrixWrapper {

    @inlinable
    public prefix static func -(rhs: Self) -> Self { .init(wrapping: -rhs.wrapped) }


    @inlinable
    public static func +(lhs: Self, rhs: Self) -> Self { .init(wrapping: lhs.wrapped + rhs.wrapped) }

    @inlinable
    public static func +(lhs: Wrapped, rhs: Self) -> Wrapped { lhs + rhs.wrapped }

    @inlinable
    public static func +(lhs: Self, rhs: Wrapped) -> Wrapped { lhs.wrapped + rhs }


    @inlinable
    public static func -(lhs: Self, rhs: Self) -> Self { .init(wrapping: lhs.wrapped - rhs.wrapped) }

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
    public static func *(lhs: Scalar, rhs: Self) -> Self { .init(wrapping: lhs * rhs.wrapped) }


    @inlinable
    public static func *(lhs: Self, rhs: Scalar) -> Self { .init(wrapping: lhs.wrapped * rhs) }


    @inlinable
    public static func *=(lhs: inout Self, rhs: Scalar) { lhs.wrapped *= rhs }


    @inlinable
    public static func *(lhs: Self, rhs: Wrapped.Row) -> Wrapped.Column { lhs.wrapped * rhs }


    @inlinable
    public static func *(lhs: Wrapped.Column, rhs: Self) -> Wrapped.Row { lhs * rhs.wrapped }

}



// MARK: - KvSimdSquareMatrixWrapper

public protocol KvSimdSquareMatrixWrapper : KvSimdMatrixWrapper
where Wrapped : KvSimdSquareMatrix
{ }


extension KvSimdSquareMatrixWrapper {

    @inlinable
    public static func *(lhs: Self, rhs: Self) -> Self { .init(wrapping: lhs.wrapped * rhs.wrapped) }

    @inlinable
    public static func *(lhs: Wrapped, rhs: Self) -> Wrapped { lhs * rhs.wrapped }

    @inlinable
    public static func *(lhs: Self, rhs: Wrapped) -> Wrapped { lhs.wrapped * rhs }


    @inlinable
    public static func *=(lhs: inout Self, rhs: Self) { lhs.wrapped *= rhs.wrapped }

    @inlinable
    public static func *=(lhs: inout Self, rhs: Wrapped) { lhs.wrapped *= rhs }

}



// MARK: - KvSimdMatrix2x2

/// Lightweight wrapper for standard SIMD 2×2 matrix types.
public struct KvSimdMatrix2x2<Scalar> : KvSimdMatrix2xN, KvSimdMatrixNx2, KvSimdSquareMatrix, KvSimdSquareMatrixWrapper
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
    public var transpose: Transpose { .init(wrapping: wrapped.transpose) }

    @inlinable
    public var determinant: Scalar { wrapped.determinant }

    @inlinable
    public var inverse: Self { .init(wrapping: wrapped.inverse) }


    public var wrapped: Wrapped


    @inlinable
    public init() { wrapped = .init() }

    @inlinable
    public init(wrapping wrapped: Wrapped) {
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
    where RHS : KvSimdVector2F, RHS.Scalar == Scalar, RHS.SimdView == Row.SimdView
    {
        lhs.wrapped * Row(simdView: rhs.simdView)
    }


    @inlinable
    public static func * <LHS>(lhs: LHS, rhs: Self) -> Row
    where LHS : KvSimdVector2F, LHS.Scalar == Scalar, LHS.SimdView == Column.SimdView
    {
        Column(simdView: lhs.simdView) * rhs.wrapped
    }

}



// MARK: - KvSimdMatrix2x3

/// Lightweight wrapper for standard SIMD 2×3 matrix types.
public struct KvSimdMatrix2x3<Scalar> : KvSimdMatrix2xN, KvSimdMatrixNx3, KvSimdMatrixWrapper
where Scalar : KvSimdMatrixScalar
{

    public typealias Scalar = Scalar

    public typealias Row = Wrapped.Row
    public typealias Column = Wrapped.Column
    public typealias Diagonal = Wrapped.Diagonal

    public typealias Transpose = KvSimdMatrix3x2<Scalar>

    public typealias Wrapped = Scalar.Matrix2x3


    public var columns: (Column, Column) {
        @inlinable
        get { wrapped.columns }
        @inlinable
        set { wrapped.columns = newValue }
    }

    @inlinable
    public var transpose: Transpose { .init(wrapping: wrapped.transpose) }


    public var wrapped: Wrapped


    @inlinable
    public init() { wrapped = .init() }

    @inlinable
    public init(wrapping wrapped: Wrapped) {
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
    where RHS : KvSimdVector2F, RHS.Scalar == Scalar, RHS.SimdView == Row.SimdView
    {
        lhs.wrapped * Row(simdView: rhs.simdView)
    }


    @inlinable
    public static func * <LHS>(lhs: LHS, rhs: Self) -> Row
    where LHS : KvSimdVector3F, LHS.Scalar == Scalar, LHS.SimdView == Column.SimdView
    {
        Column(simdView: lhs.simdView) * rhs.wrapped
    }

}



// MARK: - KvSimdMatrix2x4

/// Lightweight wrapper for standard SIMD 2×4 matrix types.
public struct KvSimdMatrix2x4<Scalar> : KvSimdMatrix2xN, KvSimdMatrixNx4, KvSimdMatrixWrapper
where Scalar : KvSimdMatrixScalar
{

    public typealias Scalar = Scalar

    public typealias Row = Wrapped.Row
    public typealias Column = Wrapped.Column
    public typealias Diagonal = Wrapped.Diagonal

    public typealias Transpose = KvSimdMatrix4x2<Scalar>

    public typealias Wrapped = Scalar.Matrix2x4


    public var columns: (Column, Column) {
        @inlinable
        get { wrapped.columns }
        @inlinable
        set { wrapped.columns = newValue }
    }

    @inlinable
    public var transpose: Transpose { .init(wrapping: wrapped.transpose) }


    public var wrapped: Wrapped


    @inlinable
    public init() { wrapped = .init() }

    @inlinable
    public init(wrapping wrapped: Wrapped) {
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
    where RHS : KvSimdVector2F, RHS.Scalar == Scalar, RHS.SimdView == Row.SimdView
    {
        lhs.wrapped * Row(simdView: rhs.simdView)
    }


    @inlinable
    public static func * <LHS>(lhs: LHS, rhs: Self) -> Row
    where LHS : KvSimdVector4F, LHS.Scalar == Scalar, LHS.SimdView == Column.SimdView
    {
        Column(simdView: lhs.simdView) * rhs.wrapped
    }

}



// MARK: - KvSimdMatrix3x2

/// Lightweight wrapper for standard SIMD 3×2 matrix types.
public struct KvSimdMatrix3x2<Scalar> : KvSimdMatrix3xN, KvSimdMatrixNx2, KvSimdMatrixWrapper
where Scalar : KvSimdMatrixScalar
{

    public typealias Scalar = Scalar

    public typealias Row = Wrapped.Row
    public typealias Column = Wrapped.Column
    public typealias Diagonal = Wrapped.Diagonal

    public typealias Transpose = KvSimdMatrix2x3<Scalar>

    public typealias Wrapped = Scalar.Matrix3x2


    public var columns: (Column, Column, Column) {
        @inlinable
        get { wrapped.columns }
        @inlinable
        set { wrapped.columns = newValue }
    }

    @inlinable
    public var transpose: Transpose { .init(wrapping: wrapped.transpose) }


    public var wrapped: Wrapped


    @inlinable
    public init() { wrapped = .init() }

    @inlinable
    public init(wrapping wrapped: Wrapped) {
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
    where RHS : KvSimdVector3F, RHS.Scalar == Scalar, RHS.SimdView == Row.SimdView
    {
        lhs.wrapped * Row(simdView: rhs.simdView)
    }


    @inlinable
    public static func * <LHS>(lhs: LHS, rhs: Self) -> Row
    where LHS : KvSimdVector2F, LHS.Scalar == Scalar, LHS.SimdView == Column.SimdView
    {
        Column(simdView: lhs.simdView) * rhs.wrapped
    }

}



// MARK: - KvSimdMatrix3x3

/// Lightweight wrapper for standard SIMD 3×3 matrix types.
public struct KvSimdMatrix3x3<Scalar> : KvSimdMatrix3xN, KvSimdMatrixNx3, KvSimdSquareMatrix, KvSimdSquareMatrixWrapper
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
    public var transpose: Transpose { .init(wrapping: wrapped.transpose) }

    @inlinable
    public var determinant: Scalar { wrapped.determinant }

    @inlinable
    public var inverse: Self { .init(wrapping: wrapped.inverse) }


    public var wrapped: Wrapped


    @inlinable
    public init() { wrapped = .init() }

    @inlinable
    public init(wrapping wrapped: Wrapped) {
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
    where RHS : KvSimdVector3F, RHS.Scalar == Scalar, RHS.SimdView == Row.SimdView
    {
        lhs.wrapped * Row(simdView: rhs.simdView)
    }


    @inlinable
    public static func * <LHS>(lhs: LHS, rhs: Self) -> Row
    where LHS : KvSimdVector3F, LHS.Scalar == Scalar, LHS.SimdView == Column.SimdView
    {
        Column(simdView: lhs.simdView) * rhs.wrapped
    }

}



// MARK: - KvSimdMatrix3x4

/// Lightweight wrapper for standard SIMD 3×4 matrix types.
public struct KvSimdMatrix3x4<Scalar> : KvSimdMatrix3xN, KvSimdMatrixNx4, KvSimdMatrixWrapper
where Scalar : KvSimdMatrixScalar
{

    public typealias Scalar = Scalar

    public typealias Row = Wrapped.Row
    public typealias Column = Wrapped.Column
    public typealias Diagonal = Wrapped.Diagonal

    public typealias Transpose = KvSimdMatrix4x3<Scalar>

    public typealias Wrapped = Scalar.Matrix3x4


    public var columns: (Column, Column, Column) {
        @inlinable
        get { wrapped.columns }
        @inlinable
        set { wrapped.columns = newValue }
    }

    @inlinable
    public var transpose: Transpose { .init(wrapping: wrapped.transpose) }


    public var wrapped: Wrapped


    @inlinable
    public init() { wrapped = .init() }

    @inlinable
    public init(wrapping wrapped: Wrapped) {
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
    where RHS : KvSimdVector3F, RHS.Scalar == Scalar, RHS.SimdView == Row.SimdView
    {
        lhs.wrapped * Row(simdView: rhs.simdView)
    }


    @inlinable
    public static func * <LHS>(lhs: LHS, rhs: Self) -> Row
    where LHS : KvSimdVector4F, LHS.Scalar == Scalar, LHS.SimdView == Column.SimdView
    {
        Column(simdView: lhs.simdView) * rhs.wrapped
    }

}



// MARK: - KvSimdMatrix4x2

/// Lightweight wrapper for standard SIMD 4×2 matrix types.
public struct KvSimdMatrix4x2<Scalar> : KvSimdMatrix4xN, KvSimdMatrixNx2, KvSimdMatrixWrapper
where Scalar : KvSimdMatrixScalar
{

    public typealias Scalar = Scalar

    public typealias Row = Wrapped.Row
    public typealias Column = Wrapped.Column
    public typealias Diagonal = Wrapped.Diagonal

    public typealias Transpose = KvSimdMatrix2x4<Scalar>

    public typealias Wrapped = Scalar.Matrix4x2


    public var columns: (Column, Column, Column, Column) {
        @inlinable
        get { wrapped.columns }
        @inlinable
        set { wrapped.columns = newValue }
    }

    @inlinable
    public var transpose: Transpose { .init(wrapping: wrapped.transpose) }


    public var wrapped: Wrapped


    @inlinable
    public init() { wrapped = .init() }

    @inlinable
    public init(wrapping wrapped: Wrapped) {
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
    where RHS : KvSimdVector4F, RHS.Scalar == Scalar, RHS.SimdView == Row.SimdView
    {
        lhs.wrapped * Row(simdView: rhs.simdView)
    }


    @inlinable
    public static func * <LHS>(lhs: LHS, rhs: Self) -> Row
    where LHS : KvSimdVector2F, LHS.Scalar == Scalar, LHS.SimdView == Column.SimdView
    {
        Column(simdView: lhs.simdView) * rhs.wrapped
    }

}



// MARK: - KvSimdMatrix4x3

/// Lightweight wrapper for standard SIMD 4×3 matrix types.
public struct KvSimdMatrix4x3<Scalar> : KvSimdMatrix4xN, KvSimdMatrixNx3, KvSimdMatrixWrapper
where Scalar : KvSimdMatrixScalar
{

    public typealias Scalar = Scalar

    public typealias Row = Wrapped.Row
    public typealias Column = Wrapped.Column
    public typealias Diagonal = Wrapped.Diagonal

    public typealias Transpose = KvSimdMatrix3x4<Scalar>

    public typealias Wrapped = Scalar.Matrix4x3


    public var columns: (Column, Column, Column, Column) {
        @inlinable
        get { wrapped.columns }
        @inlinable
        set { wrapped.columns = newValue }
    }

    @inlinable
    public var transpose: Transpose { .init(wrapping: wrapped.transpose) }


    public var wrapped: Wrapped


    @inlinable
    public init() { wrapped = .init() }

    @inlinable
    public init(wrapping wrapped: Wrapped) {
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
    where RHS : KvSimdVector4F, RHS.Scalar == Scalar, RHS.SimdView == Row.SimdView
    {
        lhs.wrapped * Row(simdView: rhs.simdView)
    }


    @inlinable
    public static func * <LHS>(lhs: LHS, rhs: Self) -> Row
    where LHS : KvSimdVector3F, LHS.Scalar == Scalar, LHS.SimdView == Column.SimdView
    {
        Column(simdView: lhs.simdView) * rhs.wrapped
    }

}



// MARK: - KvSimdMatrix4x4

/// Lightweight wrapper for standard SIMD 4×4 matrix types.
public struct KvSimdMatrix4x4<Scalar> : KvSimdMatrix4xN, KvSimdMatrixNx4, KvSimdSquareMatrix, KvSimdSquareMatrixWrapper
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
    public var transpose: Transpose { .init(wrapping: wrapped.transpose) }

    @inlinable
    public var determinant: Scalar { wrapped.determinant }

    @inlinable
    public var inverse: Self { .init(wrapping: wrapped.inverse) }


    public var wrapped: Wrapped


    @inlinable
    public init() { wrapped = .init() }

    @inlinable
    public init(wrapping wrapped: Wrapped) {
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
    where RHS : KvSimdVector4F, RHS.Scalar == Scalar, RHS.SimdView == Row.SimdView
    {
        lhs.wrapped * Row(simdView: rhs.simdView)
    }


    @inlinable
    public static func * <LHS>(lhs: LHS, rhs: Self) -> Row
    where LHS : KvSimdVector4F, LHS.Scalar == Scalar, LHS.SimdView == Column.SimdView
    {
        Column(simdView: lhs.simdView) * rhs.wrapped
    }

}



// MARK: - simd_float2x2

extension simd_float2x2 : KvSimdMatrix2xN, KvSimdMatrixNx2, KvSimdSquareMatrix {

    public typealias Scalar = Float

    public typealias Row = SIMD2<Scalar>
    public typealias Column = SIMD2<Scalar>
    public typealias Diagonal = SIMD2<Scalar>

}


// MARK: - simd_double2x2

extension simd_double2x2 : KvSimdMatrix2xN, KvSimdMatrixNx2, KvSimdSquareMatrix {

    public typealias Scalar = Double

    public typealias Row = SIMD2<Scalar>
    public typealias Column = SIMD2<Scalar>
    public typealias Diagonal = SIMD2<Scalar>

}


// MARK: - simd_float2x3

extension simd_float2x3 : KvSimdMatrix2xN, KvSimdMatrixNx3 {

    public typealias Scalar = Float

    public typealias Row = SIMD2<Scalar>
    public typealias Column = SIMD3<Scalar>
    public typealias Diagonal = SIMD2<Scalar>

}


// MARK: - simd_double2x3

extension simd_double2x3 : KvSimdMatrix2xN, KvSimdMatrixNx3 {

    public typealias Scalar = Double

    public typealias Row = SIMD2<Scalar>
    public typealias Column = SIMD3<Scalar>
    public typealias Diagonal = SIMD2<Scalar>

}


// MARK: - simd_float2x4

extension simd_float2x4 : KvSimdMatrix2xN, KvSimdMatrixNx4 {

    public typealias Scalar = Float

    public typealias Row = SIMD2<Scalar>
    public typealias Column = SIMD4<Scalar>
    public typealias Diagonal = SIMD2<Scalar>

}


// MARK: - simd_double2x4

extension simd_double2x4 : KvSimdMatrix2xN, KvSimdMatrixNx4 {

    public typealias Scalar = Double

    public typealias Row = SIMD2<Scalar>
    public typealias Column = SIMD4<Scalar>
    public typealias Diagonal = SIMD2<Scalar>

}


// MARK: - simd_float3x2

extension simd_float3x2 : KvSimdMatrix3xN, KvSimdMatrixNx2 {

    public typealias Scalar = Float

    public typealias Row = SIMD3<Scalar>
    public typealias Column = SIMD2<Scalar>
    public typealias Diagonal = SIMD2<Scalar>

}


// MARK: - simd_double3x2

extension simd_double3x2 : KvSimdMatrix3xN, KvSimdMatrixNx2 {

    public typealias Scalar = Double

    public typealias Row = SIMD3<Scalar>
    public typealias Column = SIMD2<Scalar>
    public typealias Diagonal = SIMD2<Scalar>

}


// MARK: - simd_float3x3

extension simd_float3x3 : KvSimdMatrix3xN, KvSimdMatrixNx3, KvSimdSquareMatrix {

    public typealias Scalar = Float

    public typealias Row = SIMD3<Scalar>
    public typealias Column = SIMD3<Scalar>
    public typealias Diagonal = SIMD3<Scalar>

    public typealias Quaternion = simd_quatf

}


// MARK: - simd_double3x3

extension simd_double3x3 : KvSimdMatrix3xN, KvSimdMatrixNx3, KvSimdSquareMatrix {

    public typealias Scalar = Double

    public typealias Row = SIMD3<Scalar>
    public typealias Column = SIMD3<Scalar>
    public typealias Diagonal = SIMD3<Scalar>

    public typealias Quaternion = simd_quatd

}


// MARK: - simd_float3x4

extension simd_float3x4 : KvSimdMatrix3xN, KvSimdMatrixNx4 {

    public typealias Scalar = Float

    public typealias Row = SIMD3<Scalar>
    public typealias Column = SIMD4<Scalar>
    public typealias Diagonal = SIMD3<Scalar>

}


// MARK: - simd_double3x4

extension simd_double3x4 : KvSimdMatrix3xN, KvSimdMatrixNx4 {

    public typealias Scalar = Double

    public typealias Row = SIMD3<Scalar>
    public typealias Column = SIMD4<Scalar>
    public typealias Diagonal = SIMD3<Scalar>

}


// MARK: - simd_float4x2

extension simd_float4x2 : KvSimdMatrix4xN, KvSimdMatrixNx2 {

    public typealias Scalar = Float

    public typealias Row = SIMD4<Scalar>
    public typealias Column = SIMD2<Scalar>
    public typealias Diagonal = SIMD2<Scalar>

}


// MARK: - simd_double4x2

extension simd_double4x2 : KvSimdMatrix4xN, KvSimdMatrixNx2 {

    public typealias Scalar = Double

    public typealias Row = SIMD4<Scalar>
    public typealias Column = SIMD2<Scalar>
    public typealias Diagonal = SIMD2<Scalar>

}


// MARK: - simd_float4x3

extension simd_float4x3 : KvSimdMatrix4xN, KvSimdMatrixNx3 {

    public typealias Scalar = Float

    public typealias Row = SIMD4<Scalar>
    public typealias Column = SIMD3<Scalar>
    public typealias Diagonal = SIMD3<Scalar>

}


// MARK: - simd_double4x3

extension simd_double4x3 : KvSimdMatrix4xN, KvSimdMatrixNx3 {

    public typealias Scalar = Double

    public typealias Row = SIMD4<Scalar>
    public typealias Column = SIMD3<Scalar>
    public typealias Diagonal = SIMD3<Scalar>

}


// MARK: - simd_float4x4

extension simd_float4x4 : KvSimdMatrix4xN, KvSimdMatrixNx4, KvSimdSquareMatrix {

    public typealias Scalar = Float

    public typealias Row = SIMD4<Scalar>
    public typealias Column = SIMD4<Scalar>
    public typealias Diagonal = SIMD4<Scalar>

    public typealias Quaternion = simd_quatf

}


// MARK: - simd_double4x4

extension simd_double4x4 : KvSimdMatrix4xN, KvSimdMatrixNx4, KvSimdSquareMatrix {

    public typealias Scalar = Double

    public typealias Row = SIMD4<Scalar>
    public typealias Column = SIMD4<Scalar>
    public typealias Diagonal = SIMD4<Scalar>

    public typealias Quaternion = simd_quatd

}
