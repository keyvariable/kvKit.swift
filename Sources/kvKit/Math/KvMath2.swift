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

    public typealias Scalar = Scalar

    public typealias Vector = SIMD2<Scalar>
    public typealias Position = Vector

    public typealias Matrix = KvSimdMatrix2x2<Scalar>
    public typealias ProjectiveMatrix = KvSimdMatrix3x3<Scalar>

}


public typealias KvMath2F = KvMath2<Float>
public typealias KvMath2D = KvMath2<Double>



// MARK: Matrix Operations

extension KvMath2 {

    @inlinable
    public static func abs(_ matrix: Matrix) -> Matrix {
        .init(abs(matrix[0]), abs(matrix[1]))
    }


    @inlinable
    public static func min(_ matrix: Matrix) -> Scalar {
        Swift.min(matrix[0].min(), matrix[1].min())
    }


    @inlinable
    public static func max(_ matrix: Matrix) -> Scalar {
        Swift.max(matrix[0].max(), matrix[1].max())
    }

}



// MARK: Transformations

extension KvMath2 {

    @inlinable
    public static func apply(_ matrix: ProjectiveMatrix, toPosition position: Position) -> Position {
        let p3 = matrix * ProjectiveMatrix.Row(position, 1)

        return p3[[ 0, 1 ] as simd_long2] / p3.z
    }

    @inlinable
    public static func apply(_ matrix: ProjectiveMatrix, toVector vector: Vector) -> Vector {
        let v3 = matrix * ProjectiveMatrix.Row(vector, 0)

        return v3[[ 0, 1 ] as simd_long2]
    }


    @inlinable
    public static func translationMatrix(by translation: Vector) -> ProjectiveMatrix {
        ProjectiveMatrix([ 1, 0, 0 ], [ 0, 1, 0 ], ProjectiveMatrix.Column(translation, 1))
    }

    @inlinable
    public static func translation<ProjectiveMatrix>(from matrix: ProjectiveMatrix) -> Vector
    where ProjectiveMatrix : KvSimdMatrix3xN & KvSimdMatrixNx3 & KvSimdSquareMatrix, ProjectiveMatrix.Scalar == Scalar
    {
        let c3 = matrix[2]

        return c3[[ 0, 1 ] as simd_long2] / c3.z
    }

    @inlinable
    public static func setTranslation<ProjectiveMatrix>(_ translation: Vector, to matrix: inout ProjectiveMatrix)
    where ProjectiveMatrix : KvSimdMatrix3xN & KvSimdMatrixNx3 & KvSimdSquareMatrix, ProjectiveMatrix.Scalar == Scalar
    {
        let z = matrix[2, 2]

        matrix[2] = ProjectiveMatrix.Column(translation * z, z)
    }


    /// - Returns: Scale component from given 2×2 matrix.
    @inlinable
    public static func scale<Matrix>(from matrix: Matrix) -> Vector
    where Matrix : KvSimdMatrix2xN & KvSimdMatrixNx2 & KvSimdSquareMatrix, Matrix.Scalar == Scalar
    {
        Vector(x: length(matrix[0]) * (KvIsNotNegative(matrix.determinant) ? 1 : -1),
               y: length(matrix[1]))
    }

    /// - Returns: Sqaured scale component from given 2×2 matrix.
    @inlinable
    public static func scale²<Matrix>(from matrix: Matrix) -> Vector
    where Matrix : KvSimdMatrix2xN & KvSimdMatrixNx2 & KvSimdSquareMatrix, Matrix.Scalar == Scalar
    {
        Vector(x: length_squared(matrix[0]),
               y: length_squared(matrix[1]))
    }

    /// Changes scale component of given 2×2 matrix to given value. If a column is zero then the result is undefined.
    @inlinable
    public static func setScale<Matrix>(_ scale: Vector, to matrix: inout Matrix)
    where Matrix : KvSimdMatrix2xN & KvSimdMatrixNx2 & KvSimdSquareMatrix, Matrix.Scalar == Scalar
    {
        let s = scale * rsqrt(self.scale²(from: matrix))

        matrix[0] *= s.x * (KvIsNotNegative(matrix.determinant) ? 1 : -1)
        matrix[1] *= s.y
    }


    /// - Returns: Scale component from given 3×3 projective matrix having row[2] == [ 0, 0, 1 ].
    @inlinable
    public static func scale<ProjectiveMatrix>(from matrix: ProjectiveMatrix) -> Vector
    where ProjectiveMatrix : KvSimdMatrix3xN & KvSimdMatrixNx3 & KvSimdSquareMatrix, ProjectiveMatrix.Scalar == Scalar
    {
        Vector(x: KvMath3<Scalar>.length(matrix[0]) * (KvIsNotNegative(matrix.determinant) ? 1 : -1),
               y: KvMath3<Scalar>.length(matrix[1]))
    }

    /// - Returns: Sqared scale component from given 3×3 projective matrix having row[2] == [ 0, 0, 1 ].
    @inlinable
    public static func scale²<ProjectiveMatrix>(from matrix: ProjectiveMatrix) -> Vector
    where ProjectiveMatrix : KvSimdMatrix3xN & KvSimdMatrixNx3 & KvSimdSquareMatrix, ProjectiveMatrix.Scalar == Scalar
    {
        Vector(x: KvMath3<Scalar>.length_squared(matrix[0]),
               y: KvMath3<Scalar>.length_squared(matrix[1]))
    }

    /// Changes scale component of given projective 3×3 matrix having row[2] == [ 0, 0, 1 ]. If a column is zero then the result is undefined.
    @inlinable
    public static func setScale<ProjectiveMatrix>(_ scale: Vector, to matrix: inout ProjectiveMatrix)
    where ProjectiveMatrix : KvSimdMatrix3xN & KvSimdMatrixNx3 & KvSimdSquareMatrix, ProjectiveMatrix.Scalar == Scalar
    {
        let s = scale * rsqrt(self.scale²(from: matrix))

        // OK due to matrix[0].z == 0
        matrix[0] *= ProjectiveMatrix.Column(s.x, s.x, 1) * (KvIsNotNegative(matrix.determinant) ? 1 : -1)
        matrix[1] *= ProjectiveMatrix.Column(s.y, s.y, 1)
    }


    /// - Returns: Transformation translating by -*position*, then applying *transform*, then translating by *position*.
    @inlinable
    public static func transformation<M2x2>(_ transform: M2x2, relativeTo position: M2x2.Row) -> ProjectiveMatrix
    where M2x2 : KvSimdMatrix2xN & KvSimdMatrixNx2 & KvSimdSquareMatrix,
          M2x2.Row.SimdView == M2x2.Column.SimdView,
          M2x2.Scalar == Scalar,
          M2x2.Column == ProjectiveMatrix.Column.Sample2
    {
        ProjectiveMatrix(ProjectiveMatrix.Column(transform[0], 0),
                         ProjectiveMatrix.Column(transform[1], 0),
                         ProjectiveMatrix.Column(position - transform * position, 1))
    }


    /// - Returns: Transformed X basis vector.
    @inlinable
    public static func basisX(from matrix: Matrix) -> Matrix.Column {
        matrix[0]
    }

    /// - Returns: Transformed Y basis vector.
    @inlinable
    public static func basisY(from matrix: Matrix) -> Matrix.Column {
        matrix[1]
    }


    /// - Returns: Transformed X basis vector.
    @inlinable
    public static func basisX(from matrix: ProjectiveMatrix) -> Vector {
        Vector(simdView: (matrix[0])[[ 0, 1 ] as simd_long2])
    }

    /// - Returns: Transformed Y basis vector.
    @inlinable
    public static func basisY(from matrix: ProjectiveMatrix) -> Vector {
        Vector(simdView: (matrix[1])[[ 0, 1 ] as simd_long2])
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


        @inlinable
        public func applying(_ transform: ProjectiveMatrix) -> Self {
            Self(over: Self.pointIndices.lazy.map { index in
                apply(transform, toPosition: point(at: index))
            })!
        }

    }

}



// MARK: .ConvexPolygon

extension KvMath2 {

    /// Implementation of a convex polygon defined by sequence of coordinates enumerated in counterclockwise (CCW) direction.
    public struct ConvexPolygon {

        /// Initializes a convex polygon produced from the minimum subsequence of given points enumerated in CCW or CW direction.
        ///
        /// - Parameter points: A sequence of coordinates having no overlapping neighbour segments.
        ///
        /// Given points are filtered to drop numerically equal coordinates and join subsequent segments.
        /// Then the resulting sequence is checked for the same direction: CCW or CW.
        /// Then an instance is initialized with a valid sequence if coordinates.
        public init?<Points>(_ points: Points)
        where Points : Sequence, Points.Element == Position
        {
            self.vertices = .init()

            var iterator = VertexIterator(points)
            var direction: Direction = .invalid

            while let vertex = iterator.next() {
                self.vertices.append(vertex.coordinate)
                direction = vertex.direction
            }

            switch direction {
            case .ccw:
                isReversed = false
            case .cw:
                isReversed = true
            case .invalid, .mixed:
                return nil
            }
        }


        /// Initializes a convex polygon produced from the minimum subsequence of given points enumerated in CCW or CW direction.
        ///
        /// - Parameter points: A sequence of coordinates having no overlapping neighbour segments.
        ///
        /// Given points are filtered to drop numerically equal coordinates and join subsequent segments.
        /// Then the resulting sequence is checked for the same direction: CCW or CW.
        /// Then an instance is initialized with a valid sequence if coordinates.
        @inlinable
        public init?(_ points: Position...) {
            self.init(points)
        }


        /// An instance is initialized with given vertices and reverse flag.
        ///
        /// - Parameter safeVertices: Array of 3 or more vertices. All vertices must be unique, all the angles must be inequal to zero or *pi*.
        /// - Parameter isReversed: Pass *false* if the vertices are in counterclockwise direction, pass *true* if the vertices are in clockwise direction.
        ///
        /// - Warning: There are no validation. Caller is responsible for validation of arguments.
        public init(vertices: [Position], isReversed: Bool) {
            self.vertices = vertices
            self.isReversed = isReversed

#if DEBUG
            if !isValid {
                KvDebug.pause("Invalid arguments: vertices = \(vertices), isReversed = \(isReversed)")
            }
#endif // DEBUG
        }


        /// An instance is initialized with given vertices and reverse flag.
        ///
        /// - Parameter safeVertices: Sequence of 3 or more vertices. All vertices must be unique, all the angles must be inequal to zero or *pi*.
        /// - Parameter isReversed: Pass *false* if the vertices are in counterclockwise direction, pass *true* if the vertices are in clockwise direction.
        ///
        /// - Warning: There are no validation. Caller is responsible for validation of arguments.
        @inlinable
        public init<Vertices>(vertices: Vertices, isReversed: Bool)
        where Vertices : Sequence, Vertices.Element == Position
        {
            self.init(vertices: Array(vertices), isReversed: isReversed)
        }



        /// Vertices in CCW order when .isReversed is false. Otherwise vertices are in CW order.
        private var vertices: [Position]
        /// A boolean value indicating whether .vertices are in CCW or CW order.
        private var isReversed: Bool = false



        // MARK: Operations

        /// Coordinates of the receiver's vertices in CCW order.
        public var ccwVertices: AnyCollection<Position> {
            isReversed ? .init(vertices.reversed()) : .init(vertices)
        }


        /// A boolean value indicating whether the receiver containts valid sequence of vertices.
        /// Usualy it should be used when unafe initialization has been used.
        public var isValid: Bool {
            switch Self.direction(of: vertices) {
            case .ccw:
                return isReversed == false
            case .cw:
                return isReversed == true
            case .invalid, .mixed:
                return false
            }
        }



        /// - Returns: The direction of linerwise closed path on given points.
        @inlinable
        public static func direction<Points>(of points: Points) -> Direction
        where Points : Sequence, Points.Element == Position
        {
            var iterator = VertexIterator(points)
            var direction: Direction = .invalid

            while let vertex = iterator.next() {
                direction = vertex.direction
            }

            return direction
        }

        /// - Returns: The direction of linerwise closed path on given points.
        @inlinable
        public static func direction(of points: Position...) -> Direction {
            direction(of: points)
        }


        /// - Returns: A boolean value indicating wheter given scale couses vertices of a convex polygon to be reversed.
        @inlinable
        public static func willReverseOnScale(x sx: Scalar, y sy: Scalar) -> Bool {
            KvIsNegative(sx * sy)
        }

        @inlinable
        public static func willReverseOnScale(_ scale: Vector) -> Bool { willReverseOnScale(x: scale.x, y: scale.y) }


        public mutating func translate(by offset: Vector) {
            vertices.indices.forEach {
                vertices[$0] += offset
            }
        }


        public mutating func scale(by scale: Vector) {
            vertices.indices.forEach {
                vertices[$0] *= scale
            }

            if Self.willReverseOnScale(scale) {
                isReversed.toggle()
            }
        }


        /// Applies given 3x3 projective matrix having row[2] == [ 0, 0, 1 ]  to all the receiver's vertices.
        public mutating func apply(_ transform: ProjectiveMatrix) {
            if KvIsNegative(transform.determinant) {
                isReversed.toggle()
            }

            vertices.indices.forEach {
                vertices[$0] = KvMath2.apply(transform, toPosition: vertices[$0])
            }
        }



        // MARK: .Direction

        /// Direction at all the polygon vertices.
        public enum Direction : Hashable {
            /// CounterClockWise.
            case ccw
            /// ClockWise.
            case cw
            // Other cases
            case mixed, invalid
        }



        // MARK: .LocalDirection

        /// Direction at a vertex and it's neighbours.
        public enum LocalDirection : Hashable {
            /// Counterclockwise.
            case ccw
            /// Clockwise.
            case cw
            /// Angle on three vertices is zero or *pi*.
            case degenerate
        }



        // MARK: .VertexIterator

        /// Filters input vertices to minimum subsequence producing a convex polygon.
        /// For each vertex calculates the subpath direction until the vertex. So last direction matches with the direction of whole convex polygon on closed path from the vertices.
        /// If direction of a subpath is not .ccw or .cw, then the rest of vertices is ignored.
        public struct VertexIterator<Points> : IteratorProtocol
        where Points : Sequence, Points.Element == Position
        {

            public init(_ points: Points) {
                nextBlock = FSM.initialStateBlock(points)
            }


            /// A FSM state as a block.
            private var nextBlock: FSM.Block


            // MARK: : IteratorProtocol

            public struct Element : Hashable {

                /// Coordinate of vertex.
                public var coordinate: Position
                /// Offset from the receiver's *coordinate* to the next coordinate.
                public var step: Vector
                /// Direction of subpath until the coordinate.
                public var direction: Direction


                // MARK: Operations

                static func from(_ source: PolygonVertexIterator.Element, direction: Direction) -> Element {
                    Element(coordinate: source.coordinate,
                            step: source.step,
                            direction: direction)
                }


                /// - Returns: A boolean value indicating wheter the receiver and *rhs* have the same directions and numerically equal coordinates and steps.
                public func isAlmostEqual(to rhs: Self) -> Bool {
                    direction == rhs.direction
                    && KvIs(coordinate, equalTo: rhs.coordinate)
                    && KvIs(step, equalTo: rhs.step)
                }

            }


            /// - Returns: Next path vertex. It's *direction* property is the direction of subpath on all the returned vertices.
            ///
            /// - Note: *Direction* property of the last element is the direction of the convex polygon.
            public mutating func next() -> Element? { nextBlock(&self) }


            // MARK: .FSM

            private class FSM {

                typealias Block = (inout VertexIterator) -> Element?


                private init(_ points: Points) {
                    iterator = .init(points)
                }


                private var iterator: PolygonVertexIterator


                // MARK: States

                static func initialStateBlock(_ points: Points) -> Block {
                    let fsm = FSM(points)

                    return { _self in
                        guard let first = fsm.iterator.next() else { return nil }

                        let pathDirection: Direction

                        switch first.direction {
                        case .ccw:
                            pathDirection = .ccw
                        case .cw:
                            pathDirection = .cw
                        case .degenerate:
                            _self.nextBlock = endStateBlock()
                            return .from(first, direction: .invalid)
                        }

                        _self.nextBlock = regularStateBlock(fsm, pathDirection)

                        return .from(first, direction: pathDirection)
                    }
                }


                private static func regularStateBlock(_ fsm: FSM, _ pathDirection: Direction) -> Block {
                    return { _self in
                        guard let next = fsm.iterator.next() else { return nil }

                        switch next.direction {
                        case .ccw:
                            guard pathDirection == .ccw else {
                                _self.nextBlock = endStateBlock()
                                return .from(next, direction: .mixed)
                            }

                        case .cw:
                            guard pathDirection == .cw else {
                                _self.nextBlock = endStateBlock()
                                return .from(next, direction: .mixed)
                            }
                        case .degenerate:
                            _self.nextBlock = endStateBlock()
                            return .from(next, direction: .invalid)
                        }

                        return .from(next, direction: pathDirection)
                    }
                }


                private static func endStateBlock() -> Block {
                    return { _ in
                        nil
                    }
                }

            }


            // MARK: .PolygonVertexIterator

            /// Filters input and returns minimum subsequence of vertices producing a polygon with non-degenerate angles. Also path direction is returned for each vertex.
            struct PolygonVertexIterator : IteratorProtocol {

                init(_ points: Points) {
                    nextBlock = FSM.initialStateBlock(points)
                }


                /// A FSM state as a block.
                private var nextBlock: FSM.Block


                // MARK: .LocalDirection

                /// Direction at a vertex and it's neighbours.
                private enum LocalDirection : Hashable {

                    /// Counterclockwise.
                    case ccw
                    /// Clockwise.
                    case cw

                    case frontOrUndefined, backward


                    // MARK: Init

                    /// - Parameter s1: Vector from first to second vertex.
                    /// - Parameter s2: Vector from second to third vertex.
                    ///
                    /// An instance is initialized with the direction of three vertices.
                    public init(steps s1: Vector, _ s2: Vector) {
                        var isNegative = false

                        if KvIsPositive(KvMath2.cross2(s1, s2), alsoIsNegative: &isNegative) {
                            self = .ccw
                        }
                        else if isNegative {
                            self = .cw
                        }
                        else {
                            self = KvIsNotNegative(dot(s1, s2)) ? .frontOrUndefined : .backward
                        }
                    }


                    /// An instance is initialized with the direction of three vertices.
                    @inlinable
                    public init(points p1: Position, _ p2: Position, _ p3: Position) {
                        self.init(steps: p2 - p1, p3 - p2)
                    }

                }


                // MARK: : IteratorProtocol

                struct Element : Hashable {

                    /// Coordinate of vertex.
                    var coordinate: Points.Element
                    /// Offset from the receiver's *coordinate* to the next coordinate.
                    public var step: Vector
                    /// Direction at the coordinate and it's neighbours.
                    var direction: ConvexPolygon.LocalDirection


                    // MARK: Operations

                    /// - Returns: A boolean value indicating wheter the receiver and *rhs* have the same directions and numerically equal coordinates and steps.
                    public func isAlmostEqual(to rhs: Self) -> Bool {
                        direction == rhs.direction
                        && KvIs(coordinate, equalTo: rhs.coordinate)
                        && KvIs(step, equalTo: rhs.step)
                    }

                }


                /// - Returns: Next path vertex and the direction of subpath on all the returned vertices.
                mutating func next() -> Element? { nextBlock(&self) }


                // MARK: .FSM

                private class FSM {

                    typealias Block = (inout PolygonVertexIterator) -> Element?


                    private typealias Point = Points.Element
                    private typealias Vector = Point


                    private init(_ points: Points) {
                        iterator = .init(points)
                    }


                    private var iterator: DistinctCoordinateIterator


                    // MARK: States

                    static func initialStateBlock(_ points: Points) -> Block {
                        let fsm = FSM(points)

                        return { _self in
                            guard let start = fsm.iterator.next() else {
                                _self.nextBlock = endStateBlock()
                                return nil
                            }

                            guard var p1 = fsm.iterator.next() else {
                                _self.nextBlock = endStateBlock()
                                return .init(coordinate: start, step: .zero, direction: .degenerate)
                            }

                            var s1 = p1 - start

                            // Enumerating points until first non-degenerate case.
                            while let p2 = fsm.iterator.next() {
                                let s2 = p2 - p1

                                switch LocalDirection(steps: s1, s2) {
                                case .ccw:
                                    _self.nextBlock = regularStateBlock(
                                        fsm, start, s1,
                                        .init(coordinate: p1, step: s2, direction: .ccw),
                                        p2)
                                    return _self.nextBlock(&_self)

                                case .cw:
                                    _self.nextBlock = regularStateBlock(
                                        fsm, start, s1,
                                        .init(coordinate: p1, step: s2, direction: .cw),
                                        p2)
                                    return _self.nextBlock(&_self)

                                case .frontOrUndefined:
                                    s1 += s2
                                    p1 = p2

                                case .backward:
                                    _self.nextBlock = endStateBlock()
                                    return .init(coordinate: p1, step: s2, direction: .degenerate)
                                }
                            }

                            // Two point case of all-front case.
                            _self.nextBlock = endStateBlock()
                            return .init(coordinate: p1, step: -s1, direction: .degenerate)
                        }
                    }


                    /// - Parameter element: Pending element to retrun.
                    private static func regularStateBlock(_ fsm: FSM, _ first: Point, _ firstStep: Vector, _ element: Element, _ p2: Point) -> Block {
                        var element = element
                        var p2 = p2

                        return { _self in
                            while let p3 = fsm.iterator.next() {
                                let s3 = p3 - p2

                                defer { p2 = p3 }

                                switch LocalDirection(steps: element.step, s3) {
                                case .ccw:
                                    defer { element = .init(coordinate: p2, step: s3, direction: .ccw) }
                                    return element
                                case .cw:
                                    defer { element = .init(coordinate: p2, step: s3, direction: .cw) }
                                    return element
                                case .frontOrUndefined:
                                    element.step += s3
                                case .backward:
                                    _self.nextBlock = pendingVertexStateBlock(.init(coordinate: p2, step: s3, direction: .degenerate))
                                    return element
                                }
                            }

                            // Closing the path
                            do {
                                let s0 = first - p2

                                switch LocalDirection(steps: element.step, s0) {
                                case .ccw:
                                    _self.nextBlock = lastElementStateBlock(.init(coordinate: p2, step: s0, direction: .ccw), first, s0, firstStep)

                                case .cw:
                                    _self.nextBlock = lastElementStateBlock(.init(coordinate: p2, step: s0, direction: .cw), first, s0, firstStep)

                                case .frontOrUndefined:
                                    // *P2* point is ignored in this case.
                                    element.step += s0
                                    _self.nextBlock = lastElementStateBlock(element, first, element.step, firstStep)
                                    return _self.nextBlock(&_self)

                                case .backward:
                                    _self.nextBlock = pendingVertexStateBlock(.init(coordinate: p2, step: s0, direction: .degenerate))
                                }

                                return element
                            }
                        }
                    }


                    /// Given element will be posted once, then the end state is entered.
                    private static func lastElementStateBlock(_ element: Element, _ p1: Point, _ s1: Vector, _ s2: Vector) -> Block {
                        var element = element

                        return { _self in
                            switch LocalDirection(steps: s1, s2) {
                            case .ccw:
                                _self.nextBlock = pendingVertexStateBlock(.init(coordinate: p1, step: s2, direction: .ccw))

                            case .cw:
                                _self.nextBlock = pendingVertexStateBlock(.init(coordinate: p1, step: s2, direction: .cw))

                            case .frontOrUndefined:
                                // *Start* point is ignored in this case.
                                element.step += s2
                                _self.nextBlock = endStateBlock()

                            case .backward:
                                _self.nextBlock = pendingVertexStateBlock(.init(coordinate: p1, step: s2, direction: .degenerate))
                            }

                            return element
                        }
                    }


                    private static func pendingVertexStateBlock(_ element: Element) -> Block {
                        return { _self in
                            _self.nextBlock = endStateBlock()
                            return element
                        }
                    }


                    /// Nothing is iterated, *nil* is always returned.
                    private static func endStateBlock() -> Block {
                        return { _ in
                            nil
                        }
                    }

                }

            }


            // MARK: .DistinctCoordinateIterator

            /// Produces sequene of numerically inequal coordinates from given arbitrary sequence.
            struct DistinctCoordinateIterator : IteratorProtocol {

                init(_ points: Points) {
                    nextBlock = FSM.initialStateBlock(points)
                }


                /// A FSM state as a block.
                private var nextBlock: FSM.Block


                // MARK: : IteratorProtocol

                typealias Element = Points.Element


                mutating func next() -> Element? { nextBlock(&self) }


                // MARK: .FSM

                private class FSM {

                    typealias Block = (inout DistinctCoordinateIterator) -> Element?


                    private init(_ points: Points) {
                        iterator = points.makeIterator()
                    }


                    private var iterator: Points.Iterator


                    // MARK: States

                    static func initialStateBlock(_ points: Points) -> Block {
                        let fsm = FSM(points)

                        return { _self in
                            guard let first = fsm.iterator.next() else { return nil }

                            _self.nextBlock = regularStateBlock(fsm, first)

                            return first
                        }
                    }


                    private static func regularStateBlock(_ fsm: FSM, _ last: Points.Element) -> Block {
                        var last = last

                        return { _self in
                            while let next = fsm.iterator.next() {
                                if KvIs(next, inequalTo: last) {
                                    last = next
                                    return next
                                }
                            }

                            return nil
                        }
                    }

                }

            }

        }

    }

}



// MARK: .BConvex

extension KvMath2 {

    /// Simple implementation of convex shape equal to intersection of left halfspaces produced by given oriented lines.
    public struct BConvex {

        public let lines: [Line]


        public init(_ convex: ConvexPolygon) {
            var lines: [Line] = .init()

            let iterator = convex.ccwVertices.makeIterator()

            // No validation for line orientations assuming the convex vertices are valid.
            if let first = iterator.next() {
                var prev = first

                while let next = iterator.next() {
                    if let line = Line(prev, next) {
                        lines.append(line)
                    }
                    prev = next
                }

                if let line = Line(prev, first) {
                    lines.append(line)
                }
            }

            self.lines = lines
        }


        @inlinable
        public init(_ aabr: AABR) {
            lines = [
                .init(from: aabr.min                     , unitDirection: [  1,  0 ]),
                .init(from: .init(aabr.max.x, aabr.min.y), unitDirection: [  0,  1 ]),
                .init(from: aabr.max                     , unitDirection: [ -1,  0 ]),
                .init(from: .init(aabr.min.x, aabr.max.y), unitDirection: [  0, -1 ]),
            ]
        }


        /// - Parameter points: A sequenve of a convex polygon vertices in CCW or CW order.
        public init?<Points>(_ points: Points)
        where Points : Sequence, Points.Element == Position
        {
            var lines: [Line] = .init()

            var iterator = ConvexPolygon.VertexIterator(points)

            // Assuming the directions are nondegenerate.

            if let first = iterator.next() {
                let directionFactor: Scalar

                switch first.direction {
                case .ccw:
                    directionFactor = 1
                case .cw:
                    directionFactor = -1
                case .mixed, .invalid:
                    return nil
                }


                func AppendLine(from vertex: ConvexPolygon.VertexIterator<Points>.Element) {
                    lines.append(.init(from: vertex.coordinate, unitDirection: directionFactor * normalize(vertex.step)))
                }


                AppendLine(from: first)

                while let next = iterator.next() {
                    guard next.direction == first.direction else { return nil }

                    AppendLine(from: next)
                }
            }

            self.lines = lines
        }


        /// - Parameter points: Convex shape vertices in counterclockwise order.
        @inlinable
        public init?(_ points: Position...) {
            switch points.count {
            case 0, 1, 2:
                return nil
            case 3:
                self.init(points[0], points[1], points[2])
            default:
                self.init(points)
            }
        }


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

    @inlinable
    public static func abs<V>(_ v: V) -> V where V : KvSimdVector2, V.Scalar == Scalar {
        V(Swift.abs(v.x), Swift.abs(v.y))
    }

    @inlinable
    public static func acos(_ x: Scalar) -> Scalar { fatalError("Incomplete implementation") }

    @inlinable
    public static func asin(_ x: Scalar) -> Scalar { fatalError("Incomplete implementation") }

    @inlinable
    public static func atan(_ x: Scalar) -> Scalar { fatalError("Incomplete implementation") }

    @inlinable
    public static func atan2(_ x: Scalar, _ y: Scalar) -> Scalar { fatalError("Incomplete implementation") }

    @inlinable
    public static func clamp<V>(_ v: V, _ min: V, _ max: V) -> V where V : KvSimdVector2, V.Scalar == Scalar {
        V(x: KvMath.clamp(v.x, min.x, max.x),
          y: KvMath.clamp(v.y, min.y, max.y))
    }

    @inlinable
    public static func cos(_ x: Scalar) -> Scalar { fatalError("Incomplete implementation") }

    @inlinable
    public static func cospi(_ x: Scalar) -> Scalar { fatalError("Incomplete implementation") }

    @inlinable
    public static func distance<V>(_ x: V, _ y: V) -> Scalar where V : KvSimdVector2, V.Scalar == Scalar {
        length(y - x)
    }

    @inlinable
    public static func dot<V>(_ x: V, _ y: V) -> Scalar where V : KvSimdVector2, V.Scalar == Scalar {
        x.x * y.x + x.y * y.y
    }

    @inlinable
    public static func length<V>(_ v: V) -> Scalar where V : KvSimdVector2, V.Scalar == Scalar {
        dot(v, v).squareRoot()
    }

    @inlinable
    public static func length_squared<V>(_ v: V) -> Scalar where V : KvSimdVector2, V.Scalar == Scalar {
        dot(v, v)
    }

    @inlinable
    public static func max<V>(_ x: Vector, _ y: V) -> V where V : KvSimdVector2, V.Scalar == Scalar {
        V(x: Swift.max(x.x, y.x),
          y: Swift.max(x.y, y.y))
    }

    @inlinable
    public static func min<V>(_ x: V, _ y: V) -> V where V : KvSimdVector2, V.Scalar == Scalar {
        .init(x: Swift.min(x.x, y.x),
              y: Swift.min(x.y, y.y))
    }

    @inlinable
    public static func mix<V>(_ x: V, _ y: V, t: Scalar) -> V where V : KvSimdVector2, V.Scalar == Scalar {
        let oneMinusT: Scalar = 1 - t

        return V(x: x.x * oneMinusT + y.x * t,
                 y: x.y * oneMinusT + y.y * t)
    }

    @inlinable
    public static func normalize<V>(_ v: V) -> V where V : KvSimdVector2, V.Scalar == Scalar {
        v / length(v)
    }

    @inlinable
    public static func rsqrt<V>(_ v: V) -> V where V : KvSimdVector2, V.Scalar == Scalar {
        1 / (v * v).squareRoot()
    }

    @inlinable
    public static func sin(_ x: Vector) -> Vector { fatalError("Incomplete implementation") }

    @inlinable
    public static func sinpi(_ x: Vector) -> Vector { fatalError("Incomplete implementation") }

    @inlinable
    public static func tan(_ x: Vector) -> Vector { fatalError("Incomplete implementation") }

    @inlinable
    public static func tanpi(_ x: Vector) -> Vector { fatalError("Incomplete implementation") }

}



// MARK: SIMD where Scalar == Float

extension KvMath2 where Scalar == Float {

    @inlinable public static func abs(_ v: Vector) -> Vector { simd.abs(v) }

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    @inlinable public static func acos(_ x: Vector) -> Vector { simd.acos(x) }

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    @inlinable public static func asin(_ x: Vector) -> Vector { simd.asin(x) }

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    @inlinable public static func atan(_ x: Vector) -> Vector { simd.atan(x) }

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    @inlinable public static func atan2(_ x: Vector, _ y: Vector) -> Vector { simd.atan2(x, y) }

    @inlinable public static func clamp(_ v: Vector, _ min: Vector, _ max: Vector) -> Vector { simd_clamp(v, min, max) }

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    @inlinable public static func cos(_ x: Vector) -> Vector { simd.cos(x) }

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    @inlinable public static func cospi(_ x: Vector) -> Vector { simd.cospi(x) }

    @inlinable public static func distance(_ x: Vector, _ y: Vector) -> Scalar { simd.distance(x, y) }

    @inlinable public static func dot(_ x: Vector, _ y: Vector) -> Scalar { simd.dot(x, y) }

    @inlinable public static func length(_ v: Vector) -> Scalar { simd.length(v) }

    @inlinable public static func length_squared(_ v: Vector) -> Scalar { simd.length_squared(v) }

    @inlinable public static func max(_ x: Vector, _ y: Vector) -> Vector { simd_max(x, y) }

    @inlinable public static func min(_ x: Vector, _ y: Vector) -> Vector { simd_min(x, y) }

    @inlinable public static func mix(_ x: Vector, _ y: Vector, t: Scalar) -> Vector { simd.mix(x, y, t: t) }

    @inlinable public static func normalize(_ v: Vector) -> Vector { simd.normalize(v) }

    @inlinable public static func rsqrt(_ v: Vector) -> Vector { simd.rsqrt(v) }

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    @inlinable public static func sin(_ x: Vector) -> Vector { simd.sin(x) }

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    @inlinable public static func sinpi(_ x: Vector) -> Vector { simd.sinpi(x) }

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    @inlinable public static func tan(_ x: Vector) -> Vector { simd.tan(x) }

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    @inlinable public static func tanpi(_ x: Vector) -> Vector { simd.tanpi(x) }

}



// MARK: SIMD where Scalar == Double

extension KvMath2 where Scalar == Double {

    @inlinable public static func abs(_ v: Vector) -> Vector { simd.abs(v) }

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    @inlinable public static func acos(_ x: Vector) -> Vector { simd.acos(x) }

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    @inlinable public static func asin(_ x: Vector) -> Vector { simd.asin(x) }

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    @inlinable public static func atan(_ x: Vector) -> Vector { simd.atan(x) }

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    @inlinable public static func atan2(_ x: Vector, _ y: Vector) -> Vector { simd.atan2(x, y) }

    @inlinable public static func clamp(_ v: Vector, _ min: Vector, _ max: Vector) -> Vector { simd_clamp(v, min, max) }

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    @inlinable public static func cos(_ x: Vector) -> Vector { simd.cos(x) }

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    @inlinable public static func cospi(_ x: Vector) -> Vector { simd.cospi(x) }

    @inlinable public static func distance(_ x: Vector, _ y: Vector) -> Scalar { simd.distance(x, y) }

    @inlinable public static func dot(_ x: Vector, _ y: Vector) -> Scalar { simd.dot(x, y) }

    @inlinable public static func length(_ v: Vector) -> Scalar { simd.length(v) }

    @inlinable public static func length_squared(_ v: Vector) -> Scalar { simd.length_squared(v) }

    @inlinable public static func max(_ x: Vector, _ y: Vector) -> Vector { simd_max(x, y) }

    @inlinable public static func min(_ x: Vector, _ y: Vector) -> Vector { simd_min(x, y) }

    @inlinable public static func mix(_ x: Vector, _ y: Vector, t: Scalar) -> Vector { simd.mix(x, y, t: t) }

    @inlinable public static func normalize(_ v: Vector) -> Vector { simd.normalize(v) }

    @inlinable public static func rsqrt(_ v: Vector) -> Vector { simd.rsqrt(v) }

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    @inlinable public static func sin(_ x: Vector) -> Vector { simd.sin(x) }

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    @inlinable public static func sinpi(_ x: Vector) -> Vector { simd.sinpi(x) }

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    @inlinable public static func tan(_ x: Vector) -> Vector { simd.tan(x) }

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    @inlinable public static func tanpi(_ x: Vector) -> Vector { simd.tanpi(x) }

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
public func KvIs<Scalar>(_ lhs: KvMath2<Scalar>.Matrix, equalTo rhs: KvMath2<Scalar>.Matrix) -> Bool
where Scalar : KvMathFloatingPoint
{
    KvIsZero(KvMath2.max(KvMath2.abs(lhs - rhs)))
}


@inlinable
public func KvIs<Scalar>(_ lhs: KvMath2<Scalar>.Matrix, inequalTo rhs: KvMath2<Scalar>.Matrix) -> Bool
where Scalar : KvMathFloatingPoint
{
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
