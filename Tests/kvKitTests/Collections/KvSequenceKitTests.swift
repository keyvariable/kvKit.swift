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
//  KvSequenceKitTests.swift
//  kvKit
//
//  Created by Svyatoslav Popov on 26.10.2022.
//

import XCTest

@testable import kvKit



class KvSequenceKitTests : XCTestCase {

    // MARK: : XCTestCase

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }


    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }



    // MARK: PairIterator Test

    func testPairIterator() {
        let input = Array(0..<10)
        let output = IteratorSequence(KvSequenceKit.PairIterator(input))
        let expected = zip(input.dropLast(), input.dropFirst())

        XCTAssert(output.elementsEqual(expected, by: { $0.0 == $1.0 && $0.1 == $1.1 }))
    }



    // MARK: CyclicPairIterator Test

    func testCyclicPairIterator() {
        let input = Array(0..<10)
        let output = IteratorSequence(KvSequenceKit.CyclicPairIterator(input))
        let expected = zip(input, [ input[1...], input[..<1] ].joined())

        XCTAssert(output.elementsEqual(expected, by: { $0.0 == $1.0 && $0.1 == $1.1 }))
    }



    // MARK: PatternIterator Test

    func testPatternIterator() {
        let pattern = [ 1, 2, 3 ]

        XCTAssert(IteratorSequence(KvSequenceKit.PatternIterator(pattern, count: 0)).first(where: { _ in true }) == nil, "0 patterns")
        XCTAssert(pattern.elementsEqual(IteratorSequence(KvSequenceKit.PatternIterator(pattern, count: 1))), "1 pattern")

        let output = IteratorSequence(KvSequenceKit.PatternIterator(pattern, count: 3))
        let expected = [ pattern, pattern, pattern ].joined()

        XCTAssert(output.elementsEqual(expected), "3 patterns")
    }

}
