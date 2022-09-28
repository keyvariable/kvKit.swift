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
//  KvRay2Tests.swift
//  kvKit
//
//  Created by Svyatoslav Popov on 28.09.2022.
//

import XCTest

@testable import kvKit



class KvRay2Tests : XCTestCase {

    typealias Vertex<Math : KvMathScope> = KvPosition2<Math, Void>
    typealias Ray<Math : KvMathScope> = KvRay2<Vertex<Math>>



    // MARK: : XCTestCase

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }


    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }



    // MARK: Offset to Ray Test

    func testOffsetToRay() {

        func Run<Math : KvMathScope>(_ math: Math.Type) {
            let ray = Ray<Math>(in: .one, at: .init(.unitY))

            func Assert(_ other: Ray<Math>, _ expected: Math.Scalar?) {
                AssertEqual(ray.offset(to: other), expected, by: KvIs(_:equalTo:))
            }

            Assert(ray, nil)
            Assert(.init(in: .unitX, at: .init(.unitY)), 0)
            Assert(.init(in: -.unitX, at: [ 10, 1 ]), 0)
            Assert(.init(in: -.unitX, at: [ 1, 10 ]), nil)
            Assert(.init(in: -.unitX, at: [ 10, 0 ]), nil)
        }

        Run(KvMathFloatScope.self)
        Run(KvMathDoubleScope.self)
    }

}
