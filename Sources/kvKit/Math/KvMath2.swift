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



public enum KvMath2<Scalar> where Scalar : BinaryFloatingPoint & Comparable & SIMDScalar {

    public typealias Vector = SIMD2<Scalar>
    public typealias Position = Vector

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
