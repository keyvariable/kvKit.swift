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
//  KvDebug.swift
//  KvKit
//
//  Created by Svyatoslav Popov on 03.01.2018.
//

import Foundation

#if os(macOS)
import Cocoa
#elseif os(iOS)
import UIKit
#endif // iOS



public class KvDebug {

    @inlinable
    public static func pause(_ reason: String, _ file: String = #file, _ line: Int = #line) {
        let message = "\(reason) | \(file):\(line)"

        print(message)
        
        #if DEBUG
        do { throw KvError(message) } catch { }
        #endif // DEBUG
    }



    @inlinable
    public static func pause<T>(code: T, _ reason: String, _ file: String = #file, _ line: Int = #line) -> T {
        pause(reason, file, line)
        return code
    }



    @discardableResult @inlinable
    public static func pause<E: Error>(_ error: E, _ file: String = #file, _ line: Int = #line) -> E {
        pause((error as? KvError)?.message ?? error.localizedDescription, file, line)
        return error
    }



    @discardableResult @inlinable
    public static func pause(_ error: Error, _ file: String = #file, _ line: Int = #line) -> Error {
        pause((error as? KvError)?.message ?? error.localizedDescription, file, line)
        return error
    }

}



// MARK: MacOS Alerts

#if os(macOS)
extension KvDebug {

    @inlinable
    public static func alertError(_ message: String, in window: NSWindow? = nil, _ completion: (() -> Void)? = nil) {
        KvUI.Alert.present(message: message, in: window, completion: completion)
    }


    
    @inlinable
    public static func alertError<T>(code: T, _ message: String, in window: NSWindow? = nil, _ completion: (() -> Void)? = nil) -> T {
        alertError(message, in: window, completion)
        return code
    }

}
#endif // os(macOS)



// MARK: iOS Alerts

#if os(iOS)
@available (iOS 13.0, *)
extension KvDebug {

    @inlinable
    public static func alertError(_ message: String, in viewController: UIViewController? = nil, _ completion: (() -> Void)? = nil) {
        KvUI.Alert.present(message: message, in: viewController, completion: completion)
    }



    @inlinable
    public static func alertError<T>(code: T, _ message: String, in viewController: UIViewController? = nil, _ completion: (() -> Void)? = nil) -> T {
        alertError(message, in: viewController, completion)
        return code
    }

}
#endif // os(iOS)



// MARK: Diagnostic

extension KvDebug {

    @inlinable
    public static func mainThreadCheck() {
        #if DEBUG
        guard !Thread.isMainThread else { return }

        KvDebug.pause("Main thread check has failed")
        #endif // DEBUG
    }

}
