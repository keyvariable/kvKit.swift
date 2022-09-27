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
//  KvSimdVector.swift
//  kvKit
//
//  Created by Svyatoslav Popov on 14.09.2022.
//
//===----------------------------------------------------------------------===//
//
//  Collection of convinient protocols for SIMD vectors to provide generic constarints for dimmensions of SIMD vectors.
//

import simd



// MARK: - KvSimdVector

public protocol KvSimdVector : Hashable, CustomDebugStringConvertible {

    associatedtype Scalar : SIMDScalar


    var scalarCount: Int { get }

    var indices: Range<Int> { get }


    // MARK: Initialization

    init()

    init(repeating value: Scalar)

    init(arrayLiteral scalars: Scalar...)

    init<S>(_ scalars: S) where S : Sequence, Scalar == S.Element


    // MARK: Subscripts

    subscript(index: Int) -> Scalar { get set }

    subscript<Index>(index: SIMD2<Index>) -> SIMD2<Scalar> where Index : SIMDScalar & FixedWidthInteger { get }

    subscript<Index>(index: SIMD3<Index>) -> SIMD3<Scalar> where Index : SIMDScalar & FixedWidthInteger { get }

    subscript<Index>(index: SIMD4<Index>) -> SIMD4<Scalar> where Index : SIMDScalar & FixedWidthInteger { get }

    subscript<Index>(index: SIMD8<Index>) -> SIMD8<Scalar> where Index : SIMDScalar & FixedWidthInteger { get }

    subscript<Index>(index: SIMD16<Index>) -> SIMD16<Scalar> where Index : SIMDScalar & FixedWidthInteger { get }

    subscript<Index>(index: SIMD32<Index>) -> SIMD32<Scalar> where Index : SIMDScalar & FixedWidthInteger { get }

    subscript<Index>(index: SIMD64<Index>) -> SIMD64<Scalar> where Index : SIMDScalar & FixedWidthInteger { get }


    // MARK: Operators

    static func ==(lhs: Self, rhs: Self) -> Bool

    static func !=(lhs: Self, rhs: Self) -> Bool

}



// MARK: - KvSimdVectorComparable

public protocol KvSimdVectorComparable : KvSimdVector
where Scalar : Comparable
{

    mutating func clamp(lowerBound: Self, upperBound: Self)

    func clamped(lowerBound: Self, upperBound: Self) -> Self

    func max() -> Scalar

    func min() -> Scalar

}



// MARK: - KvSimdVectorI

/// Protocol for SIMD vectors where components conform to *FixedWidthInteger* protocol.
public protocol KvSimdVectorI : KvSimdVector where Scalar : FixedWidthInteger {

    static var zero: Self { get }
    static var one: Self { get }


    var leadingZeroBitCount: Self { get }
    var trailingZeroBitCount: Self { get }
    var nonzeroBitCount: Self { get }


    // MARK: Randomization

    static func random<T>(in range: Range<Scalar>, using generator: inout T) -> Self where T : RandomNumberGenerator

    static func random(in range: Range<Scalar>) -> Self

    static func random<T>(in range: ClosedRange<Scalar>, using generator: inout T) -> Self where T : RandomNumberGenerator

    static func random(in range: ClosedRange<Scalar>) -> Self


    // MARK: Operations

    func wrappedSum() -> Scalar


    // MARK: Operators

    prefix static func ~(a: Self) -> Self

    static func &(a: Self, b: Self) -> Self

    static func ^(a: Self, b: Self) -> Self

    static func |(a: Self, b: Self) -> Self

    static func &<<(a: Self, b: Self) -> Self

    static func &>>(a: Self, b: Self) -> Self

    static func &+(a: Self, b: Self) -> Self

    static func &-(a: Self, b: Self) -> Self

    static func &*(a: Self, b: Self) -> Self

    static func /(a: Self, b: Self) -> Self

    static func %(a: Self, b: Self) -> Self

    static func &(a: Scalar, b: Self) -> Self

    static func ^(a: Scalar, b: Self) -> Self

    static func |(a: Scalar, b: Self) -> Self

    static func &<<(a: Scalar, b: Self) -> Self

    static func &>>(a: Scalar, b: Self) -> Self

    static func &+(a: Scalar, b: Self) -> Self

    static func &-(a: Scalar, b: Self) -> Self

    static func &*(a: Scalar, b: Self) -> Self

    static func /(a: Scalar, b: Self) -> Self

    static func %(a: Scalar, b: Self) -> Self

    static func &(a: Self, b: Scalar) -> Self

    static func ^(a: Self, b: Scalar) -> Self

    static func |(a: Self, b: Scalar) -> Self

    static func &<<(a: Self, b: Scalar) -> Self

    static func &>>(a: Self, b: Scalar) -> Self

    static func &+(a: Self, b: Scalar) -> Self

    static func &-(a: Self, b: Scalar) -> Self

    static func &*(a: Self, b: Scalar) -> Self

    static func /(a: Self, b: Scalar) -> Self

    static func %(a: Self, b: Scalar) -> Self

    static func &=(a: inout Self, b: Self)

    static func ^=(a: inout Self, b: Self)

    static func |=(a: inout Self, b: Self)

    static func &<<=(a: inout Self, b: Self)

    static func &>>=(a: inout Self, b: Self)

    static func &+=(a: inout Self, b: Self)

    static func &-=(a: inout Self, b: Self)

    static func &*=(a: inout Self, b: Self)

    static func /=(a: inout Self, b: Self)

    static func %=(a: inout Self, b: Self)

    static func &=(a: inout Self, b: Scalar)

    static func ^=(a: inout Self, b: Scalar)

    static func |=(a: inout Self, b: Scalar)

    static func &<<=(a: inout Self, b: Scalar)

    static func &>>=(a: inout Self, b: Scalar)

    static func &+=(a: inout Self, b: Scalar)

    static func &-=(a: inout Self, b: Scalar)

    static func &*=(a: inout Self, b: Scalar)

    static func /=(a: inout Self, b: Scalar)

    static func %=(a: inout Self, b: Scalar)

}



// MARK: - KvSimdVectorF

/// Protocol for SIMD vectors where components conform to *BinaryFloatingPoint* protocol.
public protocol KvSimdVectorF : KvSimdVector where Scalar : FloatingPoint {

    static var zero: Self { get }
    static var one: Self { get }


    // MARK: Operations

    func addingProduct(_ a: Self, _ b: Self) -> Self

    func addingProduct(_ a: Scalar, _ b: Self) -> Self

    func addingProduct(_ a: Self, _ b: Scalar) -> Self

    mutating func addProduct(_ a: Self, _ b: Self)

    mutating func addProduct(_ a: Scalar, _ b: Self)

    mutating func addProduct(_ a: Self, _ b: Scalar)

    mutating func clamp(lowerBound: Self, upperBound: Self)

    func clamped(lowerBound: Self, upperBound: Self) -> Self

    mutating func formSquareRoot()

    func max() -> Scalar

    func min() -> Scalar

    mutating func round(_ rule: FloatingPointRoundingRule)

    func rounded(_ rule: FloatingPointRoundingRule) -> Self

    func squareRoot() -> Self

    func sum() -> Scalar


    // MARK: Operators

    static func +(a: Self, b: Self) -> Self

    static func -(a: Self, b: Self) -> Self

    static func *(a: Self, b: Self) -> Self

    static func /(a: Self, b: Self) -> Self

    prefix static func -(a: Self) -> Self

    static func +(a: Scalar, b: Self) -> Self

    static func -(a: Scalar, b: Self) -> Self

    static func *(a: Scalar, b: Self) -> Self

    static func /(a: Scalar, b: Self) -> Self

    static func +(a: Self, b: Scalar) -> Self

    static func -(a: Self, b: Scalar) -> Self

    static func *(a: Self, b: Scalar) -> Self

    static func /(a: Self, b: Scalar) -> Self

    static func +=(a: inout Self, b: Self)

    static func -=(a: inout Self, b: Self)

    static func *=(a: inout Self, b: Self)

    static func /=(a: inout Self, b: Self)

    static func +=(a: inout Self, b: Scalar)

    static func -=(a: inout Self, b: Scalar)

    static func *=(a: inout Self, b: Scalar)

    static func /=(a: inout Self, b: Scalar)

}



// MARK: - KvSimd2

/// Protocol for SIMD2 vectors.
public protocol KvSimd2 : KvSimdVector {

    var x: Scalar { get set }
    var y: Scalar { get set }


    // MARK: Initialization

    init(_ v0: Scalar, _ v1: Scalar)

    init(x: Scalar, y: Scalar)

}



// MARK: - KvSimd2I

/// Protocol for SIMD2 vectors where components conform to *FixedWidthInteger* protocol.
public protocol KvSimd2I : KvSimd2, KvSimdVectorI {

    /// `[ 1, 0 ]`
    static var unitX: Self { get }
    /// `[ -1, 0 ]`
    static var unitNX: Self { get }
    /// `[ 0, 1 ]`
    static var unitY: Self { get }
    /// `[ 0, -1 ]`
    static var unitNY: Self { get }


    init<Other>(_ other: SIMD2<Other>, rounding rule: FloatingPointRoundingRule)
    where Other : BinaryFloatingPoint, Other : SIMDScalar

    init<Other>(clamping other: SIMD2<Other>) where Other : FixedWidthInteger, Other : SIMDScalar

    init<Other>(truncatingIfNeeded other: SIMD2<Other>) where Other : FixedWidthInteger, Other : SIMDScalar

}



// MARK: - KvSimd2F

/// Protocol for SIMD2 vectors where components conform to *BinaryFloatingPoint* protocol.
public protocol KvSimd2F : KvSimd2, KvSimdVectorF where Scalar : BinaryFloatingPoint {

    /// `[ 1, 0 ]`
    static var unitX: Self { get }
    /// `[ -1, 0 ]`
    static var unitNX: Self { get }
    /// `[ 0, 1 ]`
    static var unitY: Self { get }
    /// `[ 0, -1 ]`
    static var unitNY: Self { get }


    init<Other>(_ other: SIMD2<Other>) where Other : BinaryFloatingPoint, Other : SIMDScalar

    init<Other>(_ other: SIMD2<Other>) where Other : FixedWidthInteger, Other : SIMDScalar

}



// MARK: - KvSimd3

/// Protocol for SIMD3 vectors.
public protocol KvSimd3 : KvSimdVector {

    var x: Scalar { get set }
    var y: Scalar { get set }
    var z: Scalar { get set }


    // MARK: Initialization

    init(_ v0: Scalar, _ v1: Scalar, _ v2: Scalar)

    init(x: Scalar, y: Scalar, z: Scalar)

    init(_ xy: SIMD2<Scalar>, _ w: Scalar)

}


extension KvSimd3 {

    @inlinable
    public init<V2>(_ xy: V2, _ z: Scalar)
    where V2 : KvSimd2, V2.Scalar == Scalar
    {
        self.init(xy.x, xy.y, z)
    }

}



// MARK: - KvSimd3I

/// Protocol for SIMD3 vectors where components conform to *FixedWidthInteger* protocol.
public protocol KvSimd3I : KvSimd3, KvSimdVectorI {

    /// `[ 1, 0, 0 ]`
    static var unitX: Self { get }
    /// `[ -1, 0, 0 ]`
    static var unitNX: Self { get }
    /// `[ 0, 1, 0 ]`
    static var unitY: Self { get }
    /// `[ 0, -1, 0 ]`
    static var unitNY: Self { get }
    /// `[ 0, 0, 1 ]`
    static var unitZ: Self { get }
    /// `[ 0, 0, -1 ]`
    static var unitNZ: Self { get }


    init<Other>(_ other: SIMD3<Other>, rounding rule: FloatingPointRoundingRule)
    where Other : BinaryFloatingPoint, Other : SIMDScalar

    init<Other>(clamping other: SIMD3<Other>) where Other : FixedWidthInteger, Other : SIMDScalar

    init<Other>(truncatingIfNeeded other: SIMD3<Other>) where Other : FixedWidthInteger, Other : SIMDScalar

}



// MARK: - KvSimd3F

/// Protocol for SIMD3 vectors where components conform to *BinaryFloatingPoint* protocol.
public protocol KvSimd3F : KvSimd3, KvSimdVectorF where Scalar : BinaryFloatingPoint {

    /// `[ 1, 0, 0 ]`
    static var unitX: Self { get }
    /// `[ -1, 0, 0 ]`
    static var unitNX: Self { get }
    /// `[ 0, 1, 0 ]`
    static var unitY: Self { get }
    /// `[ 0, -1, 0 ]`
    static var unitNY: Self { get }
    /// `[ 0, 0, 1 ]`
    static var unitZ: Self { get }
    /// `[ 0, 0, -1 ]`
    static var unitNZ: Self { get }


    init<Other>(_ other: SIMD3<Other>) where Other : BinaryFloatingPoint, Other : SIMDScalar

    init<Other>(_ other: SIMD3<Other>) where Other : FixedWidthInteger, Other : SIMDScalar

}



// MARK: - KvSimd4

/// Protocol for SIMD4 vectors.
public protocol KvSimd4 : KvSimdVector {

    var x: Scalar { get set }
    var y: Scalar { get set }
    var z: Scalar { get set }
    var w: Scalar { get set }

    var lowHalf: SIMD2<Scalar> { get set }
    var highHalf: SIMD2<Scalar> { get set }
    var evenHalf: SIMD2<Scalar> { get set }
    var oddHalf: SIMD2<Scalar> { get set }


    // MARK: Initialization

    init(_ v0: Scalar, _ v1: Scalar, _ v2: Scalar, _ v3: Scalar)

    init(x: Scalar, y: Scalar, z: Scalar, w: Scalar)

    init(lowHalf: SIMD2<Scalar>, highHalf: SIMD2<Scalar>)

    init(_ xyz: SIMD3<Scalar>, _ w: Scalar)

}


extension KvSimd4 {

    @inlinable
    public init<LH, RH>(lowHalf: LH, highHalf: RH)
    where LH : KvSimd2, LH.Scalar == Scalar, RH : KvSimd2, RH.Scalar == Scalar
    {
        self.init(lowHalf.x, lowHalf.y, highHalf.x, highHalf.y)
    }


    @inlinable
    public init<V3>(_ xyz: V3, _ w: Scalar)
    where V3 : KvSimd3, V3.Scalar == Scalar
    {
        self.init(xyz.x, xyz.y, xyz.z, w)
    }

}



// MARK: - KvSimd4I

/// Protocol for SIMD4 vectors where components conform to *FixedWidthInteger* protocol.
public protocol KvSimd4I : KvSimd4, KvSimdVectorI {

    /// `[ 1, 0, 0, 0 ]`
    static var unitX: Self { get }
    /// `[ -1, 0, 0, 0 ]`
    static var unitNX: Self { get }
    /// `[ 0, 1, 0, 0 ]`
    static var unitY: Self { get }
    /// `[ 0, -1, 0, 0 ]`
    static var unitNY: Self { get }
    /// `[ 0, 0, 1, 0 ]`
    static var unitZ: Self { get }
    /// `[ 0, 0, -1, 0 ]`
    static var unitNZ: Self { get }
    /// `[ 0, 0, 0, 1 ]`
    static var unitW: Self { get }
    /// `[ 0, 0, 0, -1 ]`
    static var unitNW: Self { get }


    init<Other>(_ other: SIMD4<Other>, rounding rule: FloatingPointRoundingRule)
    where Other : BinaryFloatingPoint, Other : SIMDScalar

    init<Other>(clamping other: SIMD4<Other>) where Other : FixedWidthInteger, Other : SIMDScalar

    init<Other>(truncatingIfNeeded other: SIMD4<Other>) where Other : FixedWidthInteger, Other : SIMDScalar

}



// MARK: - KvSimd4F

/// Protocol for SIMD4 vectors where components conform to *BinaryFloatingPoint* protocol.
public protocol KvSimd4F : KvSimd4, KvSimdVectorF where Scalar : BinaryFloatingPoint {

    /// `[ 1, 0, 0, 0 ]`
    static var unitX: Self { get }
    /// `[ -1, 0, 0, 0 ]`
    static var unitNX: Self { get }
    /// `[ 0, 1, 0, 0 ]`
    static var unitY: Self { get }
    /// `[ 0, -1, 0, 0 ]`
    static var unitNY: Self { get }
    /// `[ 0, 0, 1, 0 ]`
    static var unitZ: Self { get }
    /// `[ 0, 0, -1, 0 ]`
    static var unitNZ: Self { get }
    /// `[ 0, 0, 0, 1 ]`
    static var unitW: Self { get }
    /// `[ 0, 0, 0, -1 ]`
    static var unitNW: Self { get }


    init<Other>(_ other: SIMD4<Other>) where Other : BinaryFloatingPoint, Other : SIMDScalar

    init<Other>(_ other: SIMD4<Other>) where Other : FixedWidthInteger, Other : SIMDScalar

}



// MARK: - KvSimd8

/// Protocol for SIMD8 vectors.
public protocol KvSimd8 : KvSimdVector {

    var lowHalf: SIMD4<Scalar> { get set }
    var highHalf: SIMD4<Scalar> { get set }
    var evenHalf: SIMD4<Scalar> { get set }
    var oddHalf: SIMD4<Scalar> { get set }


    // MARK: Initialization

    init(_ v0: Scalar, _ v1: Scalar, _ v2: Scalar, _ v3: Scalar, _ v4: Scalar, _ v5: Scalar, _ v6: Scalar, _ v7: Scalar)

    init(lowHalf: SIMD4<Scalar>, highHalf: SIMD4<Scalar>)

}



// MARK: - KvSimd8I

/// Protocol for SIMD8 vectors where components conform to *FixedWidthInteger* protocol.
public protocol KvSimd8I : KvSimd8, KvSimdVectorI {

    init<Other>(_ other: SIMD8<Other>, rounding rule: FloatingPointRoundingRule)
    where Other : BinaryFloatingPoint, Other : SIMDScalar

    init<Other>(clamping other: SIMD8<Other>) where Other : FixedWidthInteger, Other : SIMDScalar

    init<Other>(truncatingIfNeeded other: SIMD8<Other>) where Other : FixedWidthInteger, Other : SIMDScalar

}



// MARK: - KvSimd8F

/// Protocol for SIMD8 vectors where components conform to *BinaryFloatingPoint* protocol.
public protocol KvSimd8F : KvSimd8, KvSimdVectorF where Scalar : BinaryFloatingPoint {

    init<Other>(_ other: SIMD8<Other>) where Other : BinaryFloatingPoint, Other : SIMDScalar

    init<Other>(_ other: SIMD8<Other>) where Other : FixedWidthInteger, Other : SIMDScalar

}



// MARK: - KvSimd16

/// Protocol for SIMD16 vectors.
public protocol KvSimd16 : KvSimdVector {

    var lowHalf: SIMD8<Scalar> { get set }
    var highHalf: SIMD8<Scalar> { get set }
    var evenHalf: SIMD8<Scalar> { get set }
    var oddHalf: SIMD8<Scalar> { get set }


    // MARK: Initialization

    init(_ v0: Scalar, _ v1: Scalar, _ v2: Scalar, _ v3: Scalar, _ v4: Scalar, _ v5: Scalar, _ v6: Scalar, _ v7: Scalar, _ v8: Scalar, _ v9: Scalar, _ v10: Scalar, _ v11: Scalar, _ v12: Scalar, _ v13: Scalar, _ v14: Scalar, _ v15: Scalar)

    init(lowHalf: SIMD8<Scalar>, highHalf: SIMD8<Scalar>)

}



// MARK: - KvSimd16I

/// Protocol for SIMD16 vectors where components conform to *FixedWidthInteger* protocol.
public protocol KvSimd16I : KvSimd16, KvSimdVectorI {

    init<Other>(_ other: SIMD16<Other>, rounding rule: FloatingPointRoundingRule)
    where Other : BinaryFloatingPoint, Other : SIMDScalar

    init<Other>(clamping other: SIMD16<Other>) where Other : FixedWidthInteger, Other : SIMDScalar

    init<Other>(truncatingIfNeeded other: SIMD16<Other>) where Other : FixedWidthInteger, Other : SIMDScalar

}



// MARK: - KvSimd16F

/// Protocol for SIMD16 vectors where components conform to *BinaryFloatingPoint* protocol.
public protocol KvSimd16F : KvSimd16, KvSimdVectorF where Scalar : BinaryFloatingPoint {

    init<Other>(_ other: SIMD16<Other>) where Other : BinaryFloatingPoint, Other : SIMDScalar

    init<Other>(_ other: SIMD16<Other>) where Other : FixedWidthInteger, Other : SIMDScalar

}



// MARK: - KvSimd32

/// Protocol for SIMD32 vectors.
public protocol KvSimd32 : KvSimdVector {

    var lowHalf: SIMD16<Scalar> { get set }
    var highHalf: SIMD16<Scalar> { get set }
    var evenHalf: SIMD16<Scalar> { get set }
    var oddHalf: SIMD16<Scalar> { get set }


    // MARK: Initialization

    init(_ v0: Scalar, _ v1: Scalar, _ v2: Scalar, _ v3: Scalar, _ v4: Scalar, _ v5: Scalar, _ v6: Scalar, _ v7: Scalar, _ v8: Scalar, _ v9: Scalar, _ v10: Scalar, _ v11: Scalar, _ v12: Scalar, _ v13: Scalar, _ v14: Scalar, _ v15: Scalar, _ v16: Scalar, _ v17: Scalar, _ v18: Scalar, _ v19: Scalar, _ v20: Scalar, _ v21: Scalar, _ v22: Scalar, _ v23: Scalar, _ v24: Scalar, _ v25: Scalar, _ v26: Scalar, _ v27: Scalar, _ v28: Scalar, _ v29: Scalar, _ v30: Scalar, _ v31: Scalar)

    init(lowHalf: SIMD16<Scalar>, highHalf: SIMD16<Scalar>)

}



// MARK: - KvSimd32I

/// Protocol for SIMD32 vectors where components conform to *FixedWidthInteger* protocol.
public protocol KvSimd32I : KvSimd32, KvSimdVectorI {

    init<Other>(_ other: SIMD32<Other>, rounding rule: FloatingPointRoundingRule)
    where Other : BinaryFloatingPoint, Other : SIMDScalar

    init<Other>(clamping other: SIMD32<Other>) where Other : FixedWidthInteger, Other : SIMDScalar

    init<Other>(truncatingIfNeeded other: SIMD32<Other>) where Other : FixedWidthInteger, Other : SIMDScalar

}



// MARK: - KvSimd32F

/// Protocol for SIMD32 vectors where components conform to *BinaryFloatingPoint* protocol.
public protocol KvSimd32F : KvSimd32, KvSimdVectorF where Scalar : BinaryFloatingPoint {

    init<Other>(_ other: SIMD32<Other>) where Other : BinaryFloatingPoint, Other : SIMDScalar

    init<Other>(_ other: SIMD32<Other>) where Other : FixedWidthInteger, Other : SIMDScalar

}



// MARK: - KvSimd64

/// Protocol for SIMD64 vectors.
public protocol KvSimd64 : KvSimdVector {

    var lowHalf: SIMD32<Scalar> { get set }
    var highHalf: SIMD32<Scalar> { get set }
    var evenHalf: SIMD32<Scalar> { get set }
    var oddHalf: SIMD32<Scalar> { get set }


    // MARK: Initialization

    init(_ v0: Scalar, _ v1: Scalar, _ v2: Scalar, _ v3: Scalar, _ v4: Scalar, _ v5: Scalar, _ v6: Scalar, _ v7: Scalar, _ v8: Scalar, _ v9: Scalar, _ v10: Scalar, _ v11: Scalar, _ v12: Scalar, _ v13: Scalar, _ v14: Scalar, _ v15: Scalar, _ v16: Scalar, _ v17: Scalar, _ v18: Scalar, _ v19: Scalar, _ v20: Scalar, _ v21: Scalar, _ v22: Scalar, _ v23: Scalar, _ v24: Scalar, _ v25: Scalar, _ v26: Scalar, _ v27: Scalar, _ v28: Scalar, _ v29: Scalar, _ v30: Scalar, _ v31: Scalar, _ v32: Scalar, _ v33: Scalar, _ v34: Scalar, _ v35: Scalar, _ v36: Scalar, _ v37: Scalar, _ v38: Scalar, _ v39: Scalar, _ v40: Scalar, _ v41: Scalar, _ v42: Scalar, _ v43: Scalar, _ v44: Scalar, _ v45: Scalar, _ v46: Scalar, _ v47: Scalar, _ v48: Scalar, _ v49: Scalar, _ v50: Scalar, _ v51: Scalar, _ v52: Scalar, _ v53: Scalar, _ v54: Scalar, _ v55: Scalar, _ v56: Scalar, _ v57: Scalar, _ v58: Scalar, _ v59: Scalar, _ v60: Scalar, _ v61: Scalar, _ v62: Scalar, _ v63: Scalar)

    init(lowHalf: SIMD32<Scalar>, highHalf: SIMD32<Scalar>)

}



// MARK: - KvSimd64I

/// Protocol for SIMD64 vectors where components conform to *FixedWidthInteger* protocol.
public protocol KvSimd64I : KvSimd64, KvSimdVectorI {

    init<Other>(_ other: SIMD64<Other>, rounding rule: FloatingPointRoundingRule)
    where Other : BinaryFloatingPoint, Other : SIMDScalar

    init<Other>(clamping other: SIMD64<Other>) where Other : FixedWidthInteger, Other : SIMDScalar

    init<Other>(truncatingIfNeeded other: SIMD64<Other>) where Other : FixedWidthInteger, Other : SIMDScalar

}



// MARK: - KvSimd64F

/// Protocol for SIMD64 vectors where components conform to *BinaryFloatingPoint* protocol.
public protocol KvSimd64F : KvSimd64, KvSimdVectorF where Scalar : BinaryFloatingPoint {

    init<Other>(_ other: SIMD64<Other>) where Other : BinaryFloatingPoint, Other : SIMDScalar

    init<Other>(_ other: SIMD64<Other>) where Other : FixedWidthInteger, Other : SIMDScalar

}



// MARK: - SIMD2

extension SIMD2 : KvSimd2 { }
extension SIMD2 : KvSimdVectorComparable where Scalar : Comparable { }
extension SIMD2 : KvSimdVectorI where Scalar : FixedWidthInteger { }
extension SIMD2 : KvSimdVectorF where Scalar : FloatingPoint { }
extension SIMD2 : KvSimd2I where Scalar : FixedWidthInteger {

    /// `[ 1, 0 ]`
    @inlinable public static var unitX: Self { [ 1, 0 ] }
    /// `[ -1, 0 ]`
    @inlinable public static var unitNX: Self { [ -1, 0 ] }
    /// `[ 0, 1 ]`
    @inlinable public static var unitY: Self { [ 0, 1 ] }
    /// `[ 0, -1 ]`
    @inlinable public static var unitNY: Self { [ 0, -1 ] }

}
extension SIMD2 : KvSimd2F where Scalar : BinaryFloatingPoint {

    /// `[ 1, 0 ]`
    @inlinable public static var unitX: Self { [ 1, 0 ] }
    /// `[ -1, 0 ]`
    @inlinable public static var unitNX: Self { [ -1, 0 ] }
    /// `[ 0, 1 ]`
    @inlinable public static var unitY: Self { [ 0, 1 ] }
    /// `[ 0, -1 ]`
    @inlinable public static var unitNY: Self { [ 0, -1 ] }

}



// MARK: - SIMD3

extension SIMD3 : KvSimd3 { }
extension SIMD3 : KvSimdVectorComparable where Scalar : Comparable { }
extension SIMD3 : KvSimdVectorI where Scalar : FixedWidthInteger { }
extension SIMD3 : KvSimdVectorF where Scalar : FloatingPoint { }
extension SIMD3 : KvSimd3I where Scalar : FixedWidthInteger {

    /// `[ 1, 0, 0 ]`
    @inlinable public static var unitX: Self { [ 1, 0, 0 ] }
    /// `[ -1, 0, 0 ]`
    @inlinable public static var unitNX: Self { [ -1, 0, 0 ] }
    /// `[ 0, 1, 0 ]`
    @inlinable public static var unitY: Self { [ 0, 1, 0 ] }
    /// `[ 0, -1, 0 ]`
    @inlinable public static var unitNY: Self { [ 0, -1, 0 ] }
    /// `[ 0, 0, 1 ]`
    @inlinable public static var unitZ: Self { [ 0, 0, 1 ] }
    /// `[ 0, 0, -1 ]`
    @inlinable public static var unitNZ: Self { [ 0, 0, -1 ] }

}
extension SIMD3 : KvSimd3F where Scalar : BinaryFloatingPoint {

    /// `[ 1, 0, 0 ]`
    @inlinable public static var unitX: Self { [ 1, 0, 0 ] }
    /// `[ -1, 0, 0 ]`
    @inlinable public static var unitNX: Self { [ -1, 0, 0 ] }
    /// `[ 0, 1, 0 ]`
    @inlinable public static var unitY: Self { [ 0, 1, 0 ] }
    /// `[ 0, -1, 0 ]`
    @inlinable public static var unitNY: Self { [ 0, -1, 0 ] }
    /// `[ 0, 0, 1 ]`
    @inlinable public static var unitZ: Self { [ 0, 0, 1 ] }
    /// `[ 0, 0, -1 ]`
    @inlinable public static var unitNZ: Self { [ 0, 0, -1 ] }

}



// MARK: - SIMD4

extension SIMD4 : KvSimd4 { }
extension SIMD4 : KvSimdVectorComparable where Scalar : Comparable { }
extension SIMD4 : KvSimdVectorI where Scalar : FixedWidthInteger { }
extension SIMD4 : KvSimdVectorF where Scalar : FloatingPoint { }
extension SIMD4 : KvSimd4I where Scalar : FixedWidthInteger {

    /// `[ 1, 0, 0, 0 ]`
    @inlinable public static var unitX: Self { [ 1, 0, 0, 0 ] }
    /// `[ -1, 0, 0, 0 ]`
    @inlinable public static var unitNX: Self { [ -1, 0, 0, 0 ] }
    /// `[ 0, 1, 0, 0 ]`
    @inlinable public static var unitY: Self { [ 0, 1, 0, 0 ] }
    /// `[ 0, -1, 0, 0 ]`
    @inlinable public static var unitNY: Self { [ 0, -1, 0, 0 ] }
    /// `[ 0, 0, 1, 0 ]`
    @inlinable public static var unitZ: Self { [ 0, 0, 1, 0 ] }
    /// `[ 0, 0, -1, 0 ]`
    @inlinable public static var unitNZ: Self { [ 0, 0, -1, 0 ] }
    /// `[ 0, 0, 0, 1 ]`
    @inlinable public static var unitW: Self { [ 0, 0, 0, 1 ] }
    /// `[ 0, 0, 0, -1 ]`
    @inlinable public static var unitNW: Self { [ 0, 0, 0, -1 ] }

}
extension SIMD4 : KvSimd4F where Scalar : BinaryFloatingPoint {

    /// `[ 1, 0, 0, 0 ]`
    @inlinable public static var unitX: Self { [ 1, 0, 0, 0 ] }
    /// `[ -1, 0, 0, 0 ]`
    @inlinable public static var unitNX: Self { [ -1, 0, 0, 0 ] }
    /// `[ 0, 1, 0, 0 ]`
    @inlinable public static var unitY: Self { [ 0, 1, 0, 0 ] }
    /// `[ 0, -1, 0, 0 ]`
    @inlinable public static var unitNY: Self { [ 0, -1, 0, 0 ] }
    /// `[ 0, 0, 1, 0 ]`
    @inlinable public static var unitZ: Self { [ 0, 0, 1, 0 ] }
    /// `[ 0, 0, -1, 0 ]`
    @inlinable public static var unitNZ: Self { [ 0, 0, -1, 0 ] }
    /// `[ 0, 0, 0, 1 ]`
    @inlinable public static var unitW: Self { [ 0, 0, 0, 1 ] }
    /// `[ 0, 0, 0, -1 ]`
    @inlinable public static var unitNW: Self { [ 0, 0, 0, -1 ] }

}



// MARK: - SIMD8

extension SIMD8 : KvSimd8 { }
extension SIMD8 : KvSimdVectorComparable where Scalar : Comparable { }
extension SIMD8 : KvSimdVectorI where Scalar : FixedWidthInteger { }
extension SIMD8 : KvSimdVectorF where Scalar : FloatingPoint { }
extension SIMD8 : KvSimd8I where Scalar : FixedWidthInteger { }
extension SIMD8 : KvSimd8F where Scalar : BinaryFloatingPoint { }



// MARK: - SIMD16

extension SIMD16 : KvSimd16 { }
extension SIMD16 : KvSimdVectorComparable where Scalar : Comparable { }
extension SIMD16 : KvSimdVectorI where Scalar : FixedWidthInteger { }
extension SIMD16 : KvSimdVectorF where Scalar : FloatingPoint { }
extension SIMD16 : KvSimd16I where Scalar : FixedWidthInteger { }
extension SIMD16 : KvSimd16F where Scalar : BinaryFloatingPoint { }



// MARK: - SIMD32

extension SIMD32 : KvSimd32 { }
extension SIMD32 : KvSimdVectorComparable where Scalar : Comparable { }
extension SIMD32 : KvSimdVectorI where Scalar : FixedWidthInteger { }
extension SIMD32 : KvSimdVectorF where Scalar : FloatingPoint { }
extension SIMD32 : KvSimd32I where Scalar : FixedWidthInteger { }
extension SIMD32 : KvSimd32F where Scalar : BinaryFloatingPoint { }



// MARK: - SIMD64

extension SIMD64 : KvSimd64 { }
extension SIMD64 : KvSimdVectorComparable where Scalar : Comparable { }
extension SIMD64 : KvSimdVectorI where Scalar : FixedWidthInteger { }
extension SIMD64 : KvSimdVectorF where Scalar : FloatingPoint { }
extension SIMD64 : KvSimd64I where Scalar : FixedWidthInteger { }
extension SIMD64 : KvSimd64F where Scalar : BinaryFloatingPoint { }
