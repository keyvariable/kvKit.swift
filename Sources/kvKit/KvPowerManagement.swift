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
//  KvPowerManagement.swift
//  kvKit
//
//  Created by Svyatoslav Popov on 24.01.2018.
//

import Foundation

#if os(macOS)
import IOKit.pwr_mgt
#elseif os(iOS)
import UIKit
#endif // iOS



public class KvPowerManagement { }



// MARK: System Sleep Prevention

extension KvPowerManagement {

    #if os(macOS)
    /// - returns: A RAII token if succeeded or `nil` if error occurs.
    public static func preventSystemSleep(reason: String) -> SystemSleepPreventionToken? {
        SystemSleepPreventionToken(reason: reason)
    }



    /// A RAII token cancelling system sleep prevention.
    public class SystemSleepPreventionToken : CustomStringConvertible {

        public let reason: String

        private let assertionID: IOPMAssertionID



        fileprivate init?(reason: String) {
            var assertionID: IOPMAssertionID = 0

            let resultCode = IOPMAssertionCreateWithName(kIOPMAssertPreventUserIdleSystemSleep as CFString,
                                                         IOPMAssertionLevel(kIOPMAssertionLevelOn),
                                                         reason as CFString,
                                                         &assertionID)
            guard resultCode == kIOReturnSuccess else {
                print("Unable to create a system sleep asserion with code \(resultCode)")
                return nil
            }

            self.assertionID = assertionID
            self.reason = reason

            //print("\(self) was activated")
        }



        deinit {
            IOPMAssertionRelease(assertionID)

            //print("\(self) was deactivated")
        }


        // MARK: : CustomStringConvertible

        public var description: String { "<system sleep assertion: id = \(assertionID), ‘\(reason)’>" }

    }


    #elseif os(iOS)
    /// - returns: A RAII token if succeeded or `nil` if error occurs.
    public static func preventSystemSleep(reason: String) -> SystemSleepPreventionToken? {
        SystemSleepPreventionToken(reason: reason)
    }



    /// A RAII token cancelling system sleep prevention.
    public class SystemSleepPreventionToken : CustomStringConvertible {

        public let reason: String

        private static var count = 0 {
            willSet {
                if newValue < 0 {
                    KvDebug.pause("Internal inconsistency: the count will be assigned with \(newValue)")
                }
            }
            didSet {
                KvDebug.mainThreadCheck("⚠️ Attempt to modify SystemSleepPreventionToken.count on a non-main thread")

                UIApplication.shared.isIdleTimerDisabled = count > 0
            }
        }



        fileprivate init?(reason: String) {
            self.reason = reason

            KvDispatchQueueKit.mainAsyncIfNeeded {
                SystemSleepPreventionToken.count += 1

                //print("\(self) was activated")
            }
        }



        deinit {
            KvDispatchQueueKit.mainAsyncIfNeeded {
                SystemSleepPreventionToken.count -= 1

                //print("\(self) was deactivated")
            }
        }



        // MARK: : CustomStringConvertible

        public var description: String { "<system sleep assertion: ‘\(reason)’>" }

    }
    #endif // os(iOS)

}
