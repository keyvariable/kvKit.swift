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
//  KvPlane3Tests.swift
//  kvKit
//
//  Created by Svyatoslav Popov on 12.10.2022.
//

import XCTest

@testable import kvKit



class KvPlane3Tests : XCTestCase {

    // MARK: : XCTestCase

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }


    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }



    // MARK: Plane-plane Intersection Test

    func testIntersectionWithPlane() {

        func Run<Math : KvMathScope>(_ math: Math.Type) {
            typealias P = KvPlane3<Math>
            typealias L = KvLine3<Math>

            let sqrt1_2 = (0.5 as Math.Scalar).squareRoot()

            let cases: [(lhs: P, rhs: P, expected: L?)] = [
                (P(normal: [ 0, 1, 0 ], d: 0), P(normal: [ 0, -sqrt1_2, sqrt1_2 ], d: 0), L(in: [ 1, 0, 0 ], at: .zero)),
                (P(normal: [ 0, 1, 0 ], d: 0), P(normal: [ 0, -sqrt1_2, sqrt1_2 ], d: -sqrt1_2), L(in: [ 1, 0, 0 ], at: [ 0, 0, 1 ])),
            ]

            cases.forEach { (lhs, rhs, expected) in
                KvAssertEqual(lhs.intersection(with: rhs), expected)
            }
        }

        Run(KvMathFloatScope.self)
        Run(KvMathDoubleScope.self)
    }

}
