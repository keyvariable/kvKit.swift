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
//  KvLine3.swift
//  kvKit
//
//  Created by Svyatoslav Popov on 24.09.2022.
//

/// Implementation of line in 3D coordinate space.
public struct KvLine3<Math : KvMathScope> {

    public typealias Math = Math

    public typealias Scalar = Math.Scalar
    public typealias Vector = Math.Vector3
    public typealias Coordinate = Vector
    public typealias Quaternion = Math.Quaternion

    public typealias Transform = KvTransform3<Math>
    public typealias AffineTransform = KvAffineTransform3<Math>



    /// Quaternion defining orientation of the line.
    public var quaternion: Quaternion
    /// Distance from the origin to the line.
    public var d: Scalar



    /// Memberwise initializer.
    @inlinable
    public init(quaternion: Quaternion, d: Scalar) {
        self.quaternion = quaternion
        self.d = d
    }


    /// A line containing two given coordinates.
    ///
    /// - Note: Initialized line is degenerate if given coordinates are equal.
    @inlinable public init(_ c0: Coordinate, _ c1: Coordinate) { self.init(in: c1 - c0, at: c0) }


    /// A line matching given ray.
    @inlinable
    public init<V>(_ ray: KvRay3<V>)
    where V : KvVertex3Protocol, V.Math == Math
    {
        self.init(in: ray.direction, at: ray.origin.coordinate)
    }


#warning("Unit test both cases")
    /// A line having given direction and containing given coordinate.
    @inlinable
    public init(in direction: Vector, at coordinate: Coordinate) {
        var right = Math.cross(direction, coordinate)

        switch Math.isNonzero(right) {
        case true:
            let front = Math.normalize(direction)
            right = Math.normalize(right)
            let up = Math.cross(right, front)

            let q = Quaternion(Math.Matrix3x3(right, up, front))

            self.init(quaternion: q, d: -Math.dot(coordinate, up))

        case false:
            self.init(quaternion: Quaternion(from: Self.front, to: direction), d: 0)
        }
    }



    // MARK: Constatns

    /// Unit direction vector in the local coordinate space. It is aimed in reverse Z direction.
    ///
    /// - SeeAlso: ``right``, ``up``.
    public static var front: Vector { .unitNZ }
    /// A unit vector in the local coordinate space that is orthogonal to ``front``. It matches Y axis.
    ///
    /// - SeeAlso: ``front``, ``right``.
    public static var up: Vector { .unitY }
    /// A unit vector in the local coordinate space that is orthogonal to both ``front`` and ``up``. It matches X axis.
    ///
    /// - SeeAlso: ``front``, ``up``.
    public static var right: Vector { .unitX }



    // MARK: Operations

    /// The direction vector.
    ///
    /// - SeeAlso: ``right``, ``up``.
    @inlinable public var front: Vector { quaternion.act(Self.front) }
    /// Vector orthogonal to ``front``.
    ///
    /// - SeeAlso: ``front``, ``right``.
    @inlinable public var up: Vector { quaternion.act(Self.up) }
    /// Vector orthogonal to both ``front`` and ``up``.
    ///
    /// - SeeAlso: ``front``, ``up``.
    @inlinable public var right: Vector { quaternion.act(Self.right) }

    /// - Returns: Some coordinate on the receiver.
    @inlinable public var anyCoordinate: Coordinate { up * -d }

    @inlinable public var isDegenerate: Bool { Math.isZero(quaternion) }


    /// Translates all the receiver's ponts by *offset*.
    ///
    /// - Note: It's faster then apply arbitraty transformation.
    @inlinable public mutating func translate(by offset: Vector) { self = translated(by: offset) }


    /// - Returns: A line produced applying translation by *offset* to all the receiver's ponts.
    ///
    /// - Note: It's faster then apply arbitraty transformation.
    @inlinable
    public func translated(by offset: Vector) -> Self {
        Self(in: front, at: anyCoordinate + offset)
    }


    /// Scales all the receiver's ponts.
    ///
    /// - Note: It's faster then apply arbitraty transformation.
    @inlinable
    public mutating func scale(by scale: Scalar) {
        d *= scale
    }


    /// - Returns: A line produced applying scale to all the receiver's ponts.
    ///
    /// - Note: It's faster then apply arbitraty transformation.
    @inlinable
    public func scaled(by scale: Scalar) -> Self {
        Self(quaternion: quaternion, d: d * scale)
    }


    /// Applies given transformation to all the receiver's points.
    @inlinable public mutating func apply(_ t: Transform) { self = t * self }

    /// Applies given transformation to all the receiver's points.
    @inlinable public mutating func apply(_ t: AffineTransform) { self = t * self }



    // MARK: Operators

    /// - Returns: Result of given transformation applied to *rhs*.
    @inlinable
    public static func *(lhs: Transform, rhs: Self) -> Self {
        Self(in: lhs.act(normal: rhs.front), at: lhs.act(coordinate: rhs.anyCoordinate))
    }

    /// - Returns: Result of given transformation applied to *rhs*.
    @inlinable
    public static func *(lhs: AffineTransform, rhs: Self) -> Self {
        Self(in: lhs.act(normal: rhs.front), at: lhs.act(coordinate: rhs.anyCoordinate))
    }

}



// MARK: : KvNumericallyEquatable

extension KvLine3 : KvNumericallyEquatable {

    /// - Returns: A boolean value indicating whether the receiver and *rhs* are numerically equal.
    @inlinable
    public func isEqual(to rhs: Self) -> Bool {
        switch KvIsNonzero(d) {
        case true:
            guard KvIsNonzero(rhs.d) else { return false }

            return Math.isEqual(quaternion * rhs.d, rhs.quaternion * d)

        case false:
            return KvIsZero(rhs.d) && Math.isCoDirectional(front, rhs.front)
        }
    }

}



// MARK: : Equatable

extension KvLine3 : Equatable { }
