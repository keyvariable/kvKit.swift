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
//  Collection of convinient protocols to provide generic constarints for dimmensions of SIMD vectors.
//

import simd



// MARK: - KvSimdVectorScalar

public typealias KvSimdVectorScalar = SIMDScalar & Comparable



// MARK: - KvSimdVector

public protocol KvSimdVector : SIMD
where Scalar : KvSimdVectorScalar, ArrayLiteralElement == Scalar
{

    associatedtype SimdView : SIMD where SimdView.Scalar == Scalar


    // MARK: Properties

    var scalarCount: Int { get }

    var indices: Range<Int> { get }

    /// SIMD representation of the receiver.
    var simdView: SimdView { get set }


    // MARK: Initialization

    init()

    init(repeating value: Scalar)

    init(arrayLiteral scalars: Scalar...)

    init<S>(_ scalars: S) where S : Sequence, Scalar == S.Element

    init(simdView: SimdView)


    // MARK: Subscripts

    subscript(index: Int) -> Scalar { get set }

    subscript<Index>(index: SIMD2<Index>) -> Sample2 where Index : SIMDScalar & FixedWidthInteger { get }

    subscript<Index>(index: SIMD3<Index>) -> Sample3 where Index : SIMDScalar & FixedWidthInteger { get }

    subscript<Index>(index: SIMD4<Index>) -> Sample4 where Index : SIMDScalar & FixedWidthInteger { get }

    subscript<Index>(index: SIMD8<Index>) -> Sample8 where Index : SIMDScalar & FixedWidthInteger { get }

    subscript<Index>(index: SIMD16<Index>) -> Sample16 where Index : SIMDScalar & FixedWidthInteger { get }

    subscript<Index>(index: SIMD32<Index>) -> Sample32 where Index : SIMDScalar & FixedWidthInteger { get }

    subscript<Index>(index: SIMD64<Index>) -> Sample64 where Index : SIMDScalar & FixedWidthInteger { get }


    // MARK: Operations

    func min() -> Scalar

    func max() -> Scalar

    mutating func clamp(lowerBound: Self, upperBound: Self)

    func clamped(lowerBound: Self, upperBound: Self) -> Self


    // MARK: Operators

    static func ==(lhs: Self, rhs: Self) -> Bool

    static func !=(lhs: Self, rhs: Self) -> Bool

}


extension KvSimdVector {

    /// Type for samples of 2 components.
    public typealias Sample2 = SIMD2<Scalar>
    /// Type for samples of 3 components.
    public typealias Sample3 = SIMD3<Scalar>
    /// Type for samples of 4 components.
    public typealias Sample4 = SIMD4<Scalar>
    /// Type for samples of 8 components.
    public typealias Sample8 = SIMD8<Scalar>
    /// Type for samples of 16 components.
    public typealias Sample16 = SIMD16<Scalar>
    /// Type for samples of 32 components.
    public typealias Sample32 = SIMD32<Scalar>
    /// Type for samples of 64 components.
    public typealias Sample64 = SIMD64<Scalar>

}


@inlinable
public func ==<LHS, RHS>(lhs: LHS, rhs: RHS) -> Bool where LHS : KvSimdVector, RHS : KvSimdVector, LHS.SimdView == RHS.SimdView {
    lhs.simdView == rhs.simdView
}

@inlinable
public func !=<LHS, RHS>(lhs: LHS, rhs: RHS) -> Bool where LHS : KvSimdVector, RHS : KvSimdVector, LHS.SimdView == RHS.SimdView {
    lhs.simdView != rhs.simdView
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


@inlinable
public prefix func ~ <RHS>(a: RHS) -> RHS where RHS : KvSimdVectorI {
    RHS(simdView: 0 &- a.simdView)
}

@inlinable
public func & <LHS, RHS>(a: LHS, b: RHS) -> LHS where LHS : KvSimdVectorI, RHS : KvSimdVectorI, LHS.SimdView == RHS.SimdView {
    LHS(simdView: a.simdView & b.simdView)
}

@inlinable
public func ^ <LHS, RHS>(a: LHS, b: RHS) -> LHS where LHS : KvSimdVectorI, RHS : KvSimdVectorI, LHS.SimdView == RHS.SimdView {
    LHS(simdView: a.simdView ^ b.simdView)
}

@inlinable
public func | <LHS, RHS>(a: LHS, b: RHS) -> LHS where LHS : KvSimdVectorI, RHS : KvSimdVectorI, LHS.SimdView == RHS.SimdView {
    LHS(simdView: a.simdView | b.simdView)
}

@inlinable
public func &<< <LHS, RHS>(a: LHS, b: RHS) -> LHS where LHS : KvSimdVectorI, RHS : KvSimdVectorI, LHS.SimdView == RHS.SimdView {
    LHS(simdView: a.simdView &<< b.simdView)
}

@inlinable
public func &>> <LHS, RHS>(a: LHS, b: RHS) -> LHS where LHS : KvSimdVectorI, RHS : KvSimdVectorI, LHS.SimdView == RHS.SimdView {
    LHS(simdView: a.simdView &>> b.simdView)
}

@inlinable
public func &+ <LHS, RHS>(a: LHS, b: RHS) -> LHS where LHS : KvSimdVectorI, RHS : KvSimdVectorI, LHS.SimdView == RHS.SimdView {
    LHS(simdView: a.simdView &+ b.simdView)
}

@inlinable
public func &- <LHS, RHS>(a: LHS, b: RHS) -> LHS where LHS : KvSimdVectorI, RHS : KvSimdVectorI, LHS.SimdView == RHS.SimdView {
    LHS(simdView: a.simdView &- b.simdView)
}

@inlinable
public func &* <LHS, RHS>(a: LHS, b: RHS) -> LHS where LHS : KvSimdVectorI, RHS : KvSimdVectorI, LHS.SimdView == RHS.SimdView {
    LHS(simdView: a.simdView &* b.simdView)
}

@inlinable
public func / <LHS, RHS>(a: LHS, b: RHS) -> LHS where LHS : KvSimdVectorI, RHS : KvSimdVectorI, LHS.SimdView == RHS.SimdView {
    LHS(simdView: a.simdView / b.simdView)
}

@inlinable
public func % <LHS, RHS>(a: LHS, b: RHS) -> LHS where LHS : KvSimdVectorI, RHS : KvSimdVectorI, LHS.SimdView == RHS.SimdView {
    LHS(simdView: a.simdView % b.simdView)
}

@inlinable
public func &= <LHS, RHS>(a: inout LHS, b: RHS) where LHS : KvSimdVectorI, RHS : KvSimdVectorI, LHS.SimdView == RHS.SimdView {
    a.simdView &= b.simdView
}

@inlinable
public func ^= <LHS, RHS>(a: inout LHS, b: RHS) where LHS : KvSimdVectorI, RHS : KvSimdVectorI, LHS.SimdView == RHS.SimdView {
    a.simdView ^= b.simdView
}

@inlinable
public func |= <LHS, RHS>(a: inout LHS, b: RHS) where LHS : KvSimdVectorI, RHS : KvSimdVectorI, LHS.SimdView == RHS.SimdView {
    a.simdView |= b.simdView
}

@inlinable
public func &<<= <LHS, RHS>(a: inout LHS, b: RHS) where LHS : KvSimdVectorI, RHS : KvSimdVectorI, LHS.SimdView == RHS.SimdView {
    a.simdView &<<= b.simdView
}

@inlinable
public func &>>= <LHS, RHS>(a: inout LHS, b: RHS) where LHS : KvSimdVectorI, RHS : KvSimdVectorI, LHS.SimdView == RHS.SimdView {
    a.simdView &>>= b.simdView
}

@inlinable
public func &+= <LHS, RHS>(a: inout LHS, b: RHS) where LHS : KvSimdVectorI, RHS : KvSimdVectorI, LHS.SimdView == RHS.SimdView {
    a.simdView &+= b.simdView
}

@inlinable
public func &-= <LHS, RHS>(a: inout LHS, b: RHS) where LHS : KvSimdVectorI, RHS : KvSimdVectorI, LHS.SimdView == RHS.SimdView {
    a.simdView &-= b.simdView
}

@inlinable
public func &*= <LHS, RHS>(a: inout LHS, b: RHS) where LHS : KvSimdVectorI, RHS : KvSimdVectorI, LHS.SimdView == RHS.SimdView {
    a.simdView &*= b.simdView
}

@inlinable
public func /= <LHS, RHS>(a: inout LHS, b: RHS) where LHS : KvSimdVectorI, RHS : KvSimdVectorI, LHS.SimdView == RHS.SimdView {
    a.simdView /= b.simdView
}

@inlinable
public func %= <LHS, RHS>(a: inout LHS, b: RHS) where LHS : KvSimdVectorI, RHS : KvSimdVectorI, LHS.SimdView == RHS.SimdView {
    a.simdView %= b.simdView
}



// MARK: - KvSimdVectorF

/// Protocol for SIMD vectors where components conform to *BinaryFloatingPoint* protocol.
public protocol KvSimdVectorF : KvSimdVector where Scalar : BinaryFloatingPoint {

    static var zero: Self { get }
    static var one: Self { get }


    // MARK: Operations

    func addingProduct(_ a: Self, _ b: Self) -> Self

    func addingProduct(_ a: Scalar, _ b: Self) -> Self

    func addingProduct(_ a: Self, _ b: Scalar) -> Self

    mutating func addProduct(_ a: Self, _ b: Self)

    mutating func addProduct(_ a: Scalar, _ b: Self)

    mutating func addProduct(_ a: Self, _ b: Scalar)

    func squareRoot() -> Self

    mutating func formSquareRoot()

    mutating func round(_ rule: FloatingPointRoundingRule)

    func rounded(_ rule: FloatingPointRoundingRule) -> Self

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


@inlinable
public prefix func - <RHS>(a: RHS) -> RHS where RHS : KvSimdVectorF { RHS(simdView: -a.simdView) }

@inlinable
public func + <LHS, RHS>(a: LHS, b: RHS) -> LHS where LHS : KvSimdVectorF, RHS : KvSimdVectorF, LHS.SimdView == RHS.SimdView {
    LHS(simdView: a.simdView + b.simdView)
}

@inlinable
public func - <LHS, RHS>(a: LHS, b: RHS) -> LHS where LHS : KvSimdVectorF, RHS : KvSimdVectorF, LHS.SimdView == RHS.SimdView {
    LHS(simdView: a.simdView - b.simdView)
}

@inlinable
public func * <LHS, RHS>(a: LHS, b: RHS) -> LHS where LHS : KvSimdVectorF, RHS : KvSimdVectorF, LHS.SimdView == RHS.SimdView {
    LHS(simdView: a.simdView * b.simdView)
}

@inlinable
public func / <LHS, RHS>(a: LHS, b: RHS) -> LHS where LHS : KvSimdVectorF, RHS : KvSimdVectorF, LHS.SimdView == RHS.SimdView {
    LHS(simdView: a.simdView / b.simdView)
}

@inlinable
public func += <LHS, RHS>(a: inout LHS, b: RHS) where LHS : KvSimdVectorF, RHS : KvSimdVectorF, LHS.SimdView == RHS.SimdView {
    a.simdView += b.simdView
}

@inlinable
public func -= <LHS, RHS>(a: inout LHS, b: RHS) where LHS : KvSimdVectorF, RHS : KvSimdVectorF, LHS.SimdView == RHS.SimdView {
    a.simdView -= b.simdView
}

@inlinable
public func *= <LHS, RHS>(a: inout LHS, b: RHS) where LHS : KvSimdVectorF, RHS : KvSimdVectorF, LHS.SimdView == RHS.SimdView {
    a.simdView *= b.simdView
}

@inlinable
public func /= <LHS, RHS>(a: inout LHS, b: RHS) where LHS : KvSimdVectorF, RHS : KvSimdVectorF, LHS.SimdView == RHS.SimdView {
    a.simdView /= b.simdView
}



// MARK: - KvSimdVector2

/// Protocol for SIMD2 vectors.
public protocol KvSimdVector2 : KvSimdVector {

    var x: Scalar { get set }
    var y: Scalar { get set }


    // MARK: Initialization

    init(_ v0: Scalar, _ v1: Scalar)

    init(x: Scalar, y: Scalar)

}



// MARK: - KvSimdVector2I

/// Protocol for SIMD2 vectors where components conform to *FixedWidthInteger* protocol.
public protocol KvSimdVector2I : KvSimdVector2, KvSimdVectorI {

    init<Other>(_ other: SIMD2<Other>, rounding rule: FloatingPointRoundingRule)
    where Other : BinaryFloatingPoint, Other : SIMDScalar

    init<Other>(clamping other: SIMD2<Other>) where Other : FixedWidthInteger, Other : SIMDScalar

    init<Other>(truncatingIfNeeded other: SIMD2<Other>) where Other : FixedWidthInteger, Other : SIMDScalar

}



// MARK: - KvSimdVector2F

/// Protocol for SIMD2 vectors where components conform to *BinaryFloatingPoint* protocol.
public protocol KvSimdVector2F : KvSimdVector2, KvSimdVectorF {

    init<Other>(_ other: SIMD2<Other>) where Other : BinaryFloatingPoint, Other : SIMDScalar

    init<Other>(_ other: SIMD2<Other>) where Other : FixedWidthInteger, Other : SIMDScalar

}



// MARK: - KvSimdVector3

/// Protocol for SIMD3 vectors.
public protocol KvSimdVector3 : KvSimdVector {

    var x: Scalar { get set }
    var y: Scalar { get set }
    var z: Scalar { get set }


    // MARK: Initialization

    init(_ v0: Scalar, _ v1: Scalar, _ v2: Scalar)

    init(x: Scalar, y: Scalar, z: Scalar)

    init(_ xy: Sample2, _ w: Scalar)

}


extension KvSimdVector3 {

    @inlinable
    public init<V2>(_ xy: V2, _ z: Scalar)
    where V2 : KvSimdVector2, V2.Scalar == Scalar
    {
        self.init(xy.x, xy.y, z)
    }

}



// MARK: - KvSimdVector3I

/// Protocol for SIMD3 vectors where components conform to *FixedWidthInteger* protocol.
public protocol KvSimdVector3I : KvSimdVector3, KvSimdVectorI {

    init<Other>(_ other: SIMD3<Other>, rounding rule: FloatingPointRoundingRule)
    where Other : BinaryFloatingPoint, Other : SIMDScalar

    init<Other>(clamping other: SIMD3<Other>) where Other : FixedWidthInteger, Other : SIMDScalar

    init<Other>(truncatingIfNeeded other: SIMD3<Other>) where Other : FixedWidthInteger, Other : SIMDScalar

}



// MARK: - KvSimdVector3F

/// Protocol for SIMD3 vectors where components conform to *BinaryFloatingPoint* protocol.
public protocol KvSimdVector3F : KvSimdVector3, KvSimdVectorF {

    init<Other>(_ other: SIMD3<Other>) where Other : BinaryFloatingPoint, Other : SIMDScalar

    init<Other>(_ other: SIMD3<Other>) where Other : FixedWidthInteger, Other : SIMDScalar

}



// MARK: - KvSimdVector4

/// Protocol for SIMD4 vectors.
public protocol KvSimdVector4 : KvSimdVector {

    var x: Scalar { get set }
    var y: Scalar { get set }
    var z: Scalar { get set }
    var w: Scalar { get set }

    var lowHalf: Sample2 { get set }
    var highHalf: Sample2 { get set }
    var evenHalf: Sample2 { get set }
    var oddHalf: Sample2 { get set }


    // MARK: Initialization

    init(_ v0: Scalar, _ v1: Scalar, _ v2: Scalar, _ v3: Scalar)

    init(x: Scalar, y: Scalar, z: Scalar, w: Scalar)

    init(lowHalf: Sample2, highHalf: Sample2)

    init(_ xyz: Sample3, _ w: Scalar)

}


extension KvSimdVector4 {

    @inlinable
    public init<LH, RH>(lowHalf: LH, highHalf: RH)
    where LH : KvSimdVector2, LH.Scalar == Scalar, RH : KvSimdVector2, RH.Scalar == Scalar
    {
        self.init(lowHalf.x, lowHalf.y, highHalf.x, highHalf.y)
    }


    @inlinable
    public init<V3>(_ xyz: V3, _ w: Scalar)
    where V3 : KvSimdVector3, V3.Scalar == Scalar
    {
        self.init(xyz.x, xyz.y, xyz.z, w)
    }

}



// MARK: - KvSimdVector4I

/// Protocol for SIMD4 vectors where components conform to *FixedWidthInteger* protocol.
public protocol KvSimdVector4I : KvSimdVector4, KvSimdVectorI {

    init<Other>(_ other: SIMD4<Other>, rounding rule: FloatingPointRoundingRule)
    where Other : BinaryFloatingPoint, Other : SIMDScalar

    init<Other>(clamping other: SIMD4<Other>) where Other : FixedWidthInteger, Other : SIMDScalar

    init<Other>(truncatingIfNeeded other: SIMD4<Other>) where Other : FixedWidthInteger, Other : SIMDScalar

}



// MARK: - KvSimdVector4F

/// Protocol for SIMD4 vectors where components conform to *BinaryFloatingPoint* protocol.
public protocol KvSimdVector4F : KvSimdVector4, KvSimdVectorF {

    init<Other>(_ other: SIMD4<Other>) where Other : BinaryFloatingPoint, Other : SIMDScalar

    init<Other>(_ other: SIMD4<Other>) where Other : FixedWidthInteger, Other : SIMDScalar

}



// MARK: - KvSimdVector8

/// Protocol for SIMD8 vectors.
public protocol KvSimdVector8 : KvSimdVector {

    var lowHalf: Sample4 { get set }
    var highHalf: Sample4 { get set }
    var evenHalf: Sample4 { get set }
    var oddHalf: Sample4 { get set }


    // MARK: Initialization

    init(_ v0: Scalar, _ v1: Scalar, _ v2: Scalar, _ v3: Scalar, _ v4: Scalar, _ v5: Scalar, _ v6: Scalar, _ v7: Scalar)

    init(lowHalf: Sample4, highHalf: Sample4)

}


extension KvSimdVector8 {

    @inlinable
    public init<LH, RH>(lowHalf: LH, highHalf: RH)
    where LH : KvSimdVector4, LH.Scalar == Scalar, RH : KvSimdVector4, RH.Scalar == Scalar
    {
        self.init(lowHalf:   lowHalf[[ 0, 1, 2, 3 ] as simd_long4],
                  highHalf: highHalf[[ 0, 1, 2, 3 ] as simd_long4])
    }

}



// MARK: - KvSimdVector8I

/// Protocol for SIMD8 vectors where components conform to *FixedWidthInteger* protocol.
public protocol KvSimdVector8I : KvSimdVector8, KvSimdVectorI {

    init<Other>(_ other: SIMD8<Other>, rounding rule: FloatingPointRoundingRule)
    where Other : BinaryFloatingPoint, Other : SIMDScalar

    init<Other>(clamping other: SIMD8<Other>) where Other : FixedWidthInteger, Other : SIMDScalar

    init<Other>(truncatingIfNeeded other: SIMD8<Other>) where Other : FixedWidthInteger, Other : SIMDScalar

}



// MARK: - KvSimdVector8F

/// Protocol for SIMD8 vectors where components conform to *BinaryFloatingPoint* protocol.
public protocol KvSimdVector8F : KvSimdVector8, KvSimdVectorF {

    init<Other>(_ other: SIMD8<Other>) where Other : BinaryFloatingPoint, Other : SIMDScalar

    init<Other>(_ other: SIMD8<Other>) where Other : FixedWidthInteger, Other : SIMDScalar

}



// MARK: - KvSimdVector16

/// Protocol for SIMD16 vectors.
public protocol KvSimdVector16 : KvSimdVector {

    var lowHalf: Sample8 { get set }
    var highHalf: Sample8 { get set }
    var evenHalf: Sample8 { get set }
    var oddHalf: Sample8 { get set }


    // MARK: Initialization

    init(_ v0: Scalar, _ v1: Scalar, _ v2: Scalar, _ v3: Scalar, _ v4: Scalar, _ v5: Scalar, _ v6: Scalar, _ v7: Scalar, _ v8: Scalar, _ v9: Scalar, _ v10: Scalar, _ v11: Scalar, _ v12: Scalar, _ v13: Scalar, _ v14: Scalar, _ v15: Scalar)

    init(lowHalf: Sample8, highHalf: Sample8)

}


extension KvSimdVector16 {

    @inlinable
    public init<LH, RH>(lowHalf: LH, highHalf: RH)
    where LH : KvSimdVector8, LH.Scalar == Scalar, RH : KvSimdVector8, RH.Scalar == Scalar
    {
        self.init(lowHalf:   lowHalf[[ 0, 1, 2, 3, 4, 5, 6, 7 ] as simd_int8],
                  highHalf: highHalf[[ 0, 1, 2, 3, 4, 5, 6, 7 ] as simd_int8])
    }

}



// MARK: - KvSimdVector16I

/// Protocol for SIMD16 vectors where components conform to *FixedWidthInteger* protocol.
public protocol KvSimdVector16I : KvSimdVector16, KvSimdVectorI {

    init<Other>(_ other: SIMD16<Other>, rounding rule: FloatingPointRoundingRule)
    where Other : BinaryFloatingPoint, Other : SIMDScalar

    init<Other>(clamping other: SIMD16<Other>) where Other : FixedWidthInteger, Other : SIMDScalar

    init<Other>(truncatingIfNeeded other: SIMD16<Other>) where Other : FixedWidthInteger, Other : SIMDScalar

}



// MARK: - KvSimdVector16F

/// Protocol for SIMD16 vectors where components conform to *BinaryFloatingPoint* protocol.
public protocol KvSimdVector16F : KvSimdVector16, KvSimdVectorF {

    init<Other>(_ other: SIMD16<Other>) where Other : BinaryFloatingPoint, Other : SIMDScalar

    init<Other>(_ other: SIMD16<Other>) where Other : FixedWidthInteger, Other : SIMDScalar

}



// MARK: - KvSimdVector32

/// Protocol for SIMD32 vectors.
public protocol KvSimdVector32 : KvSimdVector {

    var lowHalf: Sample16 { get set }
    var highHalf: Sample16 { get set }
    var evenHalf: Sample16 { get set }
    var oddHalf: Sample16 { get set }


    // MARK: Initialization

    init(_ v0: Scalar, _ v1: Scalar, _ v2: Scalar, _ v3: Scalar, _ v4: Scalar, _ v5: Scalar, _ v6: Scalar, _ v7: Scalar, _ v8: Scalar, _ v9: Scalar, _ v10: Scalar, _ v11: Scalar, _ v12: Scalar, _ v13: Scalar, _ v14: Scalar, _ v15: Scalar, _ v16: Scalar, _ v17: Scalar, _ v18: Scalar, _ v19: Scalar, _ v20: Scalar, _ v21: Scalar, _ v22: Scalar, _ v23: Scalar, _ v24: Scalar, _ v25: Scalar, _ v26: Scalar, _ v27: Scalar, _ v28: Scalar, _ v29: Scalar, _ v30: Scalar, _ v31: Scalar)

    init(lowHalf: Sample16, highHalf: Sample16)

}


extension KvSimdVector32 {

    @inlinable
    public init<LH, RH>(lowHalf: LH, highHalf: RH)
    where LH : KvSimdVector16, LH.Scalar == Scalar, RH : KvSimdVector16, RH.Scalar == Scalar
    {
        self.init(lowHalf:   lowHalf[[ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15 ] as simd_short16],
                  highHalf: highHalf[[ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15 ] as simd_short16])
    }

}



// MARK: - KvSimdVector32I

/// Protocol for SIMD32 vectors where components conform to *FixedWidthInteger* protocol.
public protocol KvSimdVector32I : KvSimdVector32, KvSimdVectorI {

    init<Other>(_ other: SIMD32<Other>, rounding rule: FloatingPointRoundingRule)
    where Other : BinaryFloatingPoint, Other : SIMDScalar

    init<Other>(clamping other: SIMD32<Other>) where Other : FixedWidthInteger, Other : SIMDScalar

    init<Other>(truncatingIfNeeded other: SIMD32<Other>) where Other : FixedWidthInteger, Other : SIMDScalar

}



// MARK: - KvSimdVector32F

/// Protocol for SIMD32 vectors where components conform to *BinaryFloatingPoint* protocol.
public protocol KvSimdVector32F : KvSimdVector32, KvSimdVectorF {

    init<Other>(_ other: SIMD32<Other>) where Other : BinaryFloatingPoint, Other : SIMDScalar

    init<Other>(_ other: SIMD32<Other>) where Other : FixedWidthInteger, Other : SIMDScalar

}



// MARK: - KvSimdVector64

/// Protocol for SIMD64 vectors.
public protocol KvSimdVector64 : KvSimdVector {

    var lowHalf: Sample32 { get set }
    var highHalf: Sample32 { get set }
    var evenHalf: Sample32 { get set }
    var oddHalf: Sample32 { get set }


    // MARK: Initialization

    init(_ v0: Scalar, _ v1: Scalar, _ v2: Scalar, _ v3: Scalar, _ v4: Scalar, _ v5: Scalar, _ v6: Scalar, _ v7: Scalar, _ v8: Scalar, _ v9: Scalar, _ v10: Scalar, _ v11: Scalar, _ v12: Scalar, _ v13: Scalar, _ v14: Scalar, _ v15: Scalar, _ v16: Scalar, _ v17: Scalar, _ v18: Scalar, _ v19: Scalar, _ v20: Scalar, _ v21: Scalar, _ v22: Scalar, _ v23: Scalar, _ v24: Scalar, _ v25: Scalar, _ v26: Scalar, _ v27: Scalar, _ v28: Scalar, _ v29: Scalar, _ v30: Scalar, _ v31: Scalar, _ v32: Scalar, _ v33: Scalar, _ v34: Scalar, _ v35: Scalar, _ v36: Scalar, _ v37: Scalar, _ v38: Scalar, _ v39: Scalar, _ v40: Scalar, _ v41: Scalar, _ v42: Scalar, _ v43: Scalar, _ v44: Scalar, _ v45: Scalar, _ v46: Scalar, _ v47: Scalar, _ v48: Scalar, _ v49: Scalar, _ v50: Scalar, _ v51: Scalar, _ v52: Scalar, _ v53: Scalar, _ v54: Scalar, _ v55: Scalar, _ v56: Scalar, _ v57: Scalar, _ v58: Scalar, _ v59: Scalar, _ v60: Scalar, _ v61: Scalar, _ v62: Scalar, _ v63: Scalar)

    init(lowHalf: Sample32, highHalf: Sample32)

}


extension KvSimdVector64 {

    @inlinable
    public init<LH, RH>(lowHalf: LH, highHalf: RH)
    where LH : KvSimdVector32, LH.Scalar == Scalar, RH : KvSimdVector32, RH.Scalar == Scalar
    {
        self.init(lowHalf:   lowHalf[[ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32 ] as simd_char32],
                  highHalf: highHalf[[ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32 ] as simd_char32])
    }

}



// MARK: - KvSimdVector64I

/// Protocol for SIMD64 vectors where components conform to *FixedWidthInteger* protocol.
public protocol KvSimdVector64I : KvSimdVector64, KvSimdVectorI {

    init<Other>(_ other: SIMD64<Other>, rounding rule: FloatingPointRoundingRule)
    where Other : BinaryFloatingPoint, Other : SIMDScalar

    init<Other>(clamping other: SIMD64<Other>) where Other : FixedWidthInteger, Other : SIMDScalar

    init<Other>(truncatingIfNeeded other: SIMD64<Other>) where Other : FixedWidthInteger, Other : SIMDScalar

}



// MARK: - KvSimdVector64F

/// Protocol for SIMD64 vectors where components conform to *BinaryFloatingPoint* protocol.
public protocol KvSimdVector64F : KvSimdVector64, KvSimdVectorF {

    init<Other>(_ other: SIMD64<Other>) where Other : BinaryFloatingPoint, Other : SIMDScalar

    init<Other>(_ other: SIMD64<Other>) where Other : FixedWidthInteger, Other : SIMDScalar

}



// MARK: - SIMD2

extension SIMD2 : KvSimdVector where Scalar : Comparable {

    public typealias SimdView = SIMD2<Scalar>

    public var simdView: SimdView {
        @inlinable get { self }
        @inlinable set { self = newValue }
    }

    @inlinable
    public init(simdView: SimdView) { self = simdView }

}

extension SIMD2 : KvSimdVector2 where Scalar : Comparable { }

extension SIMD2 : KvSimdVectorI where Scalar : FixedWidthInteger { }

extension SIMD2 : KvSimdVector2I where Scalar : FixedWidthInteger { }

extension SIMD2 : KvSimdVectorF where Scalar : BinaryFloatingPoint { }

extension SIMD2 : KvSimdVector2F where Scalar : BinaryFloatingPoint { }



// MARK: - SIMD3

extension SIMD3 : KvSimdVector where Scalar : Comparable {

    public typealias SimdView = SIMD3<Scalar>

    public var simdView: SimdView {
        @inlinable get { self }
        @inlinable set { self = newValue }
    }

    @inlinable
    public init(simdView: SimdView) { self = simdView }

}

extension SIMD3 : KvSimdVector3 where Scalar : Comparable { }

extension SIMD3 : KvSimdVectorI where Scalar : FixedWidthInteger { }

extension SIMD3 : KvSimdVector3I where Scalar : FixedWidthInteger { }

extension SIMD3 : KvSimdVectorF where Scalar : BinaryFloatingPoint { }

extension SIMD3 : KvSimdVector3F where Scalar : BinaryFloatingPoint { }



// MARK: - SIMD4

extension SIMD4 : KvSimdVector where Scalar : Comparable {

    public typealias SimdView = SIMD4<Scalar>

    public var simdView: SimdView {
        @inlinable get { self }
        @inlinable set { self = newValue }
    }

    @inlinable
    public init(simdView: SimdView) { self = simdView }

}

extension SIMD4 : KvSimdVector4 where Scalar : Comparable { }

extension SIMD4 : KvSimdVectorI where Scalar : FixedWidthInteger { }

extension SIMD4 : KvSimdVector4I where Scalar : FixedWidthInteger { }

extension SIMD4 : KvSimdVectorF where Scalar : BinaryFloatingPoint { }

extension SIMD4 : KvSimdVector4F where Scalar : BinaryFloatingPoint { }



// MARK: - SIMD8

extension SIMD8 : KvSimdVector where Scalar : Comparable {

    public typealias SimdView = SIMD8<Scalar>

    public var simdView: SimdView {
        @inlinable get { self }
        @inlinable set { self = newValue }
    }

    @inlinable
    public init(simdView: SimdView) { self = simdView }

}

extension SIMD8 : KvSimdVector8 where Scalar : Comparable { }

extension SIMD8 : KvSimdVectorI where Scalar : FixedWidthInteger { }

extension SIMD8 : KvSimdVector8I where Scalar : FixedWidthInteger { }

extension SIMD8 : KvSimdVectorF where Scalar : BinaryFloatingPoint { }

extension SIMD8 : KvSimdVector8F where Scalar : BinaryFloatingPoint { }



// MARK: - SIMD16

extension SIMD16 : KvSimdVector where Scalar : Comparable {

    public typealias SimdView = SIMD16<Scalar>

    public var simdView: SimdView {
        @inlinable get { self }
        @inlinable set { self = newValue }
    }

    @inlinable
    public init(simdView: SimdView) { self = simdView }

}

extension SIMD16 : KvSimdVector16 where Scalar : Comparable { }

extension SIMD16 : KvSimdVectorI where Scalar : FixedWidthInteger { }

extension SIMD16 : KvSimdVector16I where Scalar : FixedWidthInteger { }

extension SIMD16 : KvSimdVectorF where Scalar : BinaryFloatingPoint { }

extension SIMD16 : KvSimdVector16F where Scalar : BinaryFloatingPoint { }



// MARK: - SIMD32

extension SIMD32 : KvSimdVector where Scalar : Comparable {

    public typealias SimdView = SIMD32<Scalar>

    public var simdView: SimdView {
        @inlinable get { self }
        @inlinable set { self = newValue }
    }

    @inlinable
    public init(simdView: SimdView) { self = simdView }

}

extension SIMD32 : KvSimdVector32 where Scalar : Comparable { }

extension SIMD32 : KvSimdVectorI where Scalar : FixedWidthInteger { }

extension SIMD32 : KvSimdVector32I where Scalar : FixedWidthInteger { }

extension SIMD32 : KvSimdVectorF where Scalar : BinaryFloatingPoint { }

extension SIMD32 : KvSimdVector32F where Scalar : BinaryFloatingPoint { }



// MARK: - SIMD64

extension SIMD64 : KvSimdVector where Scalar : Comparable {

    public typealias SimdView = SIMD64<Scalar>

    public var simdView: SimdView {
        @inlinable get { self }
        @inlinable set { self = newValue }
    }

    @inlinable
    public init(simdView: SimdView) { self = simdView }

}

extension SIMD64 : KvSimdVector64 where Scalar : Comparable { }

extension SIMD64 : KvSimdVectorI where Scalar : FixedWidthInteger { }

extension SIMD64 : KvSimdVector64I where Scalar : FixedWidthInteger { }

extension SIMD64 : KvSimdVectorF where Scalar : BinaryFloatingPoint { }

extension SIMD64 : KvSimdVector64F where Scalar : BinaryFloatingPoint { }
