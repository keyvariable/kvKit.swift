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
        let data = Data(UInt8.min ... UInt8.max)

        XCTAssertEqual(KvBase16.encode(data, options: [ ]),
                       data.lazy.map({ String(format: "%02x", $0) }).joined(separator: "").data(using: .utf8)!)
        XCTAssertEqual(KvBase16.encode(data, options: .uppercase),
                       data.lazy.map({ String(format: "%02X", $0) }).joined(separator: "").data(using: .utf8)!)
    }



    // MARK: - testEncodeBuffer

    func testEncodeBuffer() {
        Data(UInt8.min ... UInt8.max).withUnsafeBytes { buffer in
            XCTAssertEqual(KvBase16.encode(buffer, options: [ ]),
                           buffer.lazy.map({ String(format: "%02x", $0) }).joined(separator: "").data(using: .utf8)!)
            XCTAssertEqual(KvBase16.encode(buffer, options: .uppercase),
                           buffer.lazy.map({ String(format: "%02X", $0) }).joined(separator: "").data(using: .utf8)!)
        }

    }


    // MARK: - testEncodeAsString

    func testEncodeAsString() {
        let data = Data(UInt8.min ... UInt8.max)

        if #available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *) {
            XCTAssertEqual(KvBase16.encodeAsString_modern(data, options: [ ]),
                           data.lazy.map({ String(format: "%02x", $0) }).joined(separator: ""))
            XCTAssertEqual(KvBase16.encodeAsString_modern(data, options: .uppercase),
                           data.lazy.map({ String(format: "%02X", $0) }).joined(separator: ""))
        }

        XCTAssertEqual(KvBase16.encodeAsString_universal(data, options: [ ]),
                       data.lazy.map({ String(format: "%02x", $0) }).joined(separator: ""))
        XCTAssertEqual(KvBase16.encodeAsString_universal(data, options: .uppercase),
                       data.lazy.map({ String(format: "%02X", $0) }).joined(separator: ""))
    }



    // MARK: - testDecodeData

    func testDecodeData() {
        let data = Data(UInt8.min ... UInt8.max)
        do {
            let encodedData = data.lazy.map({ String(format: "%02x", $0) }).joined(separator: "").data(using: .utf8)!
            XCTAssertEqual(KvBase16.decode(encodedData), data)
        }
        do {
            let encodedData = data.lazy.map({ String(format: "%02X", $0) }).joined(separator: "").data(using: .utf8)!
            XCTAssertEqual(KvBase16.decode(encodedData), data)
        }

    }



    // MARK: - testDecodeString

    func testDecodeString() {
        let data = Data(UInt8.min ... UInt8.max)
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
