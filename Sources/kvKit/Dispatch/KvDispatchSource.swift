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
//  KvDispatchSource.swift
//  kvKit
//
//  Created by Svyatoslav Popov on 22.04.2020.
//

import Foundation



/// A high-level wrapper for standard `DispatchSource`.
public class KvDispatchSource {

    public var isSuspended: Bool = true {
        didSet {
            switch (oldValue, isSuspended) {
            case (false, true):
                dispatchSource.suspend()
            case (true, false):
                dispatchSource.resume()
            default:
                break
            }
        }
    }



    public init(with dispatchSource: DispatchSourceProtocol) {
        self.dispatchSource = dispatchSource
    }



    deinit {
        if !dispatchSource.isCancelled {
            dispatchSource.cancel()
        }

        if isSuspended {
            dispatchSource.resume()
        }
    }



    private let dispatchSource: DispatchSourceProtocol

}



// MARK: Event Handling

extension KvDispatchSource {

    #if os(Linux)
    public typealias DispatchSourceHandler = () -> Void
    #else
    public typealias DispatchSourceHandler = DispatchSourceProtocol.DispatchSourceHandler
    #endif



    public func setEventHandler(_ handler: DispatchSourceHandler?) {
        dispatchSource.setEventHandler(handler: handler)
    }



    public func setCancelHandler(_ handler: DispatchSourceHandler?) {
        dispatchSource.setCancelHandler(handler: handler)
    }

}
