//===----------------------------------------------------------------------===//
//
//  Copyright (c) 2022 Svyatoslav Popov (info@keyvar.com).
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
//  KvArrayKitTests.swift
//  kvKit
//
//  Created by Svyatoslav Popov on 09.10.2022.
//

import XCTest

@testable import kvKit



class KvArrayKitTests : XCTestCase {

    // MARK: : XCTestCase

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }


    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }



    // MARK: .mutateAndFilter()

    func testMutateAndFilter() {

        func Run<T>(label: String, input: [T], expected: [T], predicate: (inout T) -> Bool)
        where T : Equatable {
            var array = input
            KvArrayKit.mutateAndFilter(&array, predicate)
            XCTAssertEqual(array, expected, label)
        }

        func Run<T, E>(label: String, input: [T], expected: E, predicate: (inout T) -> Bool)
        where T : Equatable, E : Sequence, E.Element == T {
            Run(label: label, input: input, expected: Array(expected), predicate: predicate)
        }


        (0...3).forEach { count in
            let input = [Int](unsafeUninitializedCapacity: count) { buffer, size in
                (0..<count).forEach { index in
                    buffer[index] = .random(in: 10...99)
                }
                size = count
            }
            let replacement = 0

            Run(label: "No replacement", input: input, expected: input, predicate: { _ in true })
            Run(label: "Total replacement", input: input, expected: .init(repeating: replacement, count: count), predicate: { $0 = replacement; return true })
            Run(label: "Total removal", input: input, expected: [ ], predicate: { _ in false })
            Run(label: "Replacement and total removal", input: input, expected: [ ], predicate: { $0 = replacement; return false })

            if let e = input.randomElement() {
                Run(label: "Remove random value", input: input, expected: input.filter({ $0 != e }), predicate: { $0 != e })
                Run(label: "Remove all but random value", input: input, expected: input.filter({ $0 == e }), predicate: { $0 == e })
            }
        }

    }

}
