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
//  KvDelayedActionController.swift
//  kvKit
//
//  Created by Svyatoslav Popov on 13.03.18.
//

#if canImport(Combine)



import Foundation



/// It's designed to invoke an action with a delay. For example validation of a text field after in 1 second since last content modification.
@available(iOS 13.0, macOS 10.15, *)
public class KvDelayedActionController {

    public typealias Callback = () -> Void



    public let delay: TimeInterval

    public let options: Options



    public init(delay: TimeInterval, options: Options = .init(), on dispatchQueue: DispatchQueue, _ callback: @escaping Callback) {
        self.delay = delay
        self.options = options

        action = .init(on: dispatchQueue, action: { [weak self] (action) in
            guard let controller = self else {
                KvDebug.pause("A zombie action was detected")

                return action.cancel()
            }

            controller.lastTriggerDate = Date()

            callback()
        })
    }


    deinit {
        action.cancel()
    }



    private var action: KvDelayedAction!


    private var lastTriggerDate: Date?

}



// MARK: .Options

@available(iOS 13.0, macOS 10.15, *)
extension KvDelayedActionController {

    public struct Options : OptionSet {

        /// If *accumulation* option is set then the controller restarts the acitive delay timer when *schedule()* method is called.
        public static let accumulation = Options(rawValue: 1 << 0)

        /// If *immediate* option is set then the controller invokes the action immediately after *schedule()* method is called when time interval since previous action invocation is grater or equal to *.delay*.
        public static let immediate = Options(rawValue: 2 << 0)


        // MARK: : OptionSet

        public let rawValue: UInt


        public init(rawValue: UInt) { self.rawValue = rawValue }

    }

}



// MARK: Scheduling

@available(iOS 13.0, macOS 10.15, *)
extension KvDelayedActionController {

    /// Schedule the action.
    public func schedule() {
        if action.isScheduled {
            if options.contains(.accumulation) {
                action.schedule(after: delay)
            }

        } else if options.contains(.immediate), lastTriggerDate == nil || lastTriggerDate!.timeIntervalSinceNow < -delay {
            action.trigger()

        } else {
            action.schedule(after: delay)
        }
    }


    /// Invokes the action immediately if it has been scheduled.
    public func flush() { action.flush() }


    /// Invokes the action immediately even if it has not been scheduled.
    public func trigger() { action.trigger() }



    /// Cancels scheduled action.
    public func cancel() { action.cancel() }

}



#endif // canImport(Combine)
