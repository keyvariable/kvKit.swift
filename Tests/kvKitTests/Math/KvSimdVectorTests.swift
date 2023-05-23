//
//  KvSimdVectorTests.swift
//  kvKit
//
//  Created by Svyatoslav Popov on 23.05.2023.
//

import XCTest

@testable import kvKit
@testable import kvTestKit

import simd



class KvSimdVectorTests : XCTestCase {

    // MARK: : XCTestCase

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }


    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }



    // MARK: .testUnitRandom2

    func testUnitRandom2() {

        func Run<Math>(_ m: Math.Type) where Math : KvMathScope, Math.Scalar.RawSignificand : FixedWidthInteger {
            typealias Vector = Math.Vector2

            var generator = SystemRandomNumberGenerator()

            (0 ..< 32).forEach { _ in
                XCTAssertTrue(Math.isUnit(Vector.unitRandom()))
                XCTAssertTrue(Math.isUnit(Vector.unitRandom(using: &generator)))
            }
        }

        Run(KvMathFloatScope.self)
        Run(KvMathDoubleScope.self)
    }



    // MARK: .testUnitRandom3

    func testUnitRandom3() {

        func Run<Math>(_ m: Math.Type) where Math : KvMathScope, Math.Scalar.RawSignificand : FixedWidthInteger {
            typealias Vector = Math.Vector3

            var generator = SystemRandomNumberGenerator()

            (0 ..< 32).forEach { _ in
                XCTAssertTrue(Math.isUnit(Vector.unitRandom()))
                XCTAssertTrue(Math.isUnit(Vector.unitRandom(using: &generator)))
            }
        }

        Run(KvMathFloatScope.self)
        Run(KvMathDoubleScope.self)
    }

}
