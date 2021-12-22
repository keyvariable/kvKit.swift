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
//  KvMath3.swift
//  kvKit
//
//  Created by Svyatoslav Popov on 20.04.2021.
//

import simd



public typealias KvMathScalar3 = BinaryFloatingPoint & SIMDScalar



public enum KvMath3<Scalar> where Scalar : KvMathScalar3 {

    public typealias Scalar = Scalar

    public typealias Vector = SIMD3<Scalar>
    public typealias Position = Vector

}



// MARK: Matrix Fabrics <Float>

extension KvMath3 where Scalar == Float {

    /// - Returns: Result of replacement if the left top submatix of identity matrix with given matrix.
    @inlinable
    public static func supplemented(_ base: simd_float2x2) -> simd_float3x3 {
        .init(Vector(base[0], 0), Vector(base[1], 0), [ 0, 0, 1 ])
    }

    /// - Returns: Result of replacement if the left top submatix of identity matrix with given matrix.
    @inlinable
    public static func supplemented(_ base: simd_float2x3) -> simd_float3x3 {
        .init(base[0], base[1], [ 0, 0, 1 ])
    }

    /// - Returns: Result of replacement if the left top submatix of identity matrix with given matrix.
    @inlinable
    public static func supplemented(_ base: simd_float3x2) -> simd_float3x3 {
        .init(Vector(base[0], 0), Vector(base[1], 0), Vector(base[2], 1))
    }

}



// MARK: Matrix Fabrics <Float>

extension KvMath3 where Scalar == Double {

    /// - Returns: Result of replacement if the left top submatix of identity matrix with given matrix.
    @inlinable
    public static func supplemented(_ base: simd_double2x2) -> simd_double3x3 {
        .init(Vector(base[0], 0), Vector(base[1], 0), [ 0, 0, 1 ])
    }

    /// - Returns: Result of replacement if the left top submatix of identity matrix with given matrix.
    @inlinable
    public static func supplemented(_ base: simd_double2x3) -> simd_double3x3 {
        .init(base[0], base[1], [ 0, 0, 1 ])
    }

    /// - Returns: Result of replacement if the left top submatix of identity matrix with given matrix.
    @inlinable
    public static func supplemented(_ base: simd_double3x2) -> simd_double3x3 {
        .init(Vector(base[0], 0), Vector(base[1], 0), Vector(base[2], 1))
    }

}



// MARK: Martix Operations <Float>

extension KvMath3 where Scalar == Float {

    @inlinable
    public static func abs(_ matrix: simd_float3x3) -> simd_float3x3 {
        .init(simd.abs(matrix[0]), simd.abs(matrix[1]), simd.abs(matrix[2]))
    }


    @inlinable
    public static func min(_ matrix: simd_float3x3) -> Scalar {
        Swift.min(matrix[0].min(), matrix[1].min(), matrix[2].min())
    }


    @inlinable
    public static func max(_ matrix: simd_float3x3) -> Scalar {
        Swift.max(matrix[0].max(), matrix[1].max(), matrix[2].max())
    }

}



// MARK: Martix Operations <Double>

extension KvMath3 where Scalar == Double {

    @inlinable
    public static func abs(_ matrix: simd_double3x3) -> simd_double3x3 {
        .init(simd.abs(matrix[0]), simd.abs(matrix[1]), simd.abs(matrix[2]))
    }


    @inlinable
    public static func min(_ matrix: simd_double3x3) -> Scalar {
        Swift.min(matrix[0].min(), matrix[1].min(), matrix[2].min())
    }


    @inlinable
    public static func max(_ matrix: simd_double3x3) -> Scalar {
        Swift.max(matrix[0].max(), matrix[1].max(), matrix[2].max())
    }

}



// MARK: Transformations <Float>

extension KvMath3 where Scalar == Float {

    @inlinable
    public static func apply(_ matrix: simd_float4x4, toPosition position: Position) -> Position {
        let p4 = matrix * simd_make_float4(position, 1)

        return simd_make_float3(p4) / p4.w
    }

    @inlinable
    public static func apply(_ matrix: simd_float4x4, toVector vector: Vector) -> Vector {
        simd_make_float3(matrix * simd_make_float4(vector))
    }



    @inlinable
    public static func translationMatrix(by translation: Vector) -> simd_float4x4 {
        simd_matrix([ 1, 0, 0, 0 ], [ 0, 1, 0, 0 ], [ 0, 0, 1, 0], simd_make_float4(translation, 1))
    }

    @inlinable
    public static func translation(from matrix: simd_float4x4) -> Vector {
        let c4 = matrix[3]

        return simd_make_float3(c4) / c4.w
    }

    @inlinable
    public static func setTranslation(_ translation: Vector, to matrix: inout simd_float4x4) {
        let w = matrix[3, 3]

        matrix[3] = simd_make_float4(translation * w, w)
    }



    @inlinable
    public static func scale(from matrix: simd_float4x4) -> Vector {
        // Assuming .w == 0 for columns 0...2
        .init(x: simd.length(matrix[0]),
              y: simd.length(matrix[1]),
              z: simd.length(matrix[2]))
    }

    @inlinable
    public static func scale²(from matrix: simd_float4x4) -> Vector {
        .init(x: simd.length_squared(matrix[0]),
              y: simd.length_squared(matrix[1]),
              z: simd.length_squared(matrix[2]))
    }

    @inlinable
    public static func setScale(_ scale: Vector, to matrix: inout simd_float4x4) {
        let s = scale * rsqrt(self.scale²(from: matrix))

        matrix[0] *= simd_make_float4(s.x, s.x, s.x, 1)
        matrix[1] *= simd_make_float4(s.y, s.y, s.y, 1)
        matrix[2] *= simd_make_float4(s.z, s.z, s.z, 1)
    }



    /// - Returns: Transformation translating by -*position*, then applying *transform*, then translating by *position*.
    @inlinable
    public static func transformation(_ transform: simd_float3x3, relativeTo position: Vector) -> simd_float4x4 {
        simd_matrix(simd_make_float4(transform[0]),
                    simd_make_float4(transform[1]),
                    simd_make_float4(transform[2]),
                    simd_make_float4(position - transform * position, 1))
    }



    /// - Returns: Transformed X basis vector.
    @inlinable
    public static func basisX(from matrix: simd_float4x4) -> Vector {
        simd_make_float3(matrix[0])
    }

    /// - Returns: Transformed Y basis vector.
    @inlinable
    public static func basisY(from matrix: simd_float4x4) -> Vector {
        simd_make_float3(matrix[1])
    }

    /// - Returns: Transformed Z basis vector.
    @inlinable
    public static func basisZ(from matrix: simd_float4x4) -> Vector {
        simd_make_float3(matrix[2])
    }

}



// MARK: Transformations <Double>

extension KvMath3 where Scalar == Double {

    @inlinable
    public static func apply(_ matrix: simd_double4x4, toPosition position: Position) -> Position {
        let p4 = matrix * simd_make_double4(position, 1)

        return simd_make_double3(p4) / p4.w
    }

    @inlinable
    public static func apply(_ matrix: simd_double4x4, toVector vector: Vector) -> Vector {
        simd_make_double3(matrix * simd_make_double4(vector))
    }



    @inlinable
    public static func translationMatrix(by translation: Vector) -> simd_double4x4 {
        simd_matrix([ 1, 0, 0, 0 ], [ 0, 1, 0, 0 ], [ 0, 0, 1, 0], simd_make_double4(translation, 1))
    }

    @inlinable
    public static func translation(from matrix: simd_double4x4) -> Vector {
        let c4 = matrix[3]

        return simd_make_double3(c4) / c4.w
    }

    @inlinable
    public static func setTranslation(_ translation: Vector, to matrix: inout simd_double4x4) {
        let w = matrix[3, 3]

        matrix[3] = simd_make_double4(translation * w, w)
    }



    @inlinable
    public static func scale(from matrix: simd_double4x4) -> Vector {
        // Assuming .w == 0 for columns 0...2
        .init(x: simd.length(matrix[0]),
              y: simd.length(matrix[1]),
              z: simd.length(matrix[2]))
    }

    @inlinable
    public static func scale²(from matrix: simd_double4x4) -> Vector {
        .init(x: simd.length_squared(matrix[0]),
              y: simd.length_squared(matrix[1]),
              z: simd.length_squared(matrix[2]))
    }

    @inlinable
    public static func setScale(_ scale: Vector, to matrix: inout simd_double4x4) {
        let s = scale * rsqrt(self.scale²(from: matrix))

        matrix[0] *= simd_make_double4(s.x, s.x, s.x, 1)
        matrix[1] *= simd_make_double4(s.y, s.y, s.y, 1)
        matrix[2] *= simd_make_double4(s.z, s.z, s.z, 1)
    }



    /// - Returns: Transformation translating by -*position*, then applying *transform*, then translating by *position*.
    @inlinable
    public static func transformation(_ matrix: simd_double3x3, relativeTo position: Vector) -> simd_double4x4 {
        simd_matrix(simd_make_double4(matrix[0]),
                    simd_make_double4(matrix[1]),
                    simd_make_double4(matrix[2]),
                    simd_make_double4(position - matrix * position, 1))
    }



    /// - Returns: Transformed X basis vector.
    @inlinable
    public static func basisX(from matrix: simd_double4x4) -> Vector {
        simd_make_double3(matrix[0])
    }

    /// - Returns: Transformed Y basis vector.
    @inlinable
    public static func basisY(from matrix: simd_double4x4) -> Vector {
        simd_make_double3(matrix[1])
    }

    /// - Returns: Transformed Z basis vector.
    @inlinable
    public static func basisZ(from matrix: simd_double4x4) -> Vector {
        simd_make_double3(matrix[2])
    }

}



// MARK: Projections <Float>

extension KvMath3 where Scalar == Float {

    /// - Returns: Matrix of standard orthogonal projection.
    @inlinable
    public static func orthogonalProjection(left: Scalar, right: Scalar, top: Scalar, bottom: Scalar, near: Scalar, far: Scalar) -> simd_float4x4 {
        // - Note: Single SIMD division seems faster.
        simd_float4x4(diagonal: .one / simd_float4(left - right, bottom - top, near - far, 1))
        * simd_float4x4([ -2,  0, 0, 0 ],
                        [  0, -2, 0, 0 ],
                        [  0,  0, 2, 0 ],
                        .init(right + left, top + bottom, far + near, 1))
    }


    /// - Parameter aspect: Ratio of Viewport width to viewport height.
    /// - Parameter fof: Vertical camera angle.
    ///
    /// - Returns: Projection matrix for a centered rectangular pinhole camera.
    @inlinable
    public static func perspectiveProjection(aspect: Scalar, fov: Scalar, near: Scalar, far: Scalar) -> simd_float4x4 {
        let tg = tan(0.5 * fov)

        // - Note: Single SIMD division seems faster.
        return (simd_float4x4(diagonal: .one / simd_float4(aspect * tg, tg, near - far, 1))
                * simd_float4x4([ 1, 0, 0, 0 ],
                                [ 0, 1, 0, 0 ],
                                .init(0,  0,  (far + near)  , -1),
                                .init(0,  0,  2 * far * near,  0)))
    }


    /// - Parameter k: Calibration matrix K (intrinsic matrix) of pinhole camera.
    ///
    /// - Returns: Projective matrix for pinhole camera.
    ///
    /// - Note: The perspective projection matrix is a combination of orthogonal projection matrix in the frame image units and the camera projective matrix.
    /// - Note: See details [here](http://ksimek.github.io/2013/06/03/calibrated_cameras_in_opengl/).
    @inlinable
    public static func projectiveCameraMatrix(k: simd_float3x3, near: Scalar, far: Scalar) -> simd_float4x4 {
        // - Note: Implementation below uses full K matrix. It seems better then picking some elements if K.
        simd_float4x4([ 1, 0, 0, 0 ], [ 0, 1, 0, 0 ], [ 0, 0, 0, 1 ], [ 0, 0, 1, 0 ])
        * simd_float4x4(simd_make_float4(k[0]),
                        simd_make_float4(k[1]),
                        simd_make_float4(-k[2], near + far),
                        .init(0, 0, 0, near * far))
    }

}



// MARK: Projections <Double>

extension KvMath3 where Scalar == Double {

    /// - Returns: Matrix of standard orthogonal projection.
    @inlinable
    public static func orthogonalProjection(left: Scalar, right: Scalar, top: Scalar, bottom: Scalar, near: Scalar, far: Scalar) -> simd_double4x4 {
        // - Note: Single SIMD division seems faster.
        simd_double4x4(diagonal: .one / simd_double4(left - right, bottom - top, near - far, 1))
        * simd_double4x4([ -2,  0, 0, 0 ],
                         [  0, -2, 0, 0 ],
                         [  0,  0, 2, 0 ],
                         .init(right + left, top + bottom, far + near, 1))
    }


    /// - Parameter aspect: Ratio of Viewport width to viewport height.
    /// - Parameter fof: Vertical camera angle.
    ///
    /// - Returns: Projection matrix for a centered rectangular pinhole camera.
    @inlinable
    public static func perspectiveProjection(aspect: Scalar, fov: Scalar, near: Scalar, far: Scalar) -> simd_double4x4 {
        let tg = tan(0.5 * fov)

        // - Note: Single SIMD division seems faster.
        return (simd_double4x4(diagonal: .one / simd_double4(aspect * tg, tg, near - far, 1))
                * simd_double4x4([ 1, 0, 0, 0 ],
                                 [ 0, 1, 0, 0 ],
                                 .init(0,  0,  (far + near)  , -1),
                                 .init(0,  0,  2 * far * near,  0)))
    }


    /// - Parameter k: Calibration matrix K (intrinsic matrix) of pinhole camera.
    ///
    /// - Returns: Projective matrix for pinhole camera.
    ///
    /// - Note: The perspective projection matrix is a combination of orthogonal projection matrix in the frame image units and the camera projective matrix.
    /// - Note: See details [here](http://ksimek.github.io/2013/06/03/calibrated_cameras_in_opengl/).
    @inlinable
    public static func projectiveCameraMatrix(k: simd_double3x3, near: Scalar, far: Scalar) -> simd_double4x4 {
        // - Note: Implementation below uses full K matrix. It seems better then picking some elements if K.
        simd_double4x4([ 1, 0, 0, 0 ], [ 0, 1, 0, 0 ], [ 0, 0, 0, 1 ], [ 0, 0, 1, 0 ])
        * simd_double4x4(simd_make_double4(k[0]),
                         simd_make_double4(k[1]),
                         simd_make_double4(-k[2], near + far),
                         .init(0, 0, 0, near * far))
    }

}



// MARK: .Line

extension KvMath3 {

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


        /// - Returns: A boolean value indicating whether the receiver's direction is on the halfsphere where angles in XY and XZ is in (-pi/2, pi/2].
        @inlinable
        public var hasStandardDirection: Bool {
            direction.x > 0
            || (direction.x == 0
                && (direction.y > 0
                    || (direction.y == 0 && direction.z > 0)))
        }


        /// - Returns: The direction or negated direction so the result is on the halfsphere where angles in XY and XZ is in (-pi/2, pi/2].
        @inlinable
        public var standardDirection: Vector { hasStandardDirection ? direction : -direction }


        @inlinable
        public func at(_ offset: Scalar) -> Position { origin + direction * offset }


        @inlinable
        public func distance(to point: Position) -> Scalar { length(cross(point - origin, direction)) }


        @inlinable
        public func distance(to line: Line) -> Scalar {
            let n = cross(direction, line.direction)
            let l² = length_squared(n)

            return KvIsPositive(l²) ? Swift.abs(dot(line.origin - origin, n) / sqrt(l²)) : distance(to: line.origin)
        }


        @inlinable
        public func projection(for point: Position) -> Position { at(projectionOffset(for: point)) }


        @inlinable
        public func projectionOffset(for point: Position) -> Scalar { KvMath3.dot(point - origin, direction) }


        /// - Note: When `nil` is returned then *line* is parallel to the receiver so any offset is acceptable.
        @inlinable
        public func nearbyOffset(for line: Line) -> Scalar? {
            let n = cross(direction, line.direction)
            let n2 = cross(line.direction, n)

            let denominator = dot(direction, n2)

            return KvIsNonzero(denominator) ? dot(line.origin - origin, n2) / denominator : nil
        }


        @inlinable
        public func contains(_ point: Position) -> Bool {
            KvIsZero(length_squared(cross(point - origin, direction)))
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



// MARK: .Segment

extension KvMath3 {

    public struct Segment : Hashable {

        public let line: Line
        public let range: ClosedRange<Scalar>

        @inlinable
        public var p1: Position { line.at(range.lowerBound) }

        @inlinable
        public var p2: Position { line.at(range.upperBound) }


        @inlinable
        public init(_ p1: Position, _ p2: Position) {
            line = Line(p1, p2)!
            range = line.projectionOffset(for: p1) ... line.projectionOffset(for: p2)
        }


        ///  - Returns: The receiver's range when the receiver's line has standard direction. Otherwise projection of the range on the receiver's line in standard direction is returned.
        @inlinable
        public var standardRange: ClosedRange<Scalar> { line.hasStandardDirection ? range : (-range.upperBound ... -range.lowerBound) }


        /// - Parameter point: A point on the line.
        @inlinable
        public func contains(_ point: Position) -> Bool {
            KvIs(line.projectionOffset(for: point), in: range)
        }


        @inlinable
        public func distance(to point: Position) -> Scalar {
            let offset = KvMath3.clamp(line.projectionOffset(for: point), range.lowerBound, range.upperBound)

            return KvMath3.distance(line.at(offset), point)
        }


        @inlinable
        public func distance(to segment: Segment) -> Scalar {
            switch line.nearbyOffset(for: segment.line) {
            case .some(let offset1):
                let offset2 = segment.line.nearbyOffset(for: line)!

                return KvMath3.distance(line.at(KvMath3.clamp(offset1, range.lowerBound, range.upperBound)),
                                         segment.line.at(KvMath3.clamp(offset2, segment.range.lowerBound, segment.range.upperBound)))

            case .none:
                typealias Projection = (offset: Scalar, point: Position)

                let pl1: Projection = { (offset: line.projectionOffset(for: $0), point: $0) }(segment.p1)
                let pl2: Projection = { (offset: line.projectionOffset(for: $0), point: $0) }(segment.p1)

                let projectedRange: (lowerBound: Projection, upperBound: Projection) = (pl1.offset <= pl2.offset)
                    ? (lowerBound: pl1, upperBound: pl2) : (lowerBound: pl2, upperBound: pl1)

                if KvIs(range.upperBound, lessThan: projectedRange.lowerBound.offset) {
                    return KvMath3.distance(p2, projectedRange.lowerBound.point)
                }
                else if KvIs(range.lowerBound, greaterThan: projectedRange.upperBound.offset) {
                    return KvMath3.distance(p1, projectedRange.upperBound.point)
                }
                else {
                    return line.distance(to: segment.line.origin)
                }
            }
        }


        @inlinable
        public func translated(by offset: Position) -> Self {
            .init(p1 + offset, p2 + offset)
        }


        @inlinable
        public func scaled(by scale: Scalar) -> Self {
            .init(p1 * scale, p2 * scale)
        }


        // MARK: : Equatable

        @inlinable
        public static func ==(lhs: Self, rhs: Self) -> Bool { lhs.line == rhs.line && lhs.standardRange == rhs.standardRange }


        // MARK: : Hashable

        @inlinable
        public func hash(into hasher: inout Hasher) {
            hasher.combine(line)
            hasher.combine(standardRange)
        }

    }

}



// MARK: .Plane

extension KvMath3 {

    /// Plane equation: *normal* · *x* + *d* = 0, where *x* in on the plane.
    public struct Plane : Hashable {

        public let normal: Vector
        public let d: Scalar

        /// - Warning: Assuming .offset != 0.
        @inlinable
        public var anyPoint: Position { -(normal * d) }


        @inlinable
        public init?(_ p0: Position, _ p1: Position, _ p2: Position) {
            self.init(normal: cross(p1 - p0, p2 - p0), point: p0)
        }


        @inlinable
        public init?(normal: Vector, point: Vector) {
            guard let unitNormal = KvMath3.normalizedOrNil(normal) else { return nil }

            self.init(unitNormal: unitNormal, point: point)
        }


        @inlinable
        public init?(normal: Vector, d: Scalar) {
            guard let unitNormal = KvMath3.normalizedOrNil(normal) else { return nil }

            self.init(unitNormal: unitNormal, d: d)
        }


        /// Initialize a plane where *a*∙x + *b*∙y + *c*∙z + *d* = 0, where (x, y, z) is a plane point.
        @inlinable
        public init?(a: Scalar, b: Scalar, c: Scalar, d: Scalar) {
            let normal = Vector(x: a, y: b, z: c)

            let l = KvMath3.length(normal)

            guard l != 0 else { return nil }

            let scale = 1 / l

            self.init(unitNormal: normal * scale, d: d * scale)
        }


        /// Initialize a plane where a, b, c and d coeficients are scalatrs of given vector.
        @inlinable
        public init?(_ abcd: SIMD4<Scalar>) {
            self.init(a: abcd.x, b: abcd.y, c: abcd.z, d: abcd.w)
        }


        /// - Warning: Value of *unitNormal* must be a unit vector.
        @inlinable
        public init(unitNormal: Vector, point: Vector) {
            self.init(unitNormal: unitNormal, d: -dot(point, unitNormal))
        }


        /// - Warning: Value of *unitNormal* must be a unit vector.
        @inlinable
        public init(unitNormal: Vector, d: Scalar) {
            assert(KvIsNonzero(length_squared(unitNormal)), "Invalid argument: unitNormal (\(unitNormal)) is not a unit vector")

            self.normal = unitNormal
            self.d = d
        }


        @inlinable
        public func at(_ p: Position) -> Scalar { dot(normal, p) + d }


        @inlinable
        public func signedDistance(to point: Position) -> Scalar { at(point) }


        /// - Retuens: A boolean value indicating whether the receiver is above the point. In other words *point* is below the receiver.
        @inlinable
        public func isAbove(_ point: Position) -> Bool { KvIsNegative(at(point)) }


        /// - Retuens: A boolean value indicating whether the receiver is below the point. In other words *point* is above the receiver.
        @inlinable
        public func isBelow(_ point: Position) -> Bool { KvIsPositive(at(point)) }


        @inlinable
        public func offset(from p: Position, in d: Vector) -> Scalar? {
            let divider = dot(normal, d)

            guard KvIsNonzero(divider) else { return nil }

            return -at(p) / divider
        }


        @inlinable
        public func offsetFromOrigin(in direction: Vector) -> Scalar? {
            let divider = dot(normal, direction)

            guard KvIsNonzero(divider) else { return nil }

            return -d / divider
        }


        @inlinable
        public func intersection(with line: Line) -> Position? {
            guard let t = offset(from: line.origin, in: line.direction) else { return nil }

            return line.at(t)
        }


        @inlinable
        public func intersection(with plane: Plane) -> Line? {
            let nn = dot(normal, plane.normal)

            guard KvIs(Swift.abs(nn), lessThan: 1) else { return nil }

            let invD = 1 / (1 - nn * nn)
            let c1 = (plane.d * nn - d) * invD
            let c2 = (d * nn - plane.d) * invD

            return Line(from: c1 * normal + c2 * plane.normal, in: cross(normal, plane.normal))
        }


        @inlinable
        public func projection(of p: Position) -> Position { p - at(p) * normal }


        @inlinable
        public var negated: Self { .init(unitNormal: -normal, d: -d) }

        @inlinable
        public static prefix func -(plane: Self) -> Self { plane.negated }


        @inlinable
        public func translated(by offset: Position) -> Self {
            .init(unitNormal: normal, d: d - dot(normal, offset))
        }


        /// - Returns: A plane with the same normal but translated by *normal*∙*offset* vector.
        @inlinable
        public func translated(by offset: Scalar) -> Self {
            .init(unitNormal: normal, d: d - offset)
        }


        /// - Returns: A plane produced by applying *scale* to the receiver's points.
        @inlinable
        public func scaled(by scale: Scalar) -> Self {
            .init(unitNormal: normal, d: scale * d)
        }

    }

}



// MARK: .FastPlane

extension KvMath3 {

    /// A plane with neither normalization nor normal validation.
    ///
    /// Plane equation: *normal* · *x* + *d* = 0, where *x* in on the plane.
    public struct FastPlane : Hashable {

        public let normal: Vector
        public let d: Scalar


        /// Initialize plane where *normal*∙x - offset = 0, where x is a plane point.
        @inlinable
        public init(normal: Vector, d: Scalar) {
            self.normal = normal
            self.d = d
        }


        /// Initialize a plane where *a*∙x + *b*∙y + *c*∙z + *d* = 0, where (x, y, z) is a plane point.
        @inlinable
        public init(a: Scalar, b: Scalar, c: Scalar, d: Scalar) {
            self.init(normal: .init(x: a, y: b, z: c), d: d)
        }


        /// Initialize a plane where a, b, c and d coeficients are scalatrs of given vector.
        @inlinable
        public init(_ abcd: SIMD4<Scalar>) {
            self.init(a: abcd.x, b: abcd.y, c: abcd.z, d: abcd.w)
        }


        @inlinable
        public init(_ plane: Plane) {
            self.init(normal: plane.normal, d: plane.d)
        }


        @inlinable
        public func at(_ x: Position) -> Scalar { KvMath3.dot(normal, x) + d }


        /// - Retuens: A boolean value indicating whether the receiver is above the point. In other words *point* is below the receiver.
        @inlinable
        public func isAbove(_ point: Position) -> Bool { KvIsNegative(at(point)) }


        /// - Retuens: A boolean value indicating whether the receiver is below the point. In other words *point* is above the receiver.
        @inlinable
        public func isBelow(_ point: Position) -> Bool { KvIsPositive(at(point)) }


        @inlinable
        public var negated: Self { .init(normal: -normal, d: -d) }

        @inlinable
        public static prefix func -(plane: Self) -> Self { plane.negated }

    }

}



// MARK: .AABB

extension KvMath3 {

    /// Axis-alligned bounding box.
    public struct AABB : Hashable {

        public let min: Position
        public let max: Position


        @inlinable
        public init(min: Position, max: Position) {
            assert(min.x <= max.x)
            assert(min.y <= max.y)
            assert(min.z <= max.z)

            self.min = min
            self.max = max
        }


        @inlinable
        public init(over point: Position) { self.init(min: point, max: point) }


        @inlinable
        public init(over first: Position, _ second: Position, _ rest: Position...) {
            var min = first, max = first

            min = KvMath3.min(min, second)
            max = KvMath3.max(max, second)

            rest.forEach { point in
                min = KvMath3.min(min, point)
                max = KvMath3.max(max, point)
            }

            self.init(min: min, max: max)
        }


        @inlinable
        public init?<Points>(over points: Points) where Points : Sequence, Points.Element == Position {
            var iterator = points.makeIterator()

            guard let first = iterator.next() else { return nil }

            var min = first, max = first

            while let point = iterator.next() {
                min = KvMath3.min(min, point)
                max = KvMath3.max(max, point)
            }

            self.init(min: min, max: max)
        }


        @inlinable
        public static var zero: Self { .init(over: .zero) }


        @inlinable
        public var center: Position { KvMath3.mix(min, max, t: 0.5) }

        @inlinable
        public var size: Vector { max - min }


        @inlinable
        public static var numberOfPoints: Int { 8 }

        @inlinable
        public static var pointIndices: Range<Int> { 0 ..< numberOfPoints }


        /// Face indices are enumerated in CCW order.
        @inlinable
        public static var facePointIndices: [[Int]] { [
            [ 0, 1, 3, 2 ],     // Z–
            [ 1, 5, 7, 3 ],     // X+
            [ 5, 4, 6, 7 ],     // Z+
            [ 0, 2, 6, 4 ],     // X–
            [ 2, 3, 7, 6 ],     // Y+
            [ 1, 0, 4, 5 ],     // Y–
        ] }


        @inlinable
        public var pointIndices: Range<Int> { Self.pointIndices }

        /// Face indices are enumerated in CCW order.
        @inlinable
        public var facePointIndices: [[Int]] { Self.facePointIndices }


        @inlinable
        public func point(at index: Int) -> Position {
            .init(x: (index & 1) == 0 ? min.x : max.x,
                  y: (index & 2) == 0 ? min.y : max.y,
                  z: (index & 4) == 0 ? min.z : max.z)
        }


        @inlinable
        public func union(with point: Position) -> AABB {
            .init(min: KvMath3.min(min, point), max: KvMath3.max(max, point))
        }


        @inlinable
        public func union(with points: Position...) -> AABB {
            points.reduce(self, { $0.union(with: $1) })
        }


        /// - Returns: Distacne to closest intersection with the receiver and given ray or *nil* if the intersection doesn't occur.
        @inlinable
        public func distance(from origin: Position, in direction: Vector) -> Scalar? {
            let t = KvMath3.max((max - origin) / direction, (min - origin) / direction)

            var distance: Scalar? = nil

            distance = KvIsPositive(t.x) ? KvMath.min(distance, t.x) : distance
            distance = KvIsPositive(t.y) ? KvMath.min(distance, t.y) : distance
            distance = KvIsPositive(t.z) ? KvMath.min(distance, t.z) : distance

            return distance
        }


        @inlinable
        public func translated(by translation: Vector) -> Self {
            .init(min: min + translation, max: max + translation)
        }

    }

}



// MARK: <Float>.AABB

extension KvMath3.AABB where Scalar == Float {

    @inlinable
    public func applying(_ transform: simd_float4x4) -> Self {
        Self(over: Self.pointIndices.lazy.map { index in
            KvMath3.apply(transform, toPosition: point(at: index))
        })!
    }

}



// MARK: <Double>.AABB

extension KvMath3.AABB where Scalar == Double {

    @inlinable
    public func applying(_ transform: simd_double4x4) -> Self {
        Self(over: Self.pointIndices.lazy.map { index in
            KvMath3.apply(transform, toPosition: point(at: index))
        })!
    }

}



// MARK: .Frustum

extension KvMath3 {

    public struct Frustum : Hashable {

        public let left, right, bottom, top, near, far: Plane


        @inlinable
        public init(left: Plane, right: Plane, bottom: Plane, top: Plane, near: Plane, far: Plane) {
            self.left = left
            self.right = right
            self.bottom = bottom
            self.top = top
            self.near = near
            self.far = far
        }


        /// The zero frustum, containing zero point only.
        public static var zero: Self { .init(left:   .init([ 1, 0, 0, 0 ])!, right: .init([ -1, 0, 0, 0 ])!,
                                             bottom: .init([ 0, 1, 0, 0 ])!, top:   .init([ 0, -1, 0, 0 ])!,
                                             near:   .init([ 0, 0, 1, 0 ])!, far:   .init([ 0, 0, -1, 0 ])!) }
        /// The null frustum, containing nothing.
        public static var null: Self { .init(left:   .init([ 1, 0, 0, -1 ])!, right: .init([ -1, 0, 0, -1 ])!,
                                             bottom: .init([ 0, 1, 0, -1 ])!, top:   .init([ 0, -1, 0, -1 ])!,
                                             near:   .init([ 0, 0, 1, -1 ])!, far:   .init([ 0, 0, -1, -1 ])!) }
        /// Frustum, containing all the space.
        public static var infinite: Self { .init(left:   .init([ 1, 0, 0, .infinity ])!, right: .init([ -1, 0, 0, .infinity ])!,
                                                 bottom: .init([ 0, 1, 0, .infinity ])!, top:   .init([ 0, -1, 0, .infinity ])!,
                                                 near:   .init([ 0, 0, 1, .infinity ])!, far:   .init([ 0, 0, -1, .infinity ])!) }


        /// - Returns: Minimum of signed distances to the receiver's planes.
        ///
        /// - Note: The result is positive whether given point is inside the receiver.
        @inlinable
        public func minimumInnerDistance(to x: Position) -> Scalar {
            Swift.min(Swift.min(left.signedDistance(to: x), right.signedDistance(to: x)),
                      Swift.min(bottom.signedDistance(to: x), top.signedDistance(to: x)),
                      Swift.min(near.signedDistance(to: x), far.signedDistance(to: x)))
        }


        @inlinable
        public func contains(_ x: Position) -> Bool { KvIsNotNegative(minimumInnerDistance(to: x)) }


        @inlinable
        public func contains(_ x: Position, margin: Scalar) -> Bool {
            KvIs(minimumInnerDistance(to: x), greaterThanOrEqualTo: margin)
        }


        @inlinable
        public func inset(by d: Scalar) -> Self {
            .init(left: left.translated(by: left.normal * d),
                  right: right.translated(by: right.normal * d),
                  bottom: bottom.translated(by: bottom.normal * d),
                  top: top.translated(by: top.normal * d),
                  near: near.translated(by: near.normal * d),
                  far: far.translated(by: far.normal * d))
        }

    }

}



// MARK: <Float>.Frustum

extension KvMath3.Frustum where Scalar == Float {

    /// Initializes a frustum with a perspective projecoin matrix.
    public init?(_ projectionMatrix: simd_float4x4) {
        let m = projectionMatrix.transpose

        guard let l = KvMath3.Plane(m[3] + m[0]),
              let r = KvMath3.Plane(m[3] - m[0]),
              let b = KvMath3.Plane(m[3] + m[1]),
              let t = KvMath3.Plane(m[3] - m[1]),
              let n = KvMath3.Plane(m[3] + m[2]),
              let f = KvMath3.Plane(m[3] - m[2])
        else { return nil }

        self.init(left: l, right: r, bottom: b, top: t, near: n, far: f)
    }



    /// Initializes a frustum with a perspective projecoin matrix overriding Z planes.
    public init?(_ projectionMatrix: simd_float4x4, zNear: Scalar, zFar: Scalar) {
        let m = projectionMatrix.transpose

        guard let l = KvMath3.Plane(m[3] + m[0]),
              let r = KvMath3.Plane(m[3] - m[0]),
              let b = KvMath3.Plane(m[3] + m[1]),
              let t = KvMath3.Plane(m[3] - m[1])
        else { return nil }

        let (n, f) = (zFar < zNear
                      ? (KvMath3.Plane(unitNormal: [ 0, 0, -1 ], d:  zNear), KvMath3.Plane(unitNormal: [ 0, 0,  1 ], d: -zFar))
                      : (KvMath3.Plane(unitNormal: [ 0, 0,  1 ], d: -zNear), KvMath3.Plane(unitNormal: [ 0, 0, -1 ], d:  zFar)))

        self.init(left: l, right: r, bottom: b, top: t, near: n, far: f)
    }

}



// MARK: <Double>.Frustum

extension KvMath3.Frustum where Scalar == Double {

    /// Initializes a frustum with a perspective projecoin matrix.
    public init?(_ projectionMatrix: simd_double4x4) {
        let m = projectionMatrix.transpose

        guard let l = KvMath3.Plane(m[3] + m[0]),
              let r = KvMath3.Plane(m[3] - m[0]),
              let b = KvMath3.Plane(m[3] + m[1]),
              let t = KvMath3.Plane(m[3] - m[1]),
              let n = KvMath3.Plane(m[3] + m[2]),
              let f = KvMath3.Plane(m[3] - m[2])
        else { return nil }

        self.init(left: l, right: r, bottom: b, top: t, near: n, far: f)
    }



    /// Initializes a frustum with a perspective projecoin matrix overriding Z range.
    public init?(_ projectionMatrix: simd_double4x4, zNear: Scalar, zFar: Scalar) {
        let m = projectionMatrix.transpose

        guard let l = KvMath3.Plane(m[3] + m[0]),
              let r = KvMath3.Plane(m[3] - m[0]),
              let b = KvMath3.Plane(m[3] + m[1]),
              let t = KvMath3.Plane(m[3] - m[1])
        else { return nil }

        let (n, f) = (zFar < zNear
                      ? (KvMath3.Plane(unitNormal: [ 0, 0, -1 ], d:  zNear), KvMath3.Plane(unitNormal: [ 0, 0,  1 ], d: -zFar))
                      : (KvMath3.Plane(unitNormal: [ 0, 0,  1 ], d: -zNear), KvMath3.Plane(unitNormal: [ 0, 0, -1 ], d:  zFar)))

        self.init(left: l, right: r, bottom: b, top: t, near: n, far: f)
    }

}



// MARK: .FastFrustum

extension KvMath3 {

    public struct FastFrustum : Hashable {

        public let left, right, bottom, top, near, far: FastPlane


        @inlinable
        public init(left: FastPlane, right: FastPlane, bottom: FastPlane, top: FastPlane, near: FastPlane, far: FastPlane) {
            self.left = left
            self.right = right
            self.bottom = bottom
            self.top = top
            self.near = near
            self.far = far
        }


        /// The zero frustum, containing zero point only.
        public static var zero: Self { .init(left:   .init([ 1, 0, 0, 0 ]), right: .init([ -1, 0, 0, 0 ]),
                                             bottom: .init([ 0, 1, 0, 0 ]), top:   .init([ 0, -1, 0, 0 ]),
                                             near:   .init([ 0, 0, 1, 0 ]), far:   .init([ 0, 0, -1, 0 ])) }
        /// The null frustum, containing nothing.
        public static var null: Self { .init(left:   .init([ 1, 0, 0, -1 ]), right: .init([ -1, 0, 0, -1 ]),
                                             bottom: .init([ 0, 1, 0, -1 ]), top:   .init([ 0, -1, 0, -1 ]),
                                             near:   .init([ 0, 0, 1, -1 ]), far:   .init([ 0, 0, -1, -1 ])) }
        /// Frustum, containing all the space.
        public static var infinite: Self { .init(left:   .init([ 1, 0, 0, .infinity ]), right: .init([ -1, 0, 0, .infinity ]),
                                                 bottom: .init([ 0, 1, 0, .infinity ]), top:   .init([ 0, -1, 0, .infinity ]),
                                                 near:   .init([ 0, 0, 1, .infinity ]), far:   .init([ 0, 0, -1, .infinity ])) }


        @inlinable
        public func contains(_ x: Position) -> Bool {
            KvIsNotNegative(Swift.min(Swift.min(left.at(x), right.at(x)),
                                      Swift.min(bottom.at(x), top.at(x)),
                                      Swift.min(near.at(x), far.at(x))))
        }

    }

}



// MARK: <Float>.FastFrustum

extension KvMath3.FastFrustum where Scalar == Float {

    /// Initializes a frustum with a perspective projecoin matrix.
    @inlinable
    public init(_ projectionMatrix: simd_float4x4) {
        let m = projectionMatrix.transpose

        self.init(left:   .init(m[3] + m[0]),
                  right:  .init(m[3] - m[0]),
                  bottom: .init(m[3] + m[1]),
                  top:    .init(m[3] - m[1]),
                  near:   .init(m[3] + m[2]),
                  far:    .init(m[3] - m[2]))
    }



    /// Initializes a frustum with a perspective projecoin matrix overriding Z range.
    @inlinable
    public init(_ projectionMatrix: simd_float4x4, zNear: Scalar, zFar: Scalar) {
        let m = projectionMatrix.transpose
        let (n, f) = (zFar < zNear
                      ? (KvMath3.FastPlane(normal: [ 0, 0, -1 ], d:  zNear), KvMath3.FastPlane(normal: [ 0, 0,  1 ], d: -zFar))
                      : (KvMath3.FastPlane(normal: [ 0, 0,  1 ], d: -zNear), KvMath3.FastPlane(normal: [ 0, 0, -1 ], d:  zFar)))

        self.init(left:   .init(m[3] + m[0]),
                  right:  .init(m[3] - m[0]),
                  bottom: .init(m[3] + m[1]),
                  top:    .init(m[3] - m[1]),
                  near:   n,
                  far:    f)
    }

}



// MARK: <Double>.FastFrustum

extension KvMath3.FastFrustum where Scalar == Double {

    /// Initializes a frustum with a perspective projecoin matrix.
    @inlinable
    public init(_ projectionMatrix: simd_double4x4) {
        let m = projectionMatrix.transpose

        self.init(left:   .init(m[3] + m[0]),
                  right:  .init(m[3] - m[0]),
                  bottom: .init(m[3] + m[1]),
                  top:    .init(m[3] - m[1]),
                  near:   .init(m[3] + m[2]),
                  far:    .init(m[3] - m[2]))
    }



    /// Initializes a frustum with a perspective projecoin matrix overriding Z range.
    @inlinable
    public init(_ projectionMatrix: simd_double4x4, zNear: Scalar, zFar: Scalar) {
        let m = projectionMatrix.transpose
        let (n, f) = (zFar < zNear
                      ? (KvMath3.FastPlane(normal: [ 0, 0, -1 ], d:  zNear), KvMath3.FastPlane(normal: [ 0, 0,  1 ], d: -zFar))
                      : (KvMath3.FastPlane(normal: [ 0, 0,  1 ], d: -zNear), KvMath3.FastPlane(normal: [ 0, 0, -1 ], d:  zFar)))

        self.init(left:   .init(m[3] + m[0]),
                  right:  .init(m[3] - m[0]),
                  bottom: .init(m[3] + m[1]),
                  top:    .init(m[3] - m[1]),
                  near:   n,
                  far:    f)
    }

}



// MARK: Auxiliaries

extension KvMath3 {

    /// - Returns: Normalized vector when source vector has nonzero length. Otherwise *nil* is returned.
    @inlinable
    public static func normalizedOrNil(_ vector: Vector) -> Vector? {
        let l² = length_squared(vector)

        guard KvIsNonzero(l²) else { return nil }

        return KvIs(l², inequalTo: 1) ? (vector / sqrt(l²)) : vector
    }

}



// MARK: .Sphere

extension KvMath3 {

    public struct Sphere : Hashable {

        public let center: Position
        public let radius: Scalar


        @inlinable
        public init(at center: Position, radius: Scalar) {
            assert(KvIsNotNegative(radius))

            self.center = center
            self.radius = radius
        }


        @inlinable
        public static var zero: Self { .init(at: .zero, radius: 0) }

        @inlinable
        public static var unit: Self { .init(at: .zero, radius: 1) }


        @inlinable
        public var xEdgePoint: Position { center + .init(radius, 0, 0) }

        @inlinable
        public var yEdgePoint: Position { center + .init(0, radius, 0) }

        @inlinable
        public var zEdgePoint: Position { center + .init(0, 0, radius) }


        @inlinable
        public var anyEdgePoint: Position { xEdgePoint }

    }

}



// MARK: .MeshVolume

extension KvMath3 {

    @available(*, deprecated, renamed: "MeshVolume")
    public struct Volume { }



    /// Stream accumulating volume of solid body composed of triangles. Volume is calculated as sum of signed pyramid volumes where bases are surface triangles and having the same top vertex.
    public struct MeshVolume : Hashable {

        @inlinable
        public var value: Scalar {
            _value / 6      // Common factors ½ (triangle area) and ⅓ (pyramid volume) are applied here.
        }


        @inlinable
        public init() { }


        /// - Warning: It's made internal for performance reasons.
        @usableFromInline
        internal private(set) var _value: Scalar = 0


        // MARK: Operations

        /// Process given triangle. The origin is assumed to be at the coordinate center.
        @inlinable
        public mutating func process(_ p₁: Position, _ p₂: Position, _ p₃: Position) {
            _value += dot(cross(p₂ - p₁, p₃ - p₁), p₁)
        }


        /// Process given triangle in shifted coordinate space relative to previously processed triangles.
        @inlinable
        public mutating func process(_ p₁: Position, _ p₂: Position, _ p₃: Position, offset: Position) {
            _value += dot(cross(p₂ - p₁, p₃ - p₁), p₁ - offset)
        }

    }

}



// MARK: Generalization of SIMD

extension KvMath3 {

    @inlinable public static func abs(_ v: Vector) -> Vector { .init(Swift.abs(v.x), Swift.abs(v.y), Swift.abs(v.z)) }

    @inlinable public static func clamp(_ x: Scalar, _ min: Scalar, _ max: Scalar) -> Scalar { Swift.max(min, Swift.min(max, x)) }

    @inlinable public static func clamp(_ v: Vector, _ min: Vector, _ max: Vector) -> Vector {
        Vector(x: KvMath3.clamp(v.x, min.x, max.x),
               y: KvMath3.clamp(v.y, min.y, max.y),
               z: KvMath3.clamp(v.z, min.z, max.z))
    }

    @inlinable public static func cross(_ x: Vector, _ y: Vector) -> Vector {
        Vector(x: x.y * y.z - x.z * y.y,
               y: x.z * y.x - x.x * y.z,
               z: x.x * y.y - x.y * y.x)
    }

    @inlinable public static func distance(_ x: Vector, _ y: Vector) -> Scalar { length(y - x) }

    @inlinable public static func dot(_ x: Vector, _ y: Vector) -> Scalar { x.x * y.x + x.y * y.y + x.z * y.z }

    @inlinable public static func length(_ v: Vector) -> Scalar { sqrt(dot(v, v)) }

    @inlinable public static func length_squared(_ v: Vector) -> Scalar { dot(v, v) }

    @inlinable public static func max(_ x: Vector, _ y: Vector) -> Vector {
        Vector(x: Swift.max(x.x, y.x),
               y: Swift.max(x.y, y.y),
               z: Swift.max(x.z, y.z))
    }

    @inlinable public static func min(_ x: Vector, _ y: Vector) -> Vector {
        Vector(x: Swift.min(x.x, y.x),
               y: Swift.min(x.y, y.y),
               z: Swift.min(x.z, y.z))
    }

    @inlinable public static func mix(_ x: Vector, _ y: Vector, t: Scalar) -> Vector {
        let oneMinusT = 1 - t

        return Vector(x: x.x * oneMinusT + y.x * t,
                      y: x.y * oneMinusT + y.y * t,
                      z: x.z * oneMinusT + y.z * t)
    }

}



// MARK: SIMD where Scalar == Float

extension KvMath3 where Scalar == Float {

    @inlinable public static func abs(_ v: Vector) -> Vector { simd.abs(v) }

    @inlinable public static func clamp(_ x: Scalar, _ min: Scalar, _ max: Scalar) -> Scalar { simd_clamp(x, min, max) }

    @inlinable public static func clamp(_ v: Vector, _ min: Vector, _ max: Vector) -> Vector { simd_clamp(v, min, max) }

    @inlinable public static func cross(_ x: Vector, _ y: Vector) -> Vector { simd.cross(x, y) }

    @inlinable public static func distance(_ x: Vector, _ y: Vector) -> Scalar { simd.distance(x, y) }

    @inlinable public static func dot(_ x: Vector, _ y: Vector) -> Scalar { simd.dot(x, y) }

    @inlinable public static func length(_ v: Vector) -> Scalar { simd.length(v) }

    @inlinable public static func length_squared(_ v: Vector) -> Scalar { simd.length_squared(v) }

    @inlinable public static func max(_ x: Vector, _ y: Vector) -> Vector { simd_max(x, y) }

    @inlinable public static func min(_ x: Vector, _ y: Vector) -> Vector { simd_min(x, y) }

    @inlinable public static func mix(_ x: Vector, _ y: Vector, t: Scalar) -> Vector { simd.mix(x, y, t: t) }

}



// MARK: SIMD where Scalar == Double

extension KvMath3 where Scalar == Double {

    @inlinable public static func abs(_ v: Vector) -> Vector { simd.abs(v) }

    @inlinable public static func clamp(_ x: Scalar, _ min: Scalar, _ max: Scalar) -> Scalar { simd_clamp(x, min, max) }

    @inlinable public static func clamp(_ v: Vector, _ min: Vector, _ max: Vector) -> Vector { simd_clamp(v, min, max) }

    @inlinable public static func cross(_ x: Vector, _ y: Vector) -> Vector { simd.cross(x, y) }

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
public func KvIs<Scalar>(_ lhs: KvMath3<Scalar>.Vector, equalTo rhs: KvMath3<Scalar>.Vector) -> Bool
where Scalar : KvMathScalar3
{
    KvIsZero(KvMath3.abs(lhs - rhs).max())
}


@inlinable
public func KvIs<Scalar>(_ lhs: KvMath3<Scalar>.Vector, inequalTo rhs: KvMath3<Scalar>.Vector) -> Bool
where Scalar : KvMathScalar3
{
    KvIsNonzero(KvMath3.abs(lhs - rhs).max())
}



// MARK: - Matrix Comparisons

@inlinable
public func KvIs(_ lhs: simd_float3x3, equalTo rhs: simd_float3x3) -> Bool {
    KvIsZero(KvMath3.max(KvMath3.abs(lhs - rhs)))
}


@inlinable
public func KvIs(_ lhs: simd_double3x3, equalTo rhs: simd_double3x3) -> Bool {
    KvIsZero(KvMath3.max(KvMath3.abs(lhs - rhs)))
}


@inlinable
public func KvIs(_ lhs: simd_float3x3, inequalTo rhs: simd_float3x3) -> Bool {
    KvIsNonzero(KvMath3.max(KvMath3.abs(lhs - rhs)))
}


@inlinable
public func KvIs(_ lhs: simd_double3x3, inequalTo rhs: simd_double3x3) -> Bool {
    KvIsNonzero(KvMath3.max(KvMath3.abs(lhs - rhs)))
}



// MARK: - Line Comparisons

@inlinable
public func KvIs<Scalar>(_ lhs: KvMath3<Scalar>.Line, equalTo rhs: KvMath3<Scalar>.Line) -> Bool
where Scalar : KvMathScalar3
{
    lhs.contains(rhs.origin) && KvIs(lhs.standardDirection, equalTo: rhs.standardDirection)
}


@inlinable
public func KvIs<Scalar>(_ lhs: KvMath3<Scalar>.Line, inequalTo rhs: KvMath3<Scalar>.Line) -> Bool
where Scalar : KvMathScalar3
{
    !lhs.contains(rhs.origin) || KvIs(lhs.standardDirection, inequalTo: rhs.standardDirection)
}



// MARK: - Segment Comparisons

@inlinable
public func KvIs<Scalar>(_ lhs: KvMath3<Scalar>.Segment, equalTo rhs: KvMath3<Scalar>.Segment) -> Bool
where Scalar : KvMathScalar3
{
    let p11 = lhs.p1, p21 = rhs.p1

    return KvIs(p11, equalTo: p21) ? KvIs(lhs.p2, equalTo: rhs.p2) : (KvIs(p11, equalTo: rhs.p2) && KvIs(lhs.p2, equalTo: p21))
}


@inlinable
public func KvIs<Scalar>(_ lhs: KvMath3<Scalar>.Segment, inequalTo rhs: KvMath3<Scalar>.Segment) -> Bool
where Scalar : KvMathScalar3
{
    !KvIs(lhs, equalTo: rhs)
}



// MARK: - Plane Comparisons

@inlinable
public func KvIs<Scalar>(_ lhs: KvMath3<Scalar>.Plane, equalTo rhs: KvMath3<Scalar>.Plane) -> Bool
where Scalar : KvMathScalar3
{
    KvIs(lhs.normal, equalTo: rhs.normal) && KvIs(lhs.d, equalTo: rhs.d)
}


@inlinable
public func KvIs<Scalar>(_ lhs: KvMath3<Scalar>.Plane, inequalTo rhs: KvMath3<Scalar>.Plane) -> Bool
where Scalar : KvMathScalar3
{
    KvIs(lhs.normal, inequalTo: rhs.normal) || KvIs(lhs.d, inequalTo: rhs.d)
}



// MARK: - AABB Comparisons

@inlinable
public func KvIs<Scalar>(_ lhs: KvMath3<Scalar>.AABB, equalTo rhs: KvMath3<Scalar>.AABB) -> Bool
where Scalar : KvMathScalar3
{
    KvIs(lhs.min, equalTo: rhs.min) && KvIs(lhs.max, equalTo: rhs.max)
}


@inlinable
public func KvIs<Scalar>(_ lhs: KvMath3<Scalar>.AABB, inequalTo rhs: KvMath3<Scalar>.AABB) -> Bool
where Scalar : KvMathScalar3
{
    KvIs(lhs.min, inequalTo: rhs.min) || KvIs(lhs.max, inequalTo: rhs.max)
}



// MARK: - Frustum Comparisons

@inlinable
public func KvIs<Scalar>(_ lhs: KvMath3<Scalar>.Frustum, equalTo rhs: KvMath3<Scalar>.Frustum) -> Bool
where Scalar : KvMathScalar3
{
    KvIs(lhs.left, equalTo: rhs.left) && KvIs(lhs.right, equalTo: rhs.right)
    && KvIs(lhs.bottom, equalTo: rhs.bottom) && KvIs(lhs.top, equalTo: rhs.top)
    && KvIs(lhs.near, equalTo: rhs.near) && KvIs(lhs.far, equalTo: rhs.far)
}


@inlinable
public func KvIs<Scalar>(_ lhs: KvMath3<Scalar>.Frustum, inequalTo rhs: KvMath3<Scalar>.Frustum) -> Bool
where Scalar : KvMathScalar3
{
    !KvIs(lhs, equalTo: rhs)
}



// MARK: - Sphere Comparisons

@inlinable
public func KvIs<Scalar>(_ lhs: KvMath3<Scalar>.Sphere, equalTo rhs: KvMath3<Scalar>.Sphere) -> Bool
where Scalar : KvMathScalar3
{
    KvIs(lhs.center, equalTo: rhs.center) && KvIs(lhs.radius, equalTo: rhs.radius)
}


@inlinable
public func KvIs<Scalar>(_ lhs: KvMath3<Scalar>.Sphere, inequalTo rhs: KvMath3<Scalar>.Sphere) -> Bool
where Scalar : KvMathScalar3
{
    KvIs(lhs.center, inequalTo: rhs.center) || KvIs(lhs.radius, inequalTo: rhs.radius)
}



// MARK: - MeshVolume Comparisons

@inlinable
public func KvIs<Scalar>(_ lhs: KvMath3<Scalar>.MeshVolume, equalTo rhs: KvMath3<Scalar>.MeshVolume) -> Bool
where Scalar : KvMathScalar3
{
    KvIs(lhs._value, equalTo: rhs._value)
}


@inlinable
public func KvIs<Scalar>(_ lhs: KvMath3<Scalar>.MeshVolume, inequalTo rhs: KvMath3<Scalar>.MeshVolume) -> Bool
where Scalar : KvMathScalar3
{
    KvIs(lhs._value, inequalTo: rhs._value)
}



// MARK: - Legacy <Float>

extension KvMath3 where Scalar == Float {

    @available(*, deprecated, renamed: "basisX") @inlinable
    public static func right(from matrix: simd_float4x4) -> Vector { basisX(from: matrix) }

    @available(*, deprecated, renamed: "basisY") @inlinable
    public static func up(from matrix: simd_float4x4) -> Vector { basisY(from: matrix) }

    @available(*, deprecated, renamed: "basisZ") @inlinable
    public static func front(from matrix: simd_float4x4) -> Vector { basisZ(from: matrix) }

}


// MARK: - Legacy <Double>

extension KvMath3 where Scalar == Double {

    @available(*, deprecated, renamed: "basisX") @inlinable
    public static func right(from matrix: simd_double4x4) -> Vector { basisX(from: matrix) }

    @available(*, deprecated, renamed: "basisY") @inlinable
    public static func up(from matrix: simd_double4x4) -> Vector { basisY(from: matrix) }

    @available(*, deprecated, renamed: "basisZ") @inlinable
    public static func front(from matrix: simd_double4x4) -> Vector { basisZ(from: matrix) }

}
