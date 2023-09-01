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
//  KvStringKitTests.swift
//  KvKitTests
//
//  Created by Svyatoslav Popov on 01.09.2023.
//

import XCTest

@testable import kvKit



final class KvStringKitTests : XCTestCase {

    // MARK: - testNormalizingWhitespace()

    func testNormalizingWhitespace() {
        XCTAssertEqual(
            KvStringKit.normalizingWhitespace(for: "  Dianne's \nhorse.\n\n Dianne's\tMBPro  16''\n\n"),
            "Dianne's horse.\nDianne's\tMBPro 16''"
        )
    }



    // MARK: testCapitalizingSentences()

    func testCapitalizingSentences() {
        XCTAssertEqual(
            KvStringKit.capitalizingSentences(in: "dianne's horse.\nIs it Dianne's MBPro 16''!?yes\n\n"),
            "Dianne's horse.\nIs it Dianne's MBPro 16''!?Yes\n\n"
        )
    }

}
