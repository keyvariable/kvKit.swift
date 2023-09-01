//
//  KvSimdVectorTests.swift
//  KvKitTests
//
//  Created by Svyatoslav Popov on 23.05.2023.
//

import XCTest

@testable import kvKit
@testable import kvTestKit

import simd



class KvSimdVectorTests : XCTestCase {

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
