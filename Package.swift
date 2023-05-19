// swift-tools-version:5.2
//
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

import PackageDescription


let swiftSettings: [SwiftSetting]? = nil


let package = Package(
    name: "kvKit.swift",

    platforms: [ .iOS(.v11), ],

    products: [
        .library(name: "kvKit", targets: [ "kvKit" ]),
        .library(name: "kvTestKit", targets: [ "kvTestKit" ]),
    ],

    targets: [
        .target(name: "kvKit", dependencies: [ ], swiftSettings: swiftSettings),
        .target(name: "kvTestKit", dependencies: [ "kvKit" ], swiftSettings: swiftSettings),
        .testTarget(name: "kvKitTests", dependencies: [ "kvKit", "kvTestKit" ], swiftSettings: swiftSettings),
    ]
)
