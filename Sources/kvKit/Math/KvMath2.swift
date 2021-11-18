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
//  KvMath2.swift
//  kvKit
//
//  Created by Svyatoslav Popov on 04.08.2021.
//

import simd



public typealias KvMathScalar2 = BinaryFloatingPoint & SIMDScalar



public enum KvMath2<Scalar> where Scalar : KvMathScalar2 {

    public typealias Vector = SIMD2<Scalar>
    public typealias Position = Vector

}



// MARK: Martix Operations <Float>

extension KvMath2 where Scalar == Float {

    @inlinable
    public static func abs(_ matrix: simd_float2x2) -> simd_float2x2 {
        .init(simd.abs(matrix[0]), simd.abs(matrix[1]))
    }


    @inlinable
    public static func min(_ matrix: simd_float2x2) -> Scalar {
        Swift.min(matrix[0].min(), matrix[1].min())
    }


    @inlinable
    public static func max(_ matrix: simd_float2x2) -> Scalar {
        Swift.max(matrix[0].max(), matrix[1].max())
    }

}



// MARK: Martix Operations <Double>

extension KvMath2 where Scalar == Double {

    @inlinable
    public static func abs(_ matrix: simd_double2x2) -> simd_double2x2 {
        .init(simd.abs(matrix[0]), simd.abs(matrix[1]))
    }


    @inlinable
    public static func min(_ matrix: simd_double2x2) -> Scalar {
        Swift.min(matrix[0].min(), matrix[1].min())
    }


    @inlinable
    public static func max(_ matrix: simd_double2x2) -> Scalar {
        Swift.max(matrix[0].max(), matrix[1].max())
    }

}



// MARK: .Line

extension KvMath2 {

    public struct Line : Hashable {

        /// Line origin is the closest point to origin of the coordinate space.
        public let origin: Position
        /// A unit vector.
        public let direction: Vector


        @inlinable
        public init?(_ p0: Position, _ p1: Position) {
            self.init(from: p0, in: p1 - p0)
        }


        @inlinable
        public init?(from point: Position, in direction: Vector) {
            guard let direction = normalizedOrNil(direction) else { return nil }

            self.init(origin: point - direction * dot(point, direction), unitDirection: direction)
        }


        @inlinable
        public init(origin: Position, unitDirection: Vector) {
            self.origin = origin
            self.direction = unitDirection
        }


        /// - Returns: A boolean value indicating whether the receiver's direction is on the halfcircle where angle is in (-pi/2, pi/2].
        @inlinable
        public var hasStandardDirection: Bool { direction.x > 0 || (direction.x == 0 && direction.y > 0) }


        /// - Returns: The direction or negated direction so the result is on the halfcircle where angle is in (-pi/2, pi/2].
        @inlinable
        public var standardDirection: Vector { hasStandardDirection ? direction : -direction }


        @inlinable
        public func at(_ offset: Scalar) -> Position { origin + direction * offset }


        /// - Returns: Y coordinate for x coordinate or nil whether the receiver is not vertical.
        @inlinable
        public func y(x: Scalar) -> Scalar? {
            guard KvIsNonzero(direction.x) else { return nil }

            return origin.y - (direction.y / direction.x) * (origin.x - x)
        }

        /// - Returns: X coordinate for y coordinate or nil whether the receiver is not horizontal.
        @inlinable
        public func x(y: Scalar) -> Scalar? {
            guard KvIsNonzero(direction.y) else { return nil }

            return origin.x - (direction.x / direction.y) * (origin.y - y)
        }


        @inlinable
        public func signedDistance(to point: Position) -> Scalar { KvMath2.cross2(point - origin, direction) }

        @inlinable
        public func distance(to point: Position) -> Scalar { Swift.abs(signedDistance(to: point)) }


        @inlinable
        public func projection(for point: Position) -> Position { at(projectionOffset(for: point)) }

        @inlinable
        public func projectionOffset(for point: Position) -> Scalar { KvMath2.dot(point - origin, direction) }


        @inlinable
        public func contains(_ point: Position) -> Bool {
            KvIsZero(signedDistance(to: point))
        }


        /// - Returns: Line equal to the receiver having opposite direction.
        @inlinable
        public var negated: Self { .init(origin: origin, unitDirection: -direction) }

        /// - Returns: Line equal to the receiver having opposite direction.
        @inlinable
        public static prefix func -(line: Self) -> Self { line.negated }



        // MARK: : Equatable

        @inlinable
        public static func ==(lhs: Self, rhs: Self) -> Bool {
            lhs.origin == rhs.origin && lhs.standardDirection == rhs.standardDirection
        }


        // MARK: : Hashable

        @inlinable
        public func hash(into hasher: inout Hasher) {
            hasher.combine(origin)
            hasher.combine(standardDirection)
        }

    }

}



// MARK: .AABR

extension KvMath2 {

    /// Axis-aligned bonding rectangle
    public struct AABR : Hashable {

        public let min, max: Position


        @inlinable
        public init(min: Position, max: Position) {
            assert(min.x <= max.x)
            assert(min.y <= max.y)

            self.min = min
            self.max = max
        }


        @inlinable
        public init(over point: Position) { self.init(min: point, max: point) }


        @inlinable
        public init(over first: Position, _ second: Position, _ rest: Position...) {
            var min = first, max = first

            min = KvMath2.min(min, second)
            max = KvMath2.max(max, second)

            rest.forEach { point in
                min = KvMath2.min(min, point)
                max = KvMath2.max(max, point)
            }

            self.init(min: min, max: max)
        }


        @inlinable
        public init?<Points>(over points: Points) where Points : Sequence, Points.Element == Position {
            var iterator = points.makeIterator()

            guard let first = iterator.next() else { return nil }

            var min = first, max = first

            while let point = iterator.next() {
                min = KvMath2.min(min, point)
                max = KvMath2.max(max, point)
            }

            self.init(min: min, max: max)
        }


        @inlinable
        public static var zero: Self { .init(over: .zero) }


        @inlinable
        public var center: Position { KvMath2.mix(min, max, t: 0.5) }

        @inlinable
        public var size: Vector { max - min }


        @inlinable
        public static var numberOfPoints: Int { 4 }

        @inlinable
        public static var pointIndices: Range<Int> { 0 ..< numberOfPoints }


        @inlinable
        public var pointIndices: Range<Int> { Self.pointIndices }


        @inlinable
        public func point(at index: Int) -> Position {
            .init(x: (index & 1) == 0 ? min.x : max.x,
                  y: (index & 2) == 0 ? min.y : max.y)
        }


        @inlinable
        public func translated(by translation: Vector) -> Self { .init(min: min + translation, max: max + translation) }

    }

}



// MARK: <Float>.AABR

extension KvMath2.AABR where Scalar == Float {

    @inlinable
    public func applying(_ transform: simd_float3x3) -> Self {
        Self(over: Self.pointIndices.lazy.map { index in
            let p3 = transform * .init(point(at: index), 1)

            return .init(p3.x, p3.y) * (1 / p3.z)
        })!
    }

}



// MARK: <Double>.AABR

extension KvMath2.AABR where Scalar == Double {

    @inlinable
    public func applying(_ transform: simd_double3x3) -> Self {
        Self(over: Self.pointIndices.lazy.map { index in
            let p3 = transform * .init(point(at: index), 1)

            return .init(p3.x, p3.y) * (1 / p3.z)
        })!
    }

}



// MARK: Auxiliaries

extension KvMath2 {

    /// - Returns: Normalized vector when source vector has nonzero length. Otherwise *nil* is returned.
    @inlinable
    public static func normalizedOrNil(_ vector: Vector) -> Vector? {
        let l² = length_squared(vector)

        guard KvIsNonzero(l²) else { return nil }

        return KvIs(l², inequalTo: 1) ? (vector / sqrt(l²)) : vector
    }


    /// - Returns: ((x, 0)  × (y, 0)).z
    ///
    /// - Note: It's helpful to find sine of angle between two unit vectors.
    @inlinable
    public static func cross2(_ x: Vector, _ y: Vector) -> Scalar { x.x * y.y - x.y * y.x }

}



// MARK: Generalization of SIMD

extension KvMath2 {

    @inlinable public static func abs(_ v: Vector) -> Vector { .init(Swift.abs(v.x), Swift.abs(v.y)) }

    @inlinable public static func clamp(_ x: Scalar, _ min: Scalar, _ max: Scalar) -> Scalar { Swift.max(min, Swift.min(max, x)) }

    @inlinable public static func clamp(_ v: Vector, _ min: Vector, _ max: Vector) -> Vector {
        Vector(x: KvMath3.clamp(v.x, min.x, max.x),
               y: KvMath3.clamp(v.y, min.y, max.y))
    }

    @inlinable public static func distance(_ x: Vector, _ y: Vector) -> Scalar { length(y - x) }

    @inlinable public static func dot(_ x: Vector, _ y: Vector) -> Scalar { x.x * y.x + x.y * y.y }

    @inlinable public static func length(_ v: Vector) -> Scalar { sqrt(dot(v, v)) }

    @inlinable public static func length_squared(_ v: Vector) -> Scalar { dot(v, v) }

    @inlinable public static func max(_ x: Vector, _ y: Vector) -> Vector {
        Vector(x: Swift.max(x.x, y.x),
               y: Swift.max(x.y, y.y))
    }

    @inlinable public static func min(_ x: Vector, _ y: Vector) -> Vector {
        Vector(x: Swift.min(x.x, y.x),
               y: Swift.min(x.y, y.y))
    }

    @inlinable public static func mix(_ x: Vector, _ y: Vector, t: Scalar) -> Vector {
        let oneMinusT = 1 - t

        return Vector(x: x.x * oneMinusT + y.x * t,
                      y: x.y * oneMinusT + y.y * t)
    }

}



// MARK: SIMD where Scalar == Float

extension KvMath2 where Scalar == Float {

    @inlinable public static func abs(_ v: Vector) -> Vector { simd.abs(v) }

    @inlinable public static func clamp(_ x: Scalar, _ min: Scalar, _ max: Scalar) -> Scalar { simd_clamp(x, min, max) }

    @inlinable public static func clamp(_ v: Vector, _ min: Vector, _ max: Vector) -> Vector { simd_clamp(v, min, max) }

    @inlinable public static func distance(_ x: Vector, _ y: Vector) -> Scalar { simd.distance(x, y) }

    @inlinable public static func dot(_ x: Vector, _ y: Vector) -> Scalar { simd.dot(x, y) }

    @inlinable public static func length(_ v: Vector) -> Scalar { simd.length(v) }

    @inlinable public static func length_squared(_ v: Vector) -> Scalar { simd.length_squared(v) }

    @inlinable public static func max(_ x: Vector, _ y: Vector) -> Vector { simd_max(x, y) }

    @inlinable public static func min(_ x: Vector, _ y: Vector) -> Vector { simd_min(x, y) }

    @inlinable public static func mix(_ x: Vector, _ y: Vector, t: Scalar) -> Vector { simd.mix(x, y, t: t) }

}



// MARK: SIMD where Scalar == Double

extension KvMath2 where Scalar == Double {

    @inlinable public static func abs(_ v: Vector) -> Vector { simd.abs(v) }

    @inlinable public static func clamp(_ x: Scalar, _ min: Scalar, _ max: Scalar) -> Scalar { simd_clamp(x, min, max) }

    @inlinable public static func clamp(_ v: Vector, _ min: Vector, _ max: Vector) -> Vector { simd_clamp(v, min, max) }

    @inlinable public static func distance(_ x: Vector, _ y: Vector) -> Scalar { simd.distance(x, y) }

    @inlinable public static func dot(_ x: Vector, _ y: Vector) -> Scalar { simd.dot(x, y) }

    @inlinable public static func length(_ v: Vector) -> Scalar { simd.length(v) }

    @inlinable public static func length_squared(_ v: Vector) -> Scalar { simd.length_squared(v) }

    @inlinable public static func max(_ x: Vector, _ y: Vector) -> Vector { simd_max(x, y) }

    @inlinable public static func min(_ x: Vector, _ y: Vector) -> Vector { simd_min(x, y) }

    @inlinable public static func mix(_ x: Vector, _ y: Vector, t: Scalar) -> Vector { simd.mix(x, y, t: t) }

}



// MARK: - Vector Comparisons

@inlinable
public func KvIs<Scalar>(_ lhs: KvMath2<Scalar>.Vector, equalTo rhs: KvMath2<Scalar>.Vector) -> Bool
where Scalar : KvMathScalar2
{
    KvIsZero(KvMath2.abs(lhs - rhs).max())
}


@inlinable
public func KvIs<Scalar>(_ lhs: KvMath2<Scalar>.Vector, inequalTo rhs: KvMath2<Scalar>.Vector) -> Bool
where Scalar : KvMathScalar3
{
    KvIsNonzero(KvMath2.abs(lhs - rhs).max())
}



// MARK: - Matrix Comparisons

@inlinable
public func KvIs(_ lhs: simd_float2x2, equalTo rhs: simd_float2x2) -> Bool {
    KvIsZero(KvMath2.max(KvMath2.abs(lhs - rhs)))
}


@inlinable
public func KvIs(_ lhs: simd_double2x2, equalTo rhs: simd_double2x2) -> Bool {
    KvIsZero(KvMath2.max(KvMath2.abs(lhs - rhs)))
}


@inlinable
public func KvIs(_ lhs: simd_float2x2, inequalTo rhs: simd_float2x2) -> Bool {
    KvIsNonzero(KvMath2.max(KvMath2.abs(lhs - rhs)))
}


@inlinable
public func KvIs(_ lhs: simd_double2x2, inequalTo rhs: simd_double2x2) -> Bool {
    KvIsNonzero(KvMath2.max(KvMath2.abs(lhs - rhs)))
}



// MARK: - Line Comparisons

@inlinable
public func KvIs<Scalar>(_ lhs: KvMath2<Scalar>.Line, equalTo rhs: KvMath2<Scalar>.Line) -> Bool
where Scalar : KvMathScalar2
{
    lhs.contains(rhs.origin) && KvIs(lhs.standardDirection, equalTo: rhs.standardDirection)
}


@inlinable
public func KvIs<Scalar>(_ lhs: KvMath2<Scalar>.Line, inequalTo rhs: KvMath2<Scalar>.Line) -> Bool
where Scalar : KvMathScalar2
{
    !lhs.contains(rhs.origin) || KvIs(lhs.standardDirection, inequalTo: rhs.standardDirection)
}



// MARK: - AABR Comparisons

@inlinable
public func KvIs<Scalar>(_ lhs: KvMath2<Scalar>.AABR, equalTo rhs: KvMath2<Scalar>.AABR) -> Bool
where Scalar : KvMathScalar2
{
    KvIs(lhs.min, equalTo: rhs.min) && KvIs(lhs.max, equalTo: rhs.max)
}


@inlinable
public func KvIs<Scalar>(_ lhs: KvMath2<Scalar>.AABR, inequalTo rhs: KvMath2<Scalar>.AABR) -> Bool
where Scalar : KvMathScalar2
{
    KvIs(lhs.min, inequalTo: rhs.min) || KvIs(lhs.max, inequalTo: rhs.max)
}
