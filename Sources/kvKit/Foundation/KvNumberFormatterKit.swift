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
//  KvNumberFormatterKit.swift
//  kvKit
//
//  Created by Svyatoslav Popov on 10.08.2021.
//

import Foundation



public enum KvNumberFormatterKit { }



// MARK: Auxiliary Fabrics

extension KvNumberFormatterKit {

    @inlinable
    public static var floatingPoint: NumberFormatter {
        make {
            $0.allowsFloats = true
            $0.usesSignificantDigits = true
        }
    }



    @inlinable
    public static func floatingPoint(callback: (NumberFormatter) throws -> Void) rethrows -> NumberFormatter {
        try make {
            $0.allowsFloats = true
            $0.maximumFractionDigits = .max

            try callback($0)
        }
    }



    @inlinable
    public static func make(callback: (NumberFormatter) throws -> Void) rethrows -> NumberFormatter {
        let formater = NumberFormatter()

        try callback(formater)

        return formater
    }

}
