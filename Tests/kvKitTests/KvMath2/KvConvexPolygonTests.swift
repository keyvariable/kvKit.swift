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
//  KvConvexPolygonTests.swift
//  kvKit
//
//  Created by Svyatoslav Popov on 14.09.2022.
//

import XCTest

@testable import kvKit

import simd



class KvMath2ConvexPolygonTests : XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }


    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }


    // MARK: .TestCase

    private struct TestCase<T : KvMathFloatingPoint> {

        typealias Math2 = KvMath2<T>

        typealias Convex = Math2.ConvexPolygon
        typealias Vertex = Math2.Position


        let input: [Vertex]

        let result: ExpectedResult


        // MARK: .Result

        struct ExpectedResult : Equatable {

            var polygon: [Convex.VertexIterator<[Vertex]>.PolygonVertexIterator.Element]
            var convex: [Convex.VertexIterator<[Vertex]>.Element]

        }


        // MARK: Operations

        func run(_ messagePrefix: String) {

            func AssertElementsEqual<Result, Expectation>(
                _ results: Result,
                _ expectations: Expectation,
                _ messagePrefix: String,
                by isEqualBlock: (Result.Element, Expectation.Element) -> Bool
            ) where Result : Sequence, Expectation : Sequence
            {
                var resultIterator = results.makeIterator()
                var expectationIterator = expectations.makeIterator()
                var index = 0

                while true {
                    defer { index += 1}

                    switch (resultIterator.next(), expectationIterator.next()) {
                    case (.some(let result), .some(let expectation)):
                        guard isEqualBlock(result, expectation)
                        else { return XCTFail("\(messagePrefix): index = \(index), result = \(result), expectation = \(expectation)") }
                    case (.some(let result), .none):
                        return XCTFail("\(messagePrefix): there are more results than expected (\(index)). Result at \(index): \(result)")
                    case (.none, .some(let expectation)):
                        return XCTFail("\(messagePrefix): there are less results (\(index)) than expected. Expectation at \(index): \(expectation)")
                    case (.none, .none):
                        return
                    }
                }
            }


            do {
                let polygonResults = IteratorSequence(Convex.VertexIterator.PolygonVertexIterator(input))

                AssertElementsEqual(polygonResults, result.polygon, "\(messagePrefix), polygon vertices and local directions") {
                    $0.isAlmostEqual(to: $1)
                }
            }
            do {
                let convexResults = IteratorSequence(Convex.VertexIterator(input))

                AssertElementsEqual(convexResults, result.convex, "\(messagePrefix), convex vertices and direction") {
                    $0.isAlmostEqual(to: $1)
                }
            }
        }

    }


    // MARK: Empty Input Test

    func testEmptyInput() throws {

        func MakeTestCase<T : KvMathFloatingPoint>(_ type: T.Type) -> TestCase<T> {
            TestCase<T>(
                input: [ ],
                result: .init(polygon: [ ], convex: [ ])
            )
        }

        let prefix = "Empty input"

        MakeTestCase(Float.self).run(prefix)
        MakeTestCase(Double.self).run(prefix)
    }


    // MARK: Single Vertex Input Test

    func testSingleVertexInput() throws {

        func MakeTestCase<T : KvMathFloatingPoint>(_ type: T.Type) -> TestCase<T> {
            let input: [ KvMath2<T>.Position ] = [ .zero ]
            let output = Self.coordinatesAndSteps(from: input)

            return .init(
                input: input,
                result: .init(
                    polygon: output.map { $0.polygonElement(.degenerate) },
                    convex: output.map { $0.convexElement(.invalid) }
                )
            )
        }

        let prefix = "Single vertex"

        MakeTestCase(Float.self).run(prefix)
        MakeTestCase(Double.self).run(prefix)
    }


    // MARK: Repeated Vertex Input Test

    func testRepeatedVertexInput() throws {

        func MakeTestCase<T : KvMathFloatingPoint>(_ type: T.Type) -> TestCase<T> {
            let input: [ KvMath2<T>.Position ] = [ .zero, .zero, .zero ]
            let output = Self.coordinatesAndSteps(from: input).prefix(1)

            return .init(
                input: input,
                result: .init(
                    polygon: output.map { $0.polygonElement(.degenerate) },
                    convex: output.map { $0.convexElement(.invalid) }
                )
            )
        }

        let prefix = "Repeated vertex"

        MakeTestCase(Float.self).run(prefix)
        MakeTestCase(Double.self).run(prefix)
    }


    // MARK: Two Vertices Input Test

    func testTwoVerticesInput1() throws {

        func MakeTestCase<T : KvMathFloatingPoint>(_ type: T.Type) -> TestCase<T> {
            let input: [ KvMath2<T>.Position ] = [ .one, .zero ]
            let output = Self.coordinatesAndSteps(from: input).prefix(1)

            return .init(
                input: input,
                result: .init(
                    polygon: output.map { $0.polygonElement(.degenerate) },
                    convex: output.map { $0.convexElement(.invalid) }
                )
            )
        }

        let prefix = "Two vertices"

        MakeTestCase(Float.self).run(prefix)
        MakeTestCase(Double.self).run(prefix)
    }


    // MARK: Two Vertices then the Last is Repeated Input Test

    func testTwoVerticesInput2() throws {

        func MakeTestCase<T : KvMathFloatingPoint>(_ type: T.Type) -> TestCase<T> {
            let input: [ KvMath2<T>.Position ] = [ .one, .zero, .zero, .zero ]
            let output = Self.coordinatesAndSteps(from: input.prefix(2)).prefix(1)

            return .init(
                input: [ .one, .zero, .zero, .zero ],
                result: .init(
                    polygon: output.map { $0.polygonElement(.degenerate) },
                    convex: output.map { $0.convexElement(.invalid) }
                )
            )
        }

        let prefix = "Two vertices + repeated last"

        MakeTestCase(Float.self).run(prefix)
        MakeTestCase(Double.self).run(prefix)
    }


    // MARK: Two Vertices then the first is Repeated Input Test

    func testTwoVerticesInput3() throws {

        func MakeTestCase<T : KvMathFloatingPoint>(_ type: T.Type) -> TestCase<T> {
            let input: [ KvMath2<T>.Position ] = [ .one, .zero, .one, .one, .one ]
            let output = Self.coordinatesAndSteps(from: input).prefix(1)

            return .init(
                input: [ .one, .zero, .one, .one, .one ],
                result: .init(
                    polygon: output.map { $0.polygonElement(.degenerate) },
                    convex: output.map { $0.convexElement(.invalid) }
                )
            )
        }

        let prefix = "Two vertices + repeated first"

        MakeTestCase(Float.self).run(prefix)
        MakeTestCase(Double.self).run(prefix)
    }


    // MARK: Valid Polygon Test

    func testValidInput() throws {

        func MakeTestCase<T : KvMathFloatingPoint>(_ type: T.Type, isCCW: Bool, count: Int) throws -> TestCase<T> {
            let start, end: Double
            (start, end) = isCCW ? (0, 2 * .pi) : (2 * .pi, 0)

            let input = stride(from: start, to: end - sign(end - start) * 1e-3, by: (end - start) / Double(count))
                .map { KvMath2<T>.Position(T(cos($0)), T(sin($0))) }

            let output = Self.coordinatesAndSteps(from: input)

            return TestCase<T>(
                input: input,
                result: .init(
                    polygon: output.map { $0.polygonElement(isCCW: isCCW) },
                    convex: output.map { $0.convexElement(isCCW: isCCW) }
                )
            )
        }

        try [ 3, 4, 256 ].forEach { count in
            try [ true, false ].forEach { isCCW in
                let prefix = "Valid polygon (\(count), \(isCCW ? "CCW" : "CW"))"

                try MakeTestCase(Float.self , isCCW: isCCW, count: count).run(prefix)
                try MakeTestCase(Double.self, isCCW: isCCW, count: count).run(prefix)
            }
        }
    }


    // MARK: Nonconvex Polygon Test

    func testNonconvexInput() {

        func MakeTestCase<T : KvMathFloatingPoint>(_ type: T.Type, isCCW: Bool, shift: Int) -> TestCase<T> {
            typealias TC = TestCase<T>

            var input: [KvMath2<T>.Position] = [
                [  0.0, 0.0 ],
                [  0.5, 1.0 ],
                [  0.0, 0.5 ],
                [ -0.5, 1.0 ],
            ]
            var ccwFlags = [ true, true, false, true ]

            if !isCCW {
                input = Self.cyclicShiftedRight(input.reversed())
                ccwFlags.indices.forEach { ccwFlags[$0].toggle() }
            }

            input = Self.cyclicShiftedLeft(input, for: shift)
            ccwFlags = Self.cyclicShiftedLeft(ccwFlags, for: shift)

            let output = Self.coordinatesAndSteps(from: input)
            ccwFlags = Self.cyclicShiftedLeft(ccwFlags)

            var expectation = TC.ExpectedResult(
                polygon: zip(output, ccwFlags).map { $0.0.polygonElement(isCCW: $0.1) },
                convex: zip(output, ccwFlags)
                    .prefix(1 + ccwFlags.firstIndex(where: { $0 != ccwFlags[0] })!)
                    .map { $0.0.convexElement(isCCW: $0.1) }
            )

            expectation.convex[expectation.convex.endIndex - 1].direction = .mixed

            return .init(input: input, result: expectation)
        }

        (0..<4).forEach { shift in
            [ true, false ].forEach { isCCW in
                let prefix = "Nonconvex \(isCCW ? "CCW" : "CW") polygon shifted by \(shift)"

                MakeTestCase(Float.self , isCCW: isCCW, shift: shift).run(prefix)
                MakeTestCase(Double.self, isCCW: isCCW, shift: shift).run(prefix)
            }
        }
    }


    // MARK: Quad with a Backward Vertex Test

    func testBackwardVertex() {

        func MakeTestCase<T : KvMathFloatingPoint>(_ type: T.Type, isCCW: Bool, backIndex: Int) -> TestCase<T> {
            typealias TC = TestCase<T>

            var input = Self.quadVertices(T.self, isCCW: isCCW)

            // Insertion of backward case preserving the direction.
            do {
                let prevIndex = (backIndex > 0 ? backIndex : input.endIndex) - 1
                let c = input[backIndex]
                let offset = 0.1 * (c - input[prevIndex])

                input[backIndex] -= offset
                input.insert(c, at: backIndex)
            }

            let output = Self.coordinatesAndSteps(from: input).prefix(backIndex > 0 ? backIndex : input.count)

            let expectation: TC.ExpectedResult = {
                switch backIndex > 0 {
                case true:
                    let lastIndex = output.endIndex - 1

                    var expectation = TC.ExpectedResult(
                        polygon: output.map { $0.polygonElement(isCCW: isCCW) },
                        convex: output.map { $0.convexElement(isCCW: isCCW) }
                    )

                    expectation.polygon[lastIndex].direction = .degenerate
                    expectation.convex[lastIndex].direction = .invalid

                    return expectation

                case false:
                    let localDirections: [TC.Convex.LocalDirection] = isCCW ? [ .cw, .ccw, .ccw, .ccw, .degenerate ] : [ .ccw, .cw, .cw, .cw, .degenerate ]
                    let directions: [TC.Convex.Direction] = [ isCCW ? .cw : .ccw, .mixed ]

                    return .init(
                        polygon: zip(output, localDirections).map { $0.0.polygonElement($0.1) },
                        convex: zip(output, directions).map { $0.0.convexElement($0.1) }
                    )
                }
            }()

            return .init(input: input, result: expectation)
        }

        (0..<4).forEach { backIndex in
            [ true, false ].forEach { isCCW in
                let prefix = "Quad with back index (\(backIndex), \(isCCW ? "CCW" : "CW"))"

                MakeTestCase(Float.self , isCCW: isCCW, backIndex: backIndex).run(prefix)
                MakeTestCase(Double.self, isCCW: isCCW, backIndex: backIndex).run(prefix)
            }
        }
    }


    // MARK: Quad with Duplicated Vertices

    func testDuplicatedInput() {

        func MakeTestCase<T : KvMathFloatingPoint>(_ type: T.Type, isCCW: Bool, count: Int) -> TestCase<T> {
            let quad = Self.quadVertices(T.self, isCCW: isCCW)
            let input = Self.cyclicShiftedLeft(
                quad
                    .map { repeatElement($0, count: count) }
                    .joined()
            )

            let output = Self.coordinatesAndSteps(from: quad)

            return .init(input: input,
                         result: .init(polygon: output.map { $0.polygonElement(isCCW: isCCW) },
                                       convex: output.map { $0.convexElement(isCCW: isCCW) }))
        }

        [ 2, 3, 64 ].forEach { repeatCount in
            [ true, false ].forEach { isCCW in
                let prefix = "\(isCCW ? "CCW" : "CW") quad with \(repeatCount) copies of each vertex"

                MakeTestCase(Float.self , isCCW: isCCW, count: repeatCount).run(prefix)
                MakeTestCase(Double.self, isCCW: isCCW, count: repeatCount).run(prefix)
            }
        }
    }


    // MARK: Quad with Forward Vertices Test

    func testForwardVertices() {

        func MakeTestCase<T : KvMathFloatingPoint>(_ type: T.Type, isCCW: Bool, count: Int) -> TestCase<T> {
            let quad = Self.quadVertices(T.self, isCCW: isCCW)

            let step: Double = 1.0 / Double(1 + count)
            let offsets = stride(from: 0.0, to: 1.0 - 1e-4, by: step)
                .lazy.map { T($0) }

            let input = zip(quad, Self.cyclicShiftedLeft(quad))
                .map { (start, end) in offsets.map { KvMath2<T>.mix(start, end, t: $0) } }
                .joined()

            let output = Self.coordinatesAndSteps(from: quad)

            return .init(input: Array(input),
                         result: .init(polygon: output.map { $0.polygonElement(isCCW: isCCW) },
                                       convex: output.map { $0.convexElement(isCCW: isCCW) }))
        }

        [ 1, 2, 3, 64 ].forEach { count in
            [ true, false ].forEach { isCCW in
                let prefix = "\(isCCW ? "CCW" : "CW") quad with \(count) forward vertices on each edge"

                MakeTestCase(Float.self , isCCW: isCCW, count: count).run(prefix)
                MakeTestCase(Double.self, isCCW: isCCW, count: count).run(prefix)
            }
        }
    }


    // MARK: Quad with Forward Case at the End Test

    func testForwardAtTheEnd() {

        func MakeTestCase<T : KvMathFloatingPoint>(_ type: T.Type, isCCW: Bool, startCount: Int, endCount: Int) -> TestCase<T> {
            let quad = Self.quadVertices(T.self, isCCW: isCCW)

            let offsetsStart: [T] = {
                switch startCount > 0 {
                case true:
                    let step: Double = 0.5 / Double(startCount)
                    return stride(from: 0.5, to: 1.0 - 1e-4, by: step)
                        .map { T($0) }
                case false:
                    return [ ]
                }
            }()
            let offsetsEnd: [T] = {
                let step: Double = 0.5 / Double(1 + endCount)
                return stride(from: 0.0, to: 0.5 - 1e-4, by: step)
                    .map { T($0) }
            }()

            let v0 = quad.first!, v3 = quad.last!

            let input = [ offsetsStart.map { KvMath2<T>.mix(v3, v0, t: $0) },
                          quad.dropLast(),
                          offsetsEnd.map { KvMath2<T>.mix(v3, v0, t: $0) }, ]
                .joined()

            var output = Self.coordinatesAndSteps(from: quad)
            if startCount > 0 {
                output = Self.cyclicShiftedRight(output)
            }

            return .init(input: Array(input),
                         result: .init(polygon: output.map { $0.polygonElement(isCCW: isCCW) },
                                       convex: output.map { $0.convexElement(isCCW: isCCW) }))
        }

        [ 0, 1, 2, 8 ].forEach { count in
            (0...count).forEach { startCount in
                [ true, false ].forEach { isCCW in
                    let endCount = count - startCount
                    let prefix = "\(isCCW ? "CCW" : "CW") quad with \(startCount) forward cases at the start and \(endCount) at the end"

                    MakeTestCase(Float.self , isCCW: isCCW, startCount: startCount, endCount: endCount).run(prefix)
                    MakeTestCase(Double.self, isCCW: isCCW, startCount: startCount, endCount: endCount).run(prefix)
                }
            }
        }
    }


    // MARK: .CoordinateAndStep

    private struct CoordinateAndStep<T : KvMathFloatingPoint> : Hashable {

        typealias Convex = KvMath2<T>.ConvexPolygon

        typealias PolygonElement<Points> = Convex.VertexIterator<Points>.PolygonVertexIterator.Element
        where Points : Sequence, Points.Element == KvMath2<T>.Position

        typealias ConvexElement<Points> = Convex.VertexIterator<Points>.Element
        where Points : Sequence, Points.Element == KvMath2<T>.Position


        var coordinate: KvMath2<T>.Position
        var step: KvMath2<T>.Vector


        // MARK: Operations

        func polygonElement<Points>(_ direction: Convex.LocalDirection) -> PolygonElement<Points>
        where Points : Sequence, Points.Element == KvMath2<T>.Position
        {
            .init(coordinate: coordinate, step: step, direction: direction)
        }

        func polygonElement<Points>(isCCW: Bool) -> PolygonElement<Points>
        where Points : Sequence, Points.Element == KvMath2<T>.Position
        {
            .init(coordinate: coordinate, step: step, direction: isCCW ? .ccw : .cw)
        }


        func convexElement<Points>(_ direction: Convex.Direction) -> ConvexElement<Points>
        where Points : Sequence, Points.Element == KvMath2<T>.Position
        {
            .init(coordinate: coordinate, step: step, direction: direction)
        }

        func convexElement<Points>(isCCW: Bool) -> ConvexElement<Points>
        where Points : Sequence, Points.Element == KvMath2<T>.Position
        {
            .init(coordinate: coordinate, step: step, direction: isCCW ? .ccw : .cw)
        }

    }


    // MARK: Auxiliaries

    private static func quadVertices<T : KvMathFloatingPoint>(_ type: T.Type, isCCW: Bool) -> [KvMath2<T>.Position] {
        return (isCCW
                ? [ [ 0, 0 ], [ 1, 0 ], [ 1, 1 ], [ 0, 1 ] ]
                : [ [ 0, 0 ], [ 0, 1 ], [ 1, 1 ], [ 1, 0 ] ])
    }


    private static func coordinatesAndSteps<Scalar, Points>(from input: Points) -> [CoordinateAndStep<Scalar>]
    where Scalar : KvMathFloatingPoint, Points : Sequence, Points.Element == KvMath2<Scalar>.Position
    {
        let cooedinates = cyclicShiftedLeft(input)

        return zip(cooedinates, cyclicShiftedLeft(cooedinates))
            .map { .init(coordinate: $0.0, step: $0.1 - $0.0) }
    }


    /// - Returns: Copy of given sequence where first element is moved to the end. E.g. [ 1, 2 , 3, ...] -> [ 2, 3, ..., 1 ].
    private static func cyclicShiftedLeft<S : Sequence>(_ sequence: S) -> [S.Element] {
        var iterator = sequence.makeIterator()

        guard let first = iterator.next() else { return .init() }

        var result = Array(IteratorSequence(iterator))

        result.append(first)

        return result
    }


    /// - Returns: Copy of given sequence where last element is moved to the start. E.g. [ 1, 2 , 3, ..., n] -> [ n, 1, 2, 3, ... ].
    private static func cyclicShiftedRight<S : Sequence>(_ sequence: S) -> [S.Element] {
        var iterator = sequence.makeIterator()

        guard var prev = iterator.next() else { return .init() }

        var result: [S.Element] = .init()

        while let next = iterator.next() {
            result.append(prev)
            prev = next
        }

        result.insert(prev, at: 0)

        return result
    }


    /// - Returns: Copy of given sequence where first element is moved to the end. E.g. [ 1, 2 , 3, ...] -> [ 2, 3, ..., 1 ].
    private static func cyclicShiftedLeft<C : Collection>(_ collection: C, for shift: Int = 1) -> [C.Element] {
        return Array(
            [ collection.suffix(collection.count - shift),
              collection.prefix(shift), ]
                .joined()
        )
    }


    /// - Returns: Copy of given sequence where last element is moved to the start. E.g. [ 1, 2 , 3, ..., n] -> [ n, 1, 2, 3, ... ].
    private static func cyclicShiftedRight<C : Collection>(_ collection: C, for shift: Int = 1) -> [C.Element] {
        return Array(
            [ collection.suffix(shift),
              collection.prefix(collection.count - shift), ]
                .joined()
        )
    }

}
