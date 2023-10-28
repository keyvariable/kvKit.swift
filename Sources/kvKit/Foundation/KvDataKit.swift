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
//  KvDataKit.swift
//  kvKit
//
//  Created by Svyatoslav Popov on 28.10.2023.
//

import Foundation



/// Collection of auxiliaries related to standard `Data`.
public struct KvDataKit {

    private init() { }



    // MARK: Base64

    /// Convenient wrapper combining `withUnsafeBytes(of:_:)` and `Data.base64EncodedData(options:)`.
    @inlinable
    public static func base64<T>(withBytesOf x: T, options: Data.Base64EncodingOptions = [ ]) -> Data {
        withUnsafeBytes(of: x) { buffer in
            let dataWrapper = Data(bytesNoCopy: .init(mutating: buffer.baseAddress!), count: buffer.count, deallocator: .none)

            return dataWrapper.base64EncodedData(options: options)
        }
    }

}
