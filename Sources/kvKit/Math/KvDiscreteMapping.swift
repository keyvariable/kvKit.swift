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
//  KvDiscreteMapping.swift
//  kvKit
//
//  Created by Svyatoslav Popov on 29.12.2018.
//

import Foundation



/// Mapping to descrete subset with given step containing zero: `[ ..., -step, 0, step, ... ]`.
public struct KvDiscreteMapping<T: BinaryFloatingPoint> {

    public typealias BaseType = T



    public var step: T = 1 {
        didSet {
            guard abs(step - oldValue) >= step * .ulpOfOne else { return }

            update()
        }
    }



    public init(step: T = 1) {
        self.step = step

        update()
    }



    private var scale: T = 1
    private var invScale: T = 1

}



// MARK: Mapping

extension KvDiscreteMapping {

    /// - returns: Closest value to *x*.
    public func value(for x: T) -> T { round(x * scale) * invScale }



    /// - returns: Minimum of values greater then *x*.
    public func value(greaterThen x: T) -> T {
        let scaledX = x * scale
        return ceil(scaledX + KvEpsArg(scaledX).tolerance.value) * invScale
    }



    /// - returns: Maximum of values lower then *x*.
    public func value(lessThen x: T) -> T {
        let scaledX = x * scale
        return floor(scaledX - KvEpsArg(scaledX).tolerance.value) * invScale
    }



    /// - returns: Minimum of values greater then or equal to *x*.
    public func value(greaterThenOrEqualTo x: T) -> T {
        let scaledX = x * scale
        return ceil(scaledX - KvEpsArg(scaledX).tolerance.value) * invScale
    }



    /// - returns: Maximum of values lower then or equal to *x*.
    public func value(lessThenOrEqualTo x: T) -> T {
        let scaledX = x * scale
        return floor(scaledX + KvEpsArg(scaledX).tolerance.value) * invScale
    }

}



// MARK: Maintaining of Mapping

extension KvDiscreteMapping {

    private mutating func update() {
        invScale = abs(step) >= .ulpOfOne ? step : KvDebug.pause(code: 1, "Warning: .step = \(step) is too small in absolute value")
        scale = 1 / invScale
    }

}
