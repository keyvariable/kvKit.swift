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
//  KvBase64Tests.swift
//  KvKitTests
//
//  Created by Svyatoslav Popov on 14.11.2023.
//

import XCTest

@testable import kvKit



final class KvBase64Tests : XCTestCase {

    // MARK: - testEncodeData

    func testEncodeData() {

        func Assert(_ data: Data, alphabet: KvBase64.Alphabet) {
            let result = KvBase64.encode(data, alphabet: alphabet)
            let expected = Self.expectation(encoding: data, alphabet: alphabet)

            XCTAssertEqual(result, expected, "alphabet: \(alphabet), input: \(Self.dataDescription(data)), result: \(Self.dataDescription(result)), expected: \(Self.dataDescription(expected))")
        }

        func Run(alphabet: KvBase64.Alphabet) {
            (0...0x2F).forEach {
                withUnsafeBytes(of: $0) { buffer in
                    Assert(Data(bytesNoCopy: .init(mutating: buffer.baseAddress!), count: 1, deallocator: .none), alphabet: alphabet)
                }
            }

            for length in 0 ..< 32 {
                for _ in 0 ..< 16 {
                    Assert(Data((0 ..< length).lazy.map { _ in UInt8.random(in: .min ... .max) }), alphabet: alphabet)
                }
            }
        }

        KvBase64.Alphabet.allCases.forEach(Run(alphabet:))
    }



    // MARK: Auxiliaries

    private static func expectation(encoding data: Data, alphabet: KvBase64.Alphabet) -> Data {
        var result = data.base64EncodedData()

        switch alphabet {
        case .default:
            return result
        case .urlSafe:
            result.replace(CollectionOfOne(0x2B/* + */), with: CollectionOfOne(0x2D/* - */))
            result.replace(CollectionOfOne(0x2F/* / */), with: CollectionOfOne(0x5F/* _ */))
            result.replace(CollectionOfOne(0x3D/* = */), with: [ ])
            return result
        }
    }


    private static func dataDescription(_ data: Data) -> String {
        let bytes = data
            .lazy.map { String(format: "%02X", $0) }
            .joined(separator: " ")

        return "[ \(bytes) ]"
    }

}
