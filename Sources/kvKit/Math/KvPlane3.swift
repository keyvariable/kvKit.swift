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
//  KvPlane3.swift
//  kvKit
//
//  Created by Svyatoslav Popov on 24.09.2022.
//

/// Implementation of a plane in 3D coordinate space.
///
/// Planes are equal to hals-spaces where the normals are in.
public struct KvPlane3<Math : KvMathScope> {

    public typealias Math = Math

    public typealias Scalar = Math.Scalar
    public typealias Vector = Math.Vector3
    public typealias Coordinate = Vector

    public typealias Transform = KvTransform3<Math>
    public typealias AffineTransform = KvAffineTransform3<Math>



    /// A vector orthogonal to the receiver.
    public var normal: Vector
    /// The offset between the receiver and the origin.
    ///
    /// - Note: Canonical plane equateion: *normal*∙*x* + *d* = 0, where *x* is a coordinate on plane.
    /// - Note: If the *normal* is a unit vector then *d* is the negated distance from the receiver to the origin.
    public var d: Scalar



    /// Memberwise initializer.
    @inlinable
    public init(normal: Vector, d: Scalar) {
        self.normal = normal
        self.d = d
    }


    /// A plane where *a*∙*x* + *b*∙*y* + *c*∙*z* + *d* = 0, where (*x*, *y*, *z*) is a coordinate on the plane.
    @inlinable public init(a: Scalar, b: Scalar, c: Scalar, d: Scalar) { self.init(normal: Vector(x: a, y: b, z: c), d: d) }


    /// A plane where *a*∙*x* + *b*∙*y* + *c*∙*z* + *d* = 0, where (*x*, *y*, *z*) is a coordinate on the plane, (*a*, *b*, *c*, *d*) are equal to corresponding elements of *abcd* vector.
    @inlinable public init(abcd: Math.Vector4) { self.init(a: abcd.x, b: abcd.y, c: abcd.z, d: abcd.w) }


    /// A plane containing *c0*, *c1*, and *c2* coordinates.
    ///
    /// - Note: Resulting plane is degenerate when *c0*, *c1* and *c2* are on the same plane.
    @inlinable
    public init(_ c0: Coordinate, _ c1: Coordinate, _ c2: Coordinate) {
        self.init(normal: Math.cross(c1 - c0, c2 - c0), at: c0)
    }


    /// A plane having given normal and containing given coordinate.
    @inlinable
    public init(normal: Vector, at coordinate: Coordinate) {
        self.init(normal: normal, d: -Math.dot(coordinate, normal))
    }



    // MARK: Operations

    /// Some coordinate on the receiver.
    @inlinable public var anyCoordinate: Coordinate { closestToOrigin }

    /// A coordinate on the receiver having minimum distance to the coordinate origin.
    @inlinable public var closestToOrigin: Coordinate { normal * -d }

    @inlinable public var isDegenerate: Bool { Math.isZero(normal) }


    //// - Returns: Value of the canonical equation at *x*: *normal* · *x* + *d*.
    ///
    /// - Note: Returned value is the signed offset. It's positive when *x* is in the halfspace the normal is aimed at.
    /// - Note: Signed offset matches signed distance when the normal is a unit vector.
    @inlinable public func at(_ x: Coordinate) -> Scalar { Math.dot(normal, x) + d }


    /// Alias to ``at``(method).
    @inlinable
    public func signedOffset(to x: Coordinate) -> Scalar { at(x) }


    /// - Returns: The distance from the receiver to *x* divided by length of the normal.
    @inlinable
    public func offset(to x: Coordinate) -> Scalar { abs(at(x)) }


    /// - Returns: A boolean value indicating whether given coordinate is in the positive half-space.
    ///
    /// - SeeAlso: ``isInNegative``
    /// - Note: A half-space is positive or negative whether the normal vector is in it.
    @inlinable public func isInPositive(_ x: Coordinate) -> Bool { KvIsPositive(at(x)) }


    /// - Returns: A boolean value indicating whether given coordinate is in the negative half-space.
    ///
    /// - SeeAlso: ``isInPositive``
    /// - Note: A half-space is positive or negative whether the normal vector is in it.
    @inlinable public func isInNegative(_ x: Coordinate) -> Bool { KvIsNegative(at(x)) }


    /// - Returns: A boolean value indicating whether the receiver contains given coordinate.
    @inlinable public func contains(_ x: Coordinate) -> Bool { KvIsZero(at(x)) }

    /// - Returns: A boolean value indicating whether the receiver contains coordinates of given ray.
    @inlinable
    public func contains<V>(_ ray: KvRay3<V>) -> Bool
    where V : KvVertex3Protocol, V.Math == Math
    {
        contains(ray.origin.coordinate) && KvIsZero(Math.dot(normal, ray.direction))
    }

    /// - Returns: A boolean value indicating whether the receiver contains given line.
    @inlinable
    public func contains(_ line: KvLine3<Math>) -> Bool {
        contains(line.anyCoordinate) && KvIsZero(Math.dot(line.front, normal))
    }


    /// - Returns: A boolean value indicating whether the receiver and *rhs* intersect.
    @inlinable public func intersects(with rhs: Self) -> Bool { Math.isNonzero(Math.cross(normal, rhs.normal)) }


    /// - Returns: A common line of the receiver and given plane. If the receiver is equal to given plane then *nil* is returned.
    @inlinable
    public func intersection(with plane: Self) -> KvLine3<Math>? {
        let nn = Math.dot(normal, plane.normal)

        guard KvIs(Swift.abs(nn), lessThan: 1) else { return nil }

        let invD = 1 / (1 - nn * nn)
        let c1 = (plane.d * nn - d) * invD
        let c2 = (d * nn - plane.d) * invD

        return KvLine3<Math>(in: Math.cross(normal, plane.normal), at: c1 * normal + c2 * plane.normal)
    }


    /// - Returns: The closest coordinate on the receiver to given coordinate.
    @inlinable
    public func projection(of x: Coordinate) -> Coordinate { x - at(x) * normal }


    /// Normalizes the receiver's normal.
    @inlinable
    public mutating func normalize() {
        let scale = Math.rsqrt(Math.length²(normal))

        normal *= scale
        d *= scale
    }


    /// Inverses the receiver's orientation.
    @inlinable public mutating func negate() { self = -self }


    /// Normalizes the receiver's direction if it isn't a zero vector.
    @inlinable
    public func normalized() -> Self {
        let scale = Math.rsqrt(Math.length²(normal))

        return Self(normal: normal * scale, d: d * scale)
    }


    /// - Returns: A plane matching the receiver but having unit normal.
    @inlinable
    public mutating func safeNormalize() {
        guard Math.isNonzero(normal) else { return }

        normalize()
    }


    /// - Returns: A plane matching the receiver but having unit normal when the receiver's normal isn't a zero vector.
    @inlinable
    public func safeNormalized() -> Self? {
        guard Math.isNonzero(normal) else { return nil }

        return normalized()
    }


    /// Translates all the receiver's ponts by *offset*.
    ///
    /// - Note: It's faster then apply arbitraty transformation.
    @inlinable
    public mutating func translate(by offset: Vector) {
        d -= Math.dot(normal, offset)
    }


    /// - Returns: A plane produced applying translation by *offset* to all the receiver's ponts.
    ///
    /// - Note: It's faster then apply arbitraty transformation.
    @inlinable
    public func translated(by offset: Vector) -> Self {
        Self(normal: normal, d: d - Math.dot(normal, offset))
    }


    /// Translates all the receiver's ponts by *offset* · *normal*.
    ///
    /// - Note: It's faster then apply arbitraty transformation.
    @inlinable
    public mutating func translate(by offset: Scalar) {
        d -= offset
    }


    /// - Returns: A plane produced applying translation by *offset* · *normal* to all the receiver's ponts.
    ///
    /// - Note: It's faster then apply arbitraty transformation.
    @inlinable
    public func translated(by offset: Scalar) -> Self {
        Self(normal: normal, d: d - offset)
    }


    /// Scales all the receiver's ponts.
    ///
    /// - Note: It's faster then apply arbitraty transformation.
    @inlinable
    public mutating func scale(by scale: Scalar) {
        d *= scale
    }


    /// - Returns: A plane produced applying scale to all the receiver's ponts.
    ///
    /// - Note: It's faster then apply arbitraty transformation.
    @inlinable
    public func scaled(by scale: Scalar) -> Self {
        Self(normal: normal, d: d * scale)
    }


    /// Applies given transformation to all the receiver's points.
    @inlinable public mutating func apply(_ t: Transform) { self = t * self }

    /// Applies given transformation to all the receiver's points.
    @inlinable public mutating func apply(_ t: AffineTransform) { self = t * self }



    // MARK: Operators

    /// - Returns: A plane mathing given plane but having opposite normal.
    @inlinable
    public static prefix func -(rhs: Self) -> Self {
        Self(normal: -rhs.normal, d: -rhs.d)
    }


    /// - Returns: Result of given transformation applied to *rhs*.
    @inlinable
    public static func *(lhs: Transform, rhs: Self) -> Self {
        Self(normal: lhs.act(normal: rhs.normal), at: lhs.act(coordinate: rhs.anyCoordinate))
    }

    /// - Returns: Result of given transformation applied to *rhs*.
    @inlinable
    public static func *(lhs: AffineTransform, rhs: Self) -> Self {
        Self(normal: lhs.act(normal: rhs.normal), at: lhs.act(coordinate: rhs.anyCoordinate))
    }

}



// MARK: : KvNumericallyEquatable

extension KvPlane3 : KvNumericallyEquatable {

    /// - Returns: A boolean value indicating whether the receiver and *rhs* are numerically equal.
    @inlinable
    public func isEqual(to rhs: Self) -> Bool {
        d.isEqual(to: rhs.d) && Math.isEqual(normal, rhs.normal)
    }

}



// MARK: : Equatable

extension KvPlane3 : Equatable { }



// MARK: : Hashable

extension KvPlane3 : Hashable { }
