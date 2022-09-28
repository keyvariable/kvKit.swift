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
//  KvTestKit.swift
//  kvKit
//
//  Created by Svyatoslav Popov on 28.09.2022.
//

import XCTest



/// Invokes ``XCTFail``() when *result* and *expectation* are not both `nil` or *isEqual* doesn't return *true*.
func AssertEqual<R, E>(_ result: R?, _ expectation: E?, by isEqual: (R, E) -> Bool) {
    switch (result, expectation) {
    case (.none, .none):
        break   // OK
    case (.none, .some(let expectation)):
        XCTFail("`nil` result is not equal to expected \(expectation)")
    case (.some(let result), .none):
        XCTFail("\(result) result is not equal to expected `nil`")
    case (.some(let result), .some(let expectation)):
        XCTAssert(isEqual(result, expectation), "\(result) result is not equal to expected \(expectation)")
    }
}
