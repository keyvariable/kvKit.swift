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
//  KvLine3Tests.swift
//  
//
//  Created by Svyatoslav Popov on 28.09.2022.
//

import XCTest

@testable import kvKit



class KvLine3Tests : XCTestCase {

    // MARK: : XCTestCase

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }


    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }



    // MARK: Init with Direction and Coordinate Tests

    func testInitWithDirectionAndCoordinate() {

        func Run<Math : KvMathScope>(_ math: Math.Type) {
            typealias Line = KvLine3<Math>

            /// Quaternion when line contains the origin.
            let q1 = Math.Quaternion(from: Line.front, to: Math.normalize(.one))

            func AssertEqual(_ line: Line, _ expected: Line) {
                XCTAssert(line.isEqual(to: expected), "Resulting \(line) line is not equal to expected \(expected) line")
            }

            AssertEqual(Line(in: .one, at: .zero), Line(quaternion: q1, d: 0))
            AssertEqual(Line(in: .one, at: .one), Line(quaternion: q1, d: 0))

            AssertEqual(Line(in: .one, at: .unitX), Line(in: .one, at: [ 2, 1, 1 ]))

            AssertEqual(Line(in: [ 0, (0.5 as Math.Scalar).squareRoot(), 0 ], at: .zero), Line(quaternion: .init(angle: 0.5 * .pi, axis: .unitX), d: 0))
        }

        Run(KvMathFloatScope.self)
        Run(KvMathDoubleScope.self)
    }

}
