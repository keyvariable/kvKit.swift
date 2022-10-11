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
//  KvTransformTests.swift
//  kvKit
//
//  Created by Svyatoslav Popov on 11.10.2022.
//

import XCTest

@testable import kvKit



class KvTransformTests : XCTestCase {

    typealias T2<Math : KvMathScope> = KvTransform2<Math>
    typealias AT2<Math : KvMathScope> = KvAffineTransform2<Math>

    typealias T3<Math : KvMathScope> = KvTransform3<Math>
    typealias AT3<Math : KvMathScope> = KvAffineTransform3<Math>



    // MARK: : XCTestCase

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }


    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }



    // MARK: Rotation+Translation Tests

    func testTR() {

        func RunT2<Math : KvMathScope>(_ math: Math.Type, _ translation: Math.Vector2, _ angle: Math.Scalar, expected: T2<Math>) {
            assertEqual(.init(translation: translation, angle: angle), expected)
        }

        func RunT3<Math : KvMathScope>(_ math: Math.Type, _ translation: Math.Vector3, _ quaternion: Math.Quaternion, expected: T3<Math>) {
            assertEqual(.init(translation: translation, quaternion: quaternion), expected)
        }

        // TODO: Complete tests
        func Run<Math : KvMathScope>(_ math: Math.Type) {
            RunT2(math, .zero, 0.0, expected: .identity)

            let t3: Math.Vector3 = [ 1, 2, 3 ]

            RunT3(math, .zero, .zeroAngle, expected: .identity)
            RunT3(math, .zero, .init(from: .unitY, to: .unitY), expected: .identity)
            RunT3(math, t3, .init(from: .unitY, to: .unitY), expected: .identity.translated(by: t3))
        }

        Run(KvMathFloatScope.self)
        Run(KvMathDoubleScope.self)
    }



    // MARK: Auziliaries

    private func assertEqual<Math : KvMathScope>(_ lhs: T2<Math>, _ rhs: T2<Math>, message: @autoclosure () -> String = "") {
        XCTAssert(lhs.isEqual(to: rhs), [ message(), "lhs.isEqual(to: rhs) != true, where", "\(lhs)", "\(rhs)" ].filter { !$0.isEmpty }.joined(separator: "\n\t"))
    }

    private func assertEqual<Math : KvMathScope>(_ lhs: AT2<Math>, _ rhs: AT2<Math>, message: @autoclosure () -> String = "") {
        XCTAssert(lhs.isEqual(to: rhs), [ message(), "lhs.isEqual(to: rhs) != true, where", "\(lhs)", "\(rhs)" ].filter { !$0.isEmpty }.joined(separator: "\n\t"))
    }

    private func assertEqual<Math : KvMathScope>(_ lhs: T3<Math>, _ rhs: T3<Math>, message: @autoclosure () -> String = "") {
        XCTAssert(lhs.isEqual(to: rhs), [ message(), "lhs.isEqual(to: rhs) != true, where", "\(lhs)", "\(rhs)" ].filter { !$0.isEmpty }.joined(separator: "\n\t"))
    }

    private func assertEqual<Math : KvMathScope>(_ lhs: AT3<Math>, _ rhs: AT3<Math>, message: @autoclosure () -> String = "") {
        XCTAssert(lhs.isEqual(to: rhs), [ message(), "lhs.isEqual(to: rhs) != true, where", "\(lhs)", "\(rhs)" ].filter { !$0.isEmpty }.joined(separator: "\n\t"))
    }

}
