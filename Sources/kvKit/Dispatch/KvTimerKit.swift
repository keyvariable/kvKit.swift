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
//  KvTimerKit.swift
//  kvKit
//
//  Created by Svyatoslav Popov on 11.03.2019.
//

import CoreFoundation
import Foundation



public class KvTimerKit {

    #if canImport(ObjectiveC)
    public static func scheduledTimer(timeInterval ti: TimeInterval, target aTarget: Any, selector aSelector: Selector, userInfo: Any?, repeats yesOrNo: Bool, runLoop: RunLoop? = nil) -> Timer {
        guard let runLoop = runLoop else {
            return Timer.scheduledTimer(timeInterval: ti, target: aTarget, selector: aSelector, userInfo: userInfo, repeats: yesOrNo)
        }

        let timer = Timer(timeInterval: ti, target: aTarget, selector: aSelector, userInfo: userInfo, repeats: yesOrNo)

        runLoop.add(timer, forMode: .default)

        return timer
    }
    #endif // canImport(ObjectiveC)



    @available(iOS 10.0, macOS 10.12, *)
    public static func scheduledTimer(withTimeInterval interval: TimeInterval, repeats: Bool, runLoop: RunLoop? = nil, block: @escaping (Timer) -> Void) -> Timer {
        guard let runLoop = runLoop else {
            return Timer.scheduledTimer(withTimeInterval: interval, repeats: repeats, block: block)
        }

        let timer = Timer(timeInterval: interval, repeats: repeats, block: block)

        runLoop.add(timer, forMode: .default)

        return timer
    }



    @available(iOS 10.0, macOS 10.12, *)
    public static func scheduledTimer(fire date: Date, interval: TimeInterval, repeats: Bool, runLoop: RunLoop? = nil, block: @escaping (Timer) -> Void) -> Timer {
        let timer = Timer(fire: date, interval: interval, repeats: repeats, block: block)

        (runLoop ?? .current).add(timer, forMode: .default)

        return timer
    }



    #if canImport(ObjectiveC)
    public static func scheduledTimer(fireAt date: Date, interval ti: TimeInterval, target t: Any, selector s: Selector, userInfo ui: Any?, repeats rep: Bool, runLoop: RunLoop? = nil) -> Timer {
        let timer = Timer(fireAt: date, interval: ti, target: t, selector: s, userInfo: ui, repeats: rep)

        (runLoop ?? .current).add(timer, forMode: .default)

        return timer
    }
    #endif // canImport(ObjectiveC)

}
