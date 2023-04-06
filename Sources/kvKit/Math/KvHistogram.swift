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
//  KvHistogram.swift
//  kvKit
//
//  Created by Svyatoslav Popov on 22.04.2018.
//

import Foundation



public struct KvHistogram<TX: BinaryFloatingPoint, TY: Numeric> {

    public private(set) var bins: [TY]



    public init(from: TX, to: TX, count: Int, with initialValue: TY = 0) {
        precondition(count > 0, "Internal inconsistency: count = \(count) is not a positive integer")

        bins = .init(repeating: initialValue, count: count)
        maximumIndex = bins.count - 1

        xMapping = .init(from: from ... to, to: TX(0) ... TX(count))
    }



    @inlinable
    public init(on xRange: Range<TX>, count: Int, with initialValue: TY = 0) {
        self.init(from: xRange.lowerBound, to: xRange.upperBound, count: count, with: initialValue)
    }



    @inlinable
    public init(on xRange: ClosedRange<TX>, count: Int, with initialValue: TY = 0) {
        self.init(from: xRange.lowerBound, to: xRange.upperBound, count: count, with: initialValue)
    }



    private let maximumIndex: Int

    private let xMapping: KvLinearMapping<TX>

}



// MARK: Mutation

extension KvHistogram {

    public mutating func insert(_ value: TY = 1, at: TX) {
        let index: Int = {
            let result = Int(xMapping.y(at: at))
            return result >= 0 ? (result <= maximumIndex ? result : maximumIndex) : 0
        }()

        bins[index] += value
    }

}
