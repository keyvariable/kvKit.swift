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
//  KvRoundedRectangleTests.swift
//  kvKitTests
//
//  Created by Svyatoslav Popov on 22.11.2021.
//

import XCTest

@testable import kvKit

import SwiftUI



final class KvRoundedRectangleTests : XCTestCase {

    static var allTests = [
        ("ZeroRectangle", testZeroRectangle)
    ]


    func testZeroRectangle() {
        guard #available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *) else { return }

        let expected: Path = {
            var path = Path()

            path.addLines([ CGPoint(x: 0, y: 0), CGPoint(x: 0, y: 0), CGPoint(x: 0, y: 0), CGPoint(x: 0, y: 0), CGPoint(x: 0, y: 0) ])
            path.closeSubpath()

            return path
        }()

        XCTAssertEqual(
            KvRoundedRectangle(radii: 4)
                .path(in: .zero),
            expected,
            "Unexpected zero size rect")

        XCTAssertEqual(
            KvRoundedRectangle(radii: 4)
                .inset(by: 8)
                .path(in: .zero),
            expected,
            "Unexpected zero size rect having inset")
    }

}
