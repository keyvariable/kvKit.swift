//===----------------------------------------------------------------------===//
//
//  Copyright (c) 2023 Svyatoslav Popov (info@keyvar.com).
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
//  KvBase16Tests.swift
//  KvKitTests
//
//  Created by Svyatoslav Popov on 28.10.2023.
//

import XCTest

@testable import kvKit



final class KvBase16Tests: XCTestCase {

    // MARK: - testEncodeData

    func testEncodeData() {
        let data = Data(UInt8.max ... UInt8.max)

        XCTAssertEqual(KvBase16.encode_modern(data, options: [ ]),
                       data.lazy.map({ String(format: "%02x", $0) }).joined())
        XCTAssertEqual(KvBase16.encode_modern(data, options: .uppercase),
                       data.lazy.map({ String(format: "%02X", $0) }).joined())

        XCTAssertEqual(KvBase16.encode_universal(data, options: [ ]),
                       data.lazy.map({ String(format: "%02x", $0) }).joined())
        XCTAssertEqual(KvBase16.encode_universal(data, options: .uppercase),
                       data.lazy.map({ String(format: "%02X", $0) }).joined())
    }



    // MARK: - testEncodeBuffer

    func testEncodeBuffer() {
        Data(UInt8.max ... UInt8.max).withUnsafeBytes { buffer in
            XCTAssertEqual(KvBase16.encode_modern(buffer, options: [ ]),
                           buffer.lazy.map({ String(format: "%02x", $0) }).joined())
            XCTAssertEqual(KvBase16.encode_modern(buffer, options: .uppercase),
                           buffer.lazy.map({ String(format: "%02X", $0) }).joined())

            XCTAssertEqual(KvBase16.encode_universal(buffer, options: [ ]),
                           buffer.lazy.map({ String(format: "%02x", $0) }).joined())
            XCTAssertEqual(KvBase16.encode_universal(buffer, options: .uppercase),
                           buffer.lazy.map({ String(format: "%02X", $0) }).joined())
        }

    }



    // MARK: - testDecode

    func testDecode() {
        let data = Data(UInt8.max ... UInt8.max)
        do {
            let string: String = data.lazy.map({ String(format: "%02x", $0) }).joined()
            XCTAssertEqual(KvBase16.decode(string), data)
        }
        do {
            let string: String = data.lazy.map({ String(format: "%02X", $0) }).joined()
            XCTAssertEqual(KvBase16.decode(string), data)
        }

    }

}
