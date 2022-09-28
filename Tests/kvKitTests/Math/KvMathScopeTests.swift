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

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }


    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }


    // MARK: .TestCase

    private struct TestCase<Math : KvMathScope> {

        private init() { }


        // MARK: .Infix2

        typealias Infix2<T, R> = (lhs: T, rhs: T, result: R)

    }


    // MARK: isCoDirectional Test

    func testCoDirectional2() {

        func Run<Math : KvMathScope>(_ m: Math.Type) {
            let input: [TestCase<Math>.Infix2<Math.Vector2, Bool>] = [
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

            input.forEach { (lhs, rhs, result) in
                XCTAssertEqual(Math.isCoDirectional(lhs, rhs), result, "lhs = \(lhs); rhs = \(rhs)")
            }
        }

        Run(KvMathFloatScope.self)
        Run(KvMathDoubleScope.self)
    }

    func testCoDirectional3() {

        func Run<Math : KvMathScope>(_ m: Math.Type) {
            let input: [TestCase<Math>.Infix2<Math.Vector3, Bool>] = [
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

            input.forEach { (lhs, rhs, result) in
                XCTAssertEqual(Math.isCoDirectional(lhs, rhs), result, "lhs = \(lhs); rhs = \(rhs)")
            }
        }

        Run(KvMathFloatScope.self)
        Run(KvMathDoubleScope.self)
    }

    func testCoDirectional4() {

        func Run<Math : KvMathScope>(_ m: Math.Type) {
            let input: [TestCase<Math>.Infix2<Math.Vector4, Bool>] = [
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

            input.forEach { (lhs, rhs, result) in
                XCTAssertEqual(Math.isCoDirectional(lhs, rhs), result, "lhs = \(lhs); rhs = \(rhs)")
            }
        }

        Run(KvMathFloatScope.self)
        Run(KvMathDoubleScope.self)
    }

}
