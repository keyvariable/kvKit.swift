//
//  KvMathScopeTests.swift
//  kvKit
//
//  Created by Svyatoslav Popov on 21.09.2022.
//

import XCTest

@testable import kvKit

import simd



class KvMathScopeTests : XCTestCase {

    typealias S<Math : KvMathScope> = Math.Scalar
    typealias V2<Math : KvMathScope> = Math.Vector2
    typealias V3<Math : KvMathScope> = Math.Vector3
    typealias V4<Math : KvMathScope> = Math.Vector4



    // MARK: : XCTestCase

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }


    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }



    // MARK: .TestCase

    private struct TestCase<Math : KvMathScope> {

        private init() { }


        // MARK: .Input1

        typealias Input1<T1, R> = (input: T1, expected: R)


        // MARK: .Input2

        typealias Input2<T1, T2, R> = (lhs: T1, rhs: T2, expected: R)

    }



    // MARK: isCoDirectional Test

    func testCoDirectional2() {

        func Run<Math : KvMathScope>(_ m: Math.Type) {
            let input: [TestCase<Math>.Input2<V2<Math>, V2<Math>, Bool>] = [
                (.zero, .zero, false),
                (.zero, .one, false),
                (.one, .zero, false),
                (.unitX, .zero, false),
                (.unitY, .zero, false),
                (.one, .one, true),
                (-.one, -.one, true),
                (.unitX, .unitNX, false),
                (.unitY, .unitNY, false),
                (-.one, .one, false),
                ([ 1, 0 ], [ 2, 0 ], true),
                ([ 0, 1 ], [ 0, 2 ], true),
                ([ 1, 1 ], [ 2, 2 ], true),
                ([ 1, 1 ], [ -2, -2 ], false),
                ([ 0.99, 1 ], [ 1, 1 ], false),
                (.init((1.0 as Math.Scalar).nextDown, (1.0 as Math.Scalar).nextUp), [ 10, 10 ], true),
            ]

            input.forEach { (lhs, rhs, expected) in
                XCTAssertEqual(Math.isCoDirectional(lhs, rhs), expected, "lhs = \(lhs); rhs = \(rhs)")
            }
        }

        Run(KvMathFloatScope.self)
        Run(KvMathDoubleScope.self)
    }

    func testCoDirectional3() {

        func Run<Math : KvMathScope>(_ m: Math.Type) {
            let input: [TestCase<Math>.Input2<V3<Math>, V3<Math>, Bool>] = [
                (.zero, .zero, false),
                (.zero, .one, false),
                (.one, .zero, false),
                (.unitX, .zero, false),
                (.unitY, .zero, false),
                (.unitZ, .zero, false),
                (.one, .one, true),
                (-.one, -.one, true),
                (.unitX, .unitNX, false),
                (.unitY, .unitNY, false),
                (.unitZ, .unitNZ, false),
                (-.one, .one, false),
                ([ 1, 0, 0 ], [ 2, 0, 0 ], true),
                ([ 0, 1, 0 ], [ 0, 2, 0 ], true),
                ([ 0, 0, 1 ], [ 0, 0, 2 ], true),
                ([ 1, 1, 1 ], [ 2, 2, 2 ], true),
                ([ 1, 1, 1 ], [ -2, -2, -2 ], false),
                ([ 0.99, 1, 1 ], [ 1, 1, 1 ], false),
                (.init((1.0 as Math.Scalar).nextDown, (1.0 as Math.Scalar).nextUp, (1.0 as Math.Scalar).nextDown), [ 10, 10, 10 ], true),
            ]

            input.forEach { (lhs, rhs, expected) in
                XCTAssertEqual(Math.isCoDirectional(lhs, rhs), expected, "lhs = \(lhs); rhs = \(rhs)")
            }
        }

        Run(KvMathFloatScope.self)
        Run(KvMathDoubleScope.self)
    }

    func testCoDirectional4() {

        func Run<Math : KvMathScope>(_ m: Math.Type) {
            let input: [TestCase<Math>.Input2<V4<Math>, V4<Math>, Bool>] = [
                (.zero, .zero, false),
                (.zero, .one, false),
                (.one, .zero, false),
                (.unitX, .zero, false),
                (.unitY, .zero, false),
                (.unitZ, .zero, false),
                (.unitW, .zero, false),
                (.one, .one, true),
                (-.one, -.one, true),
                (.unitX, .unitNX, false),
                (.unitY, .unitNY, false),
                (.unitZ, .unitNZ, false),
                (.unitW, .unitNW, false),
                (-.one, .one, false),
                ([ 1, 0, 0, 0 ], [ 2, 0, 0, 0 ], true),
                ([ 0, 1, 0, 0 ], [ 0, 2, 0, 0 ], true),
                ([ 0, 0, 1, 0 ], [ 0, 0, 2, 0 ], true),
                ([ 0, 0, 0, 1 ], [ 0, 0, 0, 2 ], true),
                ([ 1, 1, 1, 1 ], [ 2, 2, 2, 2 ], true),
                ([ 1, 1, 1, 1 ], [ -2, -2, -2, -2 ], false),
                ([ 0.99, 1, 1, 1 ], [ 1, 1, 1, 1 ], false),
                (.init((1.0 as Math.Scalar).nextDown, (1.0 as Math.Scalar).nextUp, (1.0 as Math.Scalar).nextDown, (1.0 as Math.Scalar).nextUp), [ 10, 10, 10, 10 ], true),
            ]

            input.forEach { (lhs, rhs, expected) in
                XCTAssertEqual(Math.isCoDirectional(lhs, rhs), expected, "lhs = \(lhs); rhs = \(rhs)")
            }
        }

        Run(KvMathFloatScope.self)
        Run(KvMathDoubleScope.self)
    }



    // MARK: isZero Tests

    func testIsZero2() {

        func Run<Math : KvMathScope>(_ math: Math.Type)
        where Math.Scalar.RawSignificand : FixedWidthInteger
        {
            let input1: [TestCase<Math>.Input1<V2<Math>, Bool>] = [
                (.zero, true),
                ([ 1e-20, 0.0 ], true),
                (.init(repeating: 1e-20), true),
                ([ 1e-3, 0.0 ], false),
                (.init(repeating: 1e-3), false),
                ([ 1.0, 0.0 ], false),
                (.one, false),
            ]

            input1.forEach { (input, expected) in
                XCTAssertEqual(Math.isZero(input), expected, "input = \(input); expected = \(expected)")
            }

            let bound = 2 * KvUlp(of: 1 as S<Math>)
            let range = -bound...bound

            (0 ..< 10_000)
                .lazy.map { _ in V2<Math>(.random(in: range), .random(in: range)) }
                .forEach { input in
                    XCTAssertEqual(Math.isZero(input), !Math.isNonzero(input), "input = \(input)")
                }
        }

        Run(KvMathFloatScope.self)
        Run(KvMathDoubleScope.self)
    }

    func testIsZero3() {

        func Run<Math : KvMathScope>(_ math: Math.Type)
        where Math.Scalar.RawSignificand : FixedWidthInteger
        {
            let input1: [TestCase<Math>.Input1<V3<Math>, Bool>] = [
                (.zero, true),
                ([ 1e-20, 0.0, 0.0 ], true),
                (.init(repeating: 1e-20), true),
                ([ 1e-3, 0.0, 0.0 ], false),
                (.init(repeating: 1e-3), false),
                ([ 1.0, 0.0, 0.0 ], false),
                (.one, false),
            ]

            input1.forEach { (input, expected) in
                XCTAssertEqual(Math.isZero(input), expected, "input = \(input); expected = \(expected)")
            }

            let bound = 2 * KvUlp(of: 1 as S<Math>)
            let range = -bound...bound

            (0 ..< 10_000)
                .lazy.map { _ in V3<Math>(.random(in: range), .random(in: range)) }
                .forEach { input in
                    XCTAssertEqual(Math.isZero(input), !Math.isNonzero(input), "input = \(input)")
                }
        }

        Run(KvMathFloatScope.self)
        Run(KvMathDoubleScope.self)
    }

    func testIsZero4() {

        func Run<Math : KvMathScope>(_ math: Math.Type)
        where Math.Scalar.RawSignificand : FixedWidthInteger
        {
            let input1: [TestCase<Math>.Input1<V4<Math>, Bool>] = [
                (.zero, true),
                ([ 1e-20, 0.0, 0.0, 0.0 ], true),
                (.init(repeating: 1e-20), true),
                ([ 1e-3, 0.0, 0.0, 0.0 ], false),
                (.init(repeating: 1e-3), false),
                ([ 1.0, 0.0, 0.0, 0.0 ], false),
                (.one, false),
            ]

            input1.forEach { (input, expected) in
                XCTAssertEqual(Math.isZero(input), expected, "input = \(input); expected = \(expected)")
            }

            let bound = 2 * KvUlp(of: 1 as S<Math>)
            let range = -bound...bound

            (0 ..< 10_000)
                .lazy.map { _ in V4<Math>(.random(in: range), .random(in: range)) }
                .forEach { input in
                    XCTAssertEqual(Math.isZero(input), !Math.isNonzero(input), "input = \(input)")
                }
        }

        Run(KvMathFloatScope.self)
        Run(KvMathDoubleScope.self)
    }



    // MARK: safeNormalize Tests

    func testSafeNormalize2() {

        func Run<Math : KvMathScope>(_ math: Math.Type) {
            let nomalizedOne = Math.normalize(V2<Math>.one)
            let input: [TestCase<Math>.Input1<V2<Math>, V2<Math>?>] = [
                (.zero, nil),
                (.one, nomalizedOne),
                (.one * 10, nomalizedOne),
                (.one * -10, -nomalizedOne),
                (.unitX, .unitX),
            ]

            input.forEach { (input, expected) in
                assertEqual(Math.self, Math.safeNormalize(input), expected)
            }
        }

        Run(KvMathFloatScope.self)
        Run(KvMathDoubleScope.self)
    }

    func testSafeNormalize3() {

        func Run<Math : KvMathScope>(_ math: Math.Type) {
            let nomalizedOne = Math.normalize(V3<Math>.one)
            let input: [TestCase<Math>.Input1<V3<Math>, V3<Math>?>] = [
                (.zero, nil),
                (.one, nomalizedOne),
                (.one * 10, nomalizedOne),
                (.one * -10, -nomalizedOne),
                (.unitX, .unitX),
            ]

            input.forEach { (input, expected) in
                assertEqual(Math.self, Math.safeNormalize(input), expected)
            }
        }

        Run(KvMathFloatScope.self)
        Run(KvMathDoubleScope.self)
    }

    func testSafeNormalize4() {

        func Run<Math : KvMathScope>(_ math: Math.Type) {
            let nomalizedOne = Math.normalize(V4<Math>.one)
            let input: [TestCase<Math>.Input1<V4<Math>, V4<Math>?>] = [
                (.zero, nil),
                (.one, nomalizedOne),
                (.one * 10, nomalizedOne),
                (.one * -10, -nomalizedOne),
                (.unitX, .unitX),
            ]

            input.forEach { (input, expected) in
                assertEqual(Math.self, Math.safeNormalize(input), expected)
            }
        }

        Run(KvMathFloatScope.self)
        Run(KvMathDoubleScope.self)
    }



    // MARK: Auxiliaries

    private func assertEqual<Math : KvMathScope>(_ math: Math.Type, _ lhs: V2<Math>, _ rhs: V2<Math>, message: @autoclosure () -> String = "") {
        XCTAssert(Math.isEqual(lhs, rhs), [ message(), "Math.isEqual(lhs, rhs) != true, where", "\(lhs)", "\(rhs)" ].filter { !$0.isEmpty }.joined(separator: "\n\t"))
    }

    private func assertEqual<Math : KvMathScope>(_ math: Math.Type, _ lhs: V3<Math>, _ rhs: V3<Math>, message: @autoclosure () -> String = "") {
        XCTAssert(Math.isEqual(lhs, rhs), [ message(), "Math.isEqual(lhs, rhs) != true, where", "\(lhs)", "\(rhs)" ].filter { !$0.isEmpty }.joined(separator: "\n\t"))
    }

    private func assertEqual<Math : KvMathScope>(_ math: Math.Type, _ lhs: V4<Math>, _ rhs: V4<Math>, message: @autoclosure () -> String = "") {
        XCTAssert(Math.isEqual(lhs, rhs), [ message(), "Math.isEqual(lhs, rhs) != true, where", "\(lhs)", "\(rhs)" ].filter { !$0.isEmpty }.joined(separator: "\n\t"))
    }

    private func assertEqual<Math : KvMathScope>(_ math: Math.Type, _ lhs: V2<Math>?, _ rhs: V2<Math>?, message: @autoclosure () -> String = "") {
        XCTAssert(lhs.flatMap { lhs in rhs.map { rhs in Math.isEqual(lhs, rhs) } } ?? (rhs == nil),
                  [ message(), "Math.isEqual(lhs, rhs) != true, where", "\(KvStringKit.with(lhs))", "\(KvStringKit.with(rhs))" ].filter { !$0.isEmpty }.joined(separator: "\n\t"))
    }

    private func assertEqual<Math : KvMathScope>(_ math: Math.Type, _ lhs: V3<Math>?, _ rhs: V3<Math>?, message: @autoclosure () -> String = "") {
        XCTAssert(lhs.flatMap { lhs in rhs.map { rhs in Math.isEqual(lhs, rhs) } } ?? (rhs == nil),
                  [ message(), "Math.isEqual(lhs, rhs) != true, where", "\(KvStringKit.with(lhs))", "\(KvStringKit.with(rhs))" ].filter { !$0.isEmpty }.joined(separator: "\n\t"))
    }

    private func assertEqual<Math : KvMathScope>(_ math: Math.Type, _ lhs: V4<Math>?, _ rhs: V4<Math>?, message: @autoclosure () -> String = "") {
        XCTAssert(lhs.flatMap { lhs in rhs.map { rhs in Math.isEqual(lhs, rhs) } } ?? (rhs == nil),
                  [ message(), "Math.isEqual(lhs, rhs) != true, where", "\(KvStringKit.with(lhs))", "\(KvStringKit.with(rhs))" ].filter { !$0.isEmpty }.joined(separator: "\n\t"))
    }

}
