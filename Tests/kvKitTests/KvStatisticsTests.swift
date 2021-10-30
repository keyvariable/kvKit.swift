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
//  KvStatisticsTests.swift
//  kvKit
//
//  Created by Svyatoslav Popov on 30.10.2021.
//

import XCTest

@testable import kvKit



final class KvStatisticsTests : XCTestCase {

    static var allTests = [
        ("LocalMaximum", testLocalMaximum),
    ]


    // MARK: LocalMaximum

    func testLocalMaximum() {
        typealias Value = Double

        let values: [Value] = [ 0, 1, 0, 1, 2, 1, 2, 3, 3, 2.9, 4, 3.99, 5, 0, 5.9999, 6, 5.9999, 6 ]

        let cases: [(threshold: Value, expectedResult: [Value])] = [
            (1e-5, [ 1, 2, 3, 4, 5, 6, 6 ]),
            (1e-3, [ 1, 2, 3, 4, 5, 6 ]),
            (1e-2, [ 1, 2, 3, 5, 6 ]),
            (1e-1, [ 1, 2, 5, 6 ]),
        ]

        for (threshold, expectedResult) in cases {
            do {
                var result: [Double] = .init()
                KvStatistics.LocalMaximum.run(with: values, threshold: threshold) { value, stopFlag in
                    result.append(value)
                }

                XCTAssertEqual(result, expectedResult, "LocalMaximum.run(threshold: \(threshold))")
            }
            do {
                var result: [Double] = .init()
                var stream = KvStatistics.LocalMaximum<Double>.Stream(threshold: threshold) {
                    result.append($0)
                }

                stream.processAndFlush(values)

                XCTAssertEqual(result, expectedResult, "LocalMaximum.Stream(threshold: \(threshold))")
            }
        }
    }

}
