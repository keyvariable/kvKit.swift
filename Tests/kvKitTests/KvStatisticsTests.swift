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
        typealias NotedValue = KvStatistics.LocalMaximum<Double>.Stream<Int>.SourceValue

        let values: [NotedValue.Value] = [ 0, 1, 0, 1, 2, 1, 2, 3, 3, 2.9, 4, 3.99, 5, 0, 5.9999, 6, 5.9999, 6 ]
        let notedValues = values
            .enumerated().map { NotedValue($0.element, note: $0.offset) }

        let cases: [(threshold: NotedValue.Value, expectedResult: [NotedValue])] = [
            (1e-5, [ .init(1, note: 1), .init(2, note: 4), .init(3, note: 7), .init(4, note: 10), .init(5, note: 12), .init(6, note: 15), .init(6, note: 17) ]),
            (1e-3, [ .init(1, note: 1), .init(2, note: 4), .init(3, note: 7), .init(4, note: 10), .init(5, note: 12), .init(6, note: 15) ]),
            (1e-2, [ .init(1, note: 1), .init(2, note: 4), .init(3, note: 7), .init(5, note: 12), .init(6, note: 15) ]),
            (1e-1, [ .init(1, note: 1), .init(2, note: 4), .init(5, note: 12), .init(6, note: 15) ]),
        ]

        for (threshold, expectedResult) in cases {
            do {
                var result: [NotedValue.Value] = .init()
                KvStatistics.LocalMaximum.run(with: values, threshold: threshold) { value, stopFlag in
                    result.append(value)
                }

                XCTAssertEqual(result, expectedResult.map { $0.value }, "LocalMaximum.run(threshold: \(threshold), no notes)")
            }
            do {
                var result: [NotedValue] = .init()
                var stream = KvStatistics.LocalMaximum<Double>.Stream(threshold: .relative(1 - threshold)) {
                    result.append($0)
                }

                stream.processAndReset(notedValues)

                XCTAssertEqual(result, expectedResult, "LocalMaximum.Stream(threshold: .relative(\(1 - threshold)), no notes)")
            }
        }
    }

}
