//===----------------------------------------------------------------------===//
//
//  Copyright (c) 2021 Svyatoslav Popov (info@keyvar.com).
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
//  KvKitTests.swift
//  kvKit
//
//  Created by Svyatoslav Popov on 30.04.2020.
//

import XCTest

@testable import kvKit



final class KvKitTests: XCTestCase {

    static var allTests = [
        ("testKvIs", testKvIs),
        ("testStringKit", testStringKit),
    ]



    func testConsoleApplication() {

        class AppDelegate : KvConsoleApplicationDelegate {

            private(set) var checkpoints: Checkpoints = [ ]

            private let operationQueue = OperationQueue()


            // MARK: Checkpoints

            struct Checkpoints : OptionSet {

                static let shouldStart = Checkpoints(rawValue: 1 << 0)
                static let didStart = Checkpoints(rawValue: 1 << 1)
                static let willStop = Checkpoints(rawValue: 1 << 2)

                static let success = Checkpoints(rawValue: 1 << 3)


                let rawValue: UInt

            }


            // MARK: : KvConsoleApplicationDelegate

            func consoleApplicationShouldStart(_ application: KvConsoleApplication) -> Bool {
                checkpoints.insert(.shouldStart)

                return true
            }


            func consoleApplicationDidStart(_ application: KvConsoleApplication) {
                checkpoints.insert(.didStart)

                let n = 10000

                var sum = 0
                let mutationLock = NSLock()

                let operation = (1...n).reduce(into: BlockOperation(), { (operation, i) in
                    operation.addExecutionBlock {
                        KvThreadKit.locking(mutationLock) {
                            sum += 2 * i - 1
                        }
                    }
                })
                operation.completionBlock = {
                    defer { application.setNeedsStop() }

                    guard sum == n * n else { return }

                    self.checkpoints.insert(.success)
                }

                operationQueue.addOperation(operation)
            }


            func consoleApplicationWillStop(_ application: KvConsoleApplication) {
                checkpoints.insert(.willStop)
            }

        }


        let appDelegate = AppDelegate()

        KvConsoleApplication.main(with: appDelegate)

        XCTAssertTrue(appDelegate.checkpoints.contains(.shouldStart), "A test application has not invoked the delegate's consoleApplicationShouldStart(_:)")
        XCTAssertTrue(appDelegate.checkpoints.contains(.didStart), "A test application has not invoked the delegate's consoleApplicationDidStart(_:)")
        XCTAssertTrue(appDelegate.checkpoints.contains(.success), "A test application has not succeeded")
        XCTAssertTrue(appDelegate.checkpoints.contains(.willStop), "A test application has not invoked the delegate's consoleApplicationWillStop(_:)")
    }



    func testKvIs() {
        do {
            let cases: [(value: Int, result: Bool)] = [ (-2, false),
                                                        (-1, false),
                                                        ( 0, false),
                                                        ( 1, true ),
                                                        ( 2, true ),
                                                        ( 3, false),
                                                        ( 4, true ), ]

            cases.forEach {
                XCTAssertEqual(KvIsPowerOf2($0.value), $0.result, "KvIsPowerOf2(\($0.value)) != \($0.result)")
            }
        }

        do {
            let cases: [(value: Double, result: Bool)] = [ (-2.0    , false),
                                                           (-1.0    , false),
                                                           (-0.1    , false),
                                                           ( 0.0    , false),
                                                           ( 0.1    , false),
                                                           ( 0.25   , true ),
                                                           ( 0.25001, false),
                                                           ( 0.5    , true ),
                                                           ( 1.0    , true ),
                                                           ( 2.0    , true ),
                                                           ( 3.0    , false),
                                                           ( 4.0    , true ),
                                                           ( 4.5    , false), ]

            cases.forEach {
                XCTAssertEqual(KvIsPowerOf2($0.value), $0.result, "KvIsPowerOf2(\($0.value)) != \($0.result)")
            }
        }

        do {
            let cases: [(value: Double, range: Range<Double>, result: Bool)] = [ (2, 0 ..< 0, false),
                                                                                 (2, 0 ..< 1, false),
                                                                                 (2, 0 ..< 2, false),
                                                                                 (2, 1 ..< 4, true),
                                                                                 (2, 2 ..< 4, true),
                                                                                 (2, 3 ..< 4, false), ]

            cases.forEach {
                XCTAssertEqual(KvIs($0.value, in: $0.range), $0.result, "KvIs(\($0.value), in: \($0.range) != \($0.result)")
                XCTAssertEqual(KvIs($0.value, outOf: $0.range), !$0.result, "KvIs(\($0.value), outOf: \($0.range) != \(!$0.result)")
            }
        }

        do {
            let cases: [(value: Double, range: ClosedRange<Double>, result: Bool)] = [ (2, 0 ... 0, false),
                                                                                       (2, 0 ... 1, false),
                                                                                       (2, 0 ... 2, true),
                                                                                       (2, 1 ... 4, true),
                                                                                       (2, 2 ... 4, true),
                                                                                       (2, 3 ... 4, false), ]

            cases.forEach {
                XCTAssertEqual(KvIs($0.value, in: $0.range), $0.result, "KvIs(\($0.value), in: \($0.range) != \($0.result)")
                XCTAssertEqual(KvIs($0.value, outOf: $0.range), !$0.result, "KvIs(\($0.value), outOf: \($0.range) != \(!$0.result)")
            }
        }

        do {
            let cases: [(value: Double, range: PartialRangeFrom<Double>, result: Bool)] = [ (2, 1..., true),
                                                                                            (2, 2..., true),
                                                                                            (2, 3..., false), ]

            cases.forEach {
                XCTAssertEqual(KvIs($0.value, in: $0.range), $0.result, "KvIs(\($0.value), in: \($0.range) != \($0.result)")
                XCTAssertEqual(KvIs($0.value, outOf: $0.range), !$0.result, "KvIs(\($0.value), outOf: \($0.range) != \(!$0.result)")
            }
        }

        do {
            let cases: [(value: Double, range: PartialRangeUpTo<Double>, result: Bool)] = [ (2, ..<1, false),
                                                                                            (2, ..<2, false),
                                                                                            (2, ..<3, true), ]

            cases.forEach {
                XCTAssertEqual(KvIs($0.value, in: $0.range), $0.result, "KvIs(\($0.value), in: \($0.range) != \($0.result)")
                XCTAssertEqual(KvIs($0.value, outOf: $0.range), !$0.result, "KvIs(\($0.value), outOf: \($0.range) != \(!$0.result)")
            }
        }

        do {
            let cases: [(value: Double, range: PartialRangeThrough<Double>, result: Bool)] = [ (2, ...1, false),
                                                                                               (2, ...2, true),
                                                                                               (2, ...3, true), ]

            cases.forEach {
                XCTAssertEqual(KvIs($0.value, in: $0.range), $0.result, "KvIs(\($0.value), in: \($0.range) != \($0.result)")
                XCTAssertEqual(KvIs($0.value, outOf: $0.range), !$0.result, "KvIs(\($0.value), outOf: \($0.range) != \(!$0.result)")
            }
        }
    }



    func testStringKit() {
        // Whitespace.
        XCTAssertEqual(
            KvStringKit.normalizingWhitespace(for: "  Dianne's \nhorse.\n\n Dianne's\tMBPro  16''\n\n"),
            "Dianne's horse.\nDianne's\tMBPro 16''"
        )
        // Sentecne capitalization.
        XCTAssertEqual(
            KvStringKit.capitalizingSentences(in: "dianne's horse.\nIs it Dianne's MBPro 16''!?yes\n\n"),
            "Dianne's horse.\nIs it Dianne's MBPro 16''!?Yes\n\n"
        )
    }

}
