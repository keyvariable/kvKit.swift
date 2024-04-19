//===----------------------------------------------------------------------===//
//
//  Copyright (c) 2024 Svyatoslav Popov (info@keyvar.com).
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
//  KvShellTests.swift
//  kvKitTests
//
//  Created by Svyatoslav Popov on 19.04.2024.
//

import XCTest

@testable import kvKit



final class KvShellTests : XCTestCase {

    // MARK: testEcho()

    func testEcho() throws {
        let string = UUID().uuidString

        let (output, result) = KvShell().run("echo", with: [ string ]) { ($0, $1) }

        switch result {
        case .failure(let error):
            XCTFail("\(error)")
        case .statusCode(let code):
            XCTFail("Echo has exited with \(code) code")
        case .success:
            XCTAssertEqual(string + "\n", output)
        }
    }

}
