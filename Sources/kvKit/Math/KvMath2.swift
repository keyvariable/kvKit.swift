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



public enum KvMath2<Scalar> where Scalar : KvMathFloatingPoint {

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



// MARK: Transformations <Float>

extension KvMath2 where Scalar == Float {

    @inlinable
    public static func apply(_ matrix: simd_float3x3, toPosition position: Position) -> Position {
        let p3 = matrix * simd_make_float3(position, 1)

        return simd_make_float2(p3) / p3.z
    }

    @inlinable
    public static func apply(_ matrix: simd_float3x3, toVector vector: Vector) -> Vector {
        simd_make_float2(matrix * simd_make_float3(vector))
    }



    @inlinable
    public static func translationMatrix(by translation: Vector) -> simd_float3x3 {
        simd_matrix([ 1, 0, 0 ], [ 0, 1, 0 ], simd_make_float3(translation, 1))
    }

    @inlinable
    public static func translation(from matrix: simd_float3x3) -> Vector {
        let c3 = matrix[2]

        return simd_make_float2(c3) / c3.z
    }

    @inlinable
    public static func setTranslation(_ translation: Vector, to matrix: inout simd_float3x3) {
        let z = matrix[2, 2]

        matrix[2] = simd_make_float3(translation * z, z)
    }



    /// - Returns: Scale component from given 2×2 matrix.
    @inlinable
    public static func scale(from matrix: simd_float2x2) -> Vector {
        .init(x: simd.length(matrix[0]) * (KvIsNotNegative(simd_determinant(matrix)) ? 1 : -1),
              y: simd.length(matrix[1]))
    }

    /// - Returns: Sqaured scale component from given 2×2 matrix.
    @inlinable
    public static func scale²(from matrix: simd_float2x2) -> Vector {
        .init(x: simd.length_squared(matrix[0]),
              y: simd.length_squared(matrix[1]))
    }

    /// Changes scale component of given 2×2 matrix to given value. If a column is zero then the result is undefined.
    @inlinable
    public static func setScale(_ scale: Vector, to matrix: inout simd_float2x2) {
        let s = scale * rsqrt(self.scale²(from: matrix))

        matrix[0] *= s.x * (KvIsNotNegative(simd_determinant(matrix)) ? 1 : -1)
        matrix[1] *= s.y
    }



    /// - Returns: Scale component from given 3×3 projective matrix having row[2] == [ 0, 0, 1 ].
    @inlinable
    public static func scale(from matrix: simd_float3x3) -> Vector {
        .init(x: simd.length(matrix[0]) * (KvIsNotNegative(simd_determinant(matrix)) ? 1 : -1),
              y: simd.length(matrix[1]))
    }

    /// - Returns: Sqared scale component from given 3×3 projective matrix having row[2] == [ 0, 0, 1 ].
    @inlinable
    public static func scale²(from matrix: simd_float3x3) -> Vector {
        .init(x: simd.length_squared(matrix[0]),
              y: simd.length_squared(matrix[1]))
    }

    /// Changes scale component of given projective 3×3 matrix having row[2] == [ 0, 0, 1 ]. If a column is zero then the result is undefined.
    @inlinable
    public static func setScale(_ scale: Vector, to matrix: inout simd_float3x3) {
        let s = scale * rsqrt(self.scale²(from: matrix))

        // OK due to matrix[0].z == 0
        matrix[0] *= simd_make_float3(s.x, s.x, 1) * (KvIsNotNegative(simd_determinant(matrix)) ? 1 : -1)
        matrix[1] *= simd_make_float3(s.y, s.y, 1)
    }



    /// - Returns: Transformation translating by -*position*, then applying *transform*, then translating by *position*.
    @inlinable
    public static func transformation(_ transform: simd_float2x2, relativeTo position: Vector) -> simd_float3x3 {
        simd_matrix(simd_make_float3(transform[0]),
                    simd_make_float3(transform[1]),
                    simd_make_float3(position - transform * position, 1))
    }



    /// - Returns: Transformed X basis vector.
    @inlinable
    public static func basisX(from matrix: simd_float3x3) -> Vector {
        simd_make_float2(matrix[0])
    }

    /// - Returns: Transformed Y basis vector.
    @inlinable
    public static func basisY(from matrix: simd_float3x3) -> Vector {
        simd_make_float2(matrix[1])
    }

}



// MARK: Transformations <Double>

extension KvMath2 where Scalar == Double {

    @inlinable
    public static func apply(_ matrix: simd_double3x3, toPosition position: Position) -> Position {
        let p3 = matrix * simd_make_double3(position, 1)

        return simd_make_double2(p3) / p3.z
    }

    @inlinable
    public static func apply(_ matrix: simd_double3x3, toVector vector: Vector) -> Vector {
        simd_make_double2(matrix * simd_make_double3(vector))
    }



    @inlinable
    public static func translationMatrix(by translation: Vector) -> simd_double3x3 {
        simd_matrix([ 1, 0, 0 ], [ 0, 1, 0 ], simd_make_double3(translation, 1))
    }

    @inlinable
    public static func translation(from matrix: simd_double3x3) -> Vector {
        let c3 = matrix[2]

        return simd_make_double2(c3) / c3.z
    }

    @inlinable
    public static func setTranslation(_ translation: Vector, to matrix: inout simd_double3x3) {
        let z = matrix[2, 2]

        matrix[2] = simd_make_double3(translation * z, z)
    }



    /// - Returns: Scale component from given 2×2 matrix.
    @inlinable
    public static func scale(from matrix: simd_double2x2) -> Vector {
        .init(x: simd.length(matrix[0]) * (KvIsNotNegative(simd_determinant(matrix)) ? 1 : -1),
              y: simd.length(matrix[1]))
    }

    /// - Returns: Sqaured scale component from given 2×2 matrix.
    @inlinable
    public static func scale²(from matrix: simd_double2x2) -> Vector {
        .init(x: simd.length_squared(matrix[0]),
              y: simd.length_squared(matrix[1]))
    }

    /// Changes scale component of given 2×2 matrix to given value. If a column is zero then the result is undefined.
    @inlinable
    public static func setScale(_ scale: Vector, to matrix: inout simd_double2x2) {
        let s = scale * rsqrt(self.scale²(from: matrix))

        matrix[0] *= s.x * (KvIsNotNegative(simd_determinant(matrix)) ? 1 : -1)
        matrix[1] *= s.y
    }



    /// - Returns: Scale component from given 3×3 projective matrix having row[2] == [ 0, 0, 1 ].
    @inlinable
    public static func scale(from matrix: simd_double3x3) -> Vector {
        .init(x: simd.length(matrix[0]) * (KvIsNotNegative(simd_determinant(matrix)) ? 1 : -1),
              y: simd.length(matrix[1]))
    }

    /// - Returns: Sqared scale component from given 3×3 projective matrix having row[2] == [ 0, 0, 1 ].
    @inlinable
    public static func scale²(from matrix: simd_double3x3) -> Vector {
        .init(x: simd.length_squared(matrix[0]),
              y: simd.length_squared(matrix[1]))
    }

    /// Changes scale component of given projective 3×3 matrix having row[2] == [ 0, 0, 1 ]. If a column is zero then the result is undefined.
    @inlinable
    public static func setScale(_ scale: Vector, to matrix: inout simd_double3x3) {
        let s = scale * rsqrt(self.scale²(from: matrix))

        // OK due to matrix[0].z == 0
        matrix[0] *= simd_make_double3(s.x, s.x, 1) * (KvIsNotNegative(simd_determinant(matrix)) ? 1 : -1)
        matrix[1] *= simd_make_double3(s.y, s.y, 1)
    }



    /// - Returns: Transformation translating by -*position*, then applying *transform*, then translating by *position*.
    @inlinable
    public static func transformation(_ transform: simd_double2x2, relativeTo position: Vector) -> simd_double3x3 {
        simd_matrix(simd_make_double3(transform[0]),
                    simd_make_double3(transform[1]),
                    simd_make_double3(position - transform * position, 1))
    }



    /// - Returns: Transformed X basis vector.
    @inlinable
    public static func basisX(from matrix: simd_double3x3) -> Vector {
        simd_make_double2(matrix[0])
    }

    /// - Returns: Transformed Y basis vector.
    @inlinable
    public static func basisY(from matrix: simd_double3x3) -> Vector {
        simd_make_double2(matrix[1])
    }

}



// MARK: .Line

extension KvMath2 {

    public struct Line : Hashable {

        /// Line origin is the closest point to origin of the coordinate space.
        public let origin: Position
        /// A unit vector.
        public let direction: Vector


        /// Initializes a line by two points.
        @inlinable
        public init?(_ p0: Position, _ p1: Position) {
            self.init(from: p0, in: p1 - p0)
        }


        /// Initializes a line having given *direction* and containg given *point*.
        @inlinable
        public init?(from point: Position, in direction: Vector) {
            guard let direction = normalizedOrNil(direction) else { return nil }

            self.init(from: point, unitDirection: direction)
        }


        /// Initializes a line having given direction vector and containg given *point*.
        ///
        /// - Parameter unitDirection: A unit vector.
        ///
        /// - Warning: There is no validation of arguments in performance reasons.
        @inlinable
        public init(from point: KvMath2.Position, unitDirection: KvMath2.Vector) {
            self.init(origin: point - unitDirection * KvMath2.dot(point, unitDirection), unitDirection: unitDirection)
        }


        /// Initializes a line having given direction vector and origin point.
        ///
        /// - Parameter origin: The closest point to origin of the coordinate space.
        /// - Parameter unitDirection: A unit vector.
        ///
        /// - Warning: There is no validation of arguments in performance reasons.
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
        public func signedDistance(to point: Position) -> Scalar { KvMath2.cross2(direction, point - origin) }

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
            KvMath2.apply(transform, toPosition: point(at: index))
        })!
    }

}



// MARK: <Double>.AABR

extension KvMath2.AABR where Scalar == Double {

    @inlinable
    public func applying(_ transform: simd_double3x3) -> Self {
        Self(over: Self.pointIndices.lazy.map { index in
            KvMath2.apply(transform, toPosition: point(at: index))
        })!
    }

}



// MARK: .Convex

extension KvMath2 {

    /// Simple implementation of convex shape equal to intersections of left halfspaces produced by given oriented lines.
    public struct Convex {

        public let lines: [Line]


        /// - Parameter points: Convex shape vertices in counterclockwise order.
        @inlinable
        public init?(_ points: [Position]) {
            guard points.count >= 3 else {
                KvDebug.pause("\(points.count) points not enough to make a convex shape")
                return nil
            }

            var iterator = points.makeIterator()

            let first = iterator.next()!
            var last: (line: Line, point: Position)

            do {
                let second = iterator.next()!

                guard let line = Line(first, second) else {
                    KvDebug.pause("Unable to make a line for points \(first) and \(second)")
                    return nil
                }

                last = (line, second)
            }

            var lines = [ last.line ]


            func Process(_ point: Position) -> Bool {
                guard let line = Line(last.point, point)
                else { return KvDebug.pause(code: false, "Unable to make a line for points \(last.point) and \(point)") }

                guard KvIsPositive(KvMath2.cross2(last.line.direction, line.direction))
                else { return KvDebug.pause(code: false, "\(point) point breaks CCW order") }

                lines.append(line)
                last = (line, point)

                return true
            }


            while let next = iterator.next() {
                guard Process(next) else { return nil }
            }
            guard Process(first) else { return nil }

            self.lines = lines
        }


        /// - Parameter points: Convex shape vertices in counterclockwise order.
        @inlinable
        public init?(_ points: Position...) { self.init(points) }


        /// - Note: Points have to be in counter-clockwise order.
        @inlinable
        public init?(p1: Position, p2: Position, p3: Position) {
            guard let line1 = Line(p1, p2) else { return nil }

            var isNegative = false

            if KvIsPositive(line1.signedDistance(to: p3), alsoIsNegative: &isNegative) {
                lines = [ line1, .init(p2, p3)!, .init(p3, p1)! ]
            }
            else if isNegative {
                lines = [ -line1, .init(p1, p3)!, .init(p3, p2)! ]
            }
            else { return nil }
        }


        // MARK: Operations

        /// - Returns: Range of X-coordinates inside the receiver at given Y-coordinate.
        @inlinable
        public func segment(y: Scalar) -> ClosedRange<Scalar>? {
            var lowerBound: Scalar = -.infinity
            var upperBound: Scalar = .infinity

            var iterator = lines.makeIterator()

            while let line = iterator.next() {
                switch line.x(y: y) {
                case .some(let x):
                    // If line intersects with horizontal then it isn't horizontal.
                    line.direction.y > 0
                    ? (upperBound = Swift.min(upperBound, x))
                    : (lowerBound = Swift.max(lowerBound, x))

                case .none:
                    // line.direction.x = ±1
                    guard line.direction.x > 0 ? KvIs(y, greaterThanOrEqualTo: line.origin.y) : KvIs(y, lessThanOrEqualTo: line.origin.y)
                    else { return nil }
                }
            }

            return upperBound >= lowerBound ? lowerBound ... upperBound : nil
        }

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
    public static func cross2(_ lhs: Vector, _ rhs: Vector) -> Scalar { lhs.x * rhs.y - lhs.y * rhs.x }

}



// MARK: Generalization of SIMD

extension KvMath2 {

    @inlinable public static func abs(_ v: Vector) -> Vector { .init(Swift.abs(v.x), Swift.abs(v.y)) }

    @inlinable public static func clamp(_ v: Vector, _ min: Vector, _ max: Vector) -> Vector {
        Vector(x: KvMath.clamp(v.x, min.x, max.x),
               y: KvMath.clamp(v.y, min.y, max.y))
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

    @inlinable public static func normalize(_ v: Vector) -> Vector { v / sqrt(length_squared(v)) }

}



// MARK: SIMD where Scalar == Float

extension KvMath2 where Scalar == Float {

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

extension KvMath2 where Scalar == Double {

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



// MARK: - Vector Comparisons

@inlinable
public func KvIs<Scalar>(_ lhs: KvMath2<Scalar>.Vector, equalTo rhs: KvMath2<Scalar>.Vector) -> Bool
where Scalar : KvMathFloatingPoint
{
    KvIsZero(KvMath2.abs(lhs - rhs).max())
}


@inlinable
public func KvIs<Scalar>(_ lhs: KvMath2<Scalar>.Vector, inequalTo rhs: KvMath2<Scalar>.Vector) -> Bool
where Scalar : KvMathFloatingPoint
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
where Scalar : KvMathFloatingPoint
{
    lhs.contains(rhs.origin) && KvIs(lhs.standardDirection, equalTo: rhs.standardDirection)
}


@inlinable
public func KvIs<Scalar>(_ lhs: KvMath2<Scalar>.Line, inequalTo rhs: KvMath2<Scalar>.Line) -> Bool
where Scalar : KvMathFloatingPoint
{
    !lhs.contains(rhs.origin) || KvIs(lhs.standardDirection, inequalTo: rhs.standardDirection)
}



// MARK: - AABR Comparisons

@inlinable
public func KvIs<Scalar>(_ lhs: KvMath2<Scalar>.AABR, equalTo rhs: KvMath2<Scalar>.AABR) -> Bool
where Scalar : KvMathFloatingPoint
{
    KvIs(lhs.min, equalTo: rhs.min) && KvIs(lhs.max, equalTo: rhs.max)
}


@inlinable
public func KvIs<Scalar>(_ lhs: KvMath2<Scalar>.AABR, inequalTo rhs: KvMath2<Scalar>.AABR) -> Bool
where Scalar : KvMathFloatingPoint
{
    KvIs(lhs.min, inequalTo: rhs.min) || KvIs(lhs.max, inequalTo: rhs.max)
}



// MARK: - Legacy

@available(*, deprecated, renamed: "KvMathFloatingPoint")
public typealias KvMathScalar2 = KvMathFloatingPoint


extension KvMath2 {

    @available(*, deprecated, renamed: "BConvex")
    public typealias Convex = BConvex


    @available(*, deprecated, message: "Use KvMath.clamp()")
    @inlinable public static func clamp(_ x: Scalar, _ min: Scalar, _ max: Scalar) -> Scalar { Swift.max(min, Swift.min(max, x)) }

}


extension KvMath2 where Scalar == Float {

    @available(*, deprecated, message: "Use KvMath.clamp()")
    @inlinable public static func clamp(_ x: Scalar, _ min: Scalar, _ max: Scalar) -> Scalar { simd_clamp(x, min, max) }

}


extension KvMath2 where Scalar == Double {

    @available(*, deprecated, message: "Use KvMath.clamp()")
    @inlinable public static func clamp(_ x: Scalar, _ min: Scalar, _ max: Scalar) -> Scalar { simd_clamp(x, min, max) }

}
