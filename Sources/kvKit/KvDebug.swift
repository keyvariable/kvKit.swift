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
//  KvDebug.swift
//  KvKit
//
//  Created by Svyatoslav Popov on 03.01.2018.
//

import Foundation

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif // AppKit



public class KvDebug {

    #if DEBUG
    /// Analog for *assert* providing ability to continue execution.
    ///
    /// - Note: Prints reason, file and line to standard output and throws an error catching it immediately when *DEBUG* is true. Use *Swift Error Breakpoint* to pause execution.
    @inlinable
    public static func pause(_ reason: String, _ file: StaticString = #fileID, _ line: UInt = #line) {
        let message = "\(reason) | \(file):\(line)"

        print(message)
        
        do { throw KvError(message) } catch { }
    }

    #else // !DEBUG
    /// Analog for *assert* providing ability to continue execution.
    ///
    /// - Note: Prints reason, file and line to standard output and throws an error catching it immediately when *DEBUG* is true. Use *Swift Error Breakpoint* to pause execution.
    @inlinable
    public static func pause(_ reason: String) {
        print(reason)
    }
    #endif // !DEBUG



    #if DEBUG
    /// Analog for *assert* providing ability to continue execution.
    ///
    /// - Returns: *code* passed an argument.
    ///
    /// - Note: It's a shortcut designed to be used like this:
    ///
    ///     `return KvDebug.pause(code: -1, "Unexpected input")`
    ///
    /// - Note: Prints reason, file and line to standard output and throws an error catching it immediately when *DEBUG* is true. Use *Swift Error Breakpoint* to pause execution.
    @inlinable
    public static func pause<T>(code: T, _ reason: String, _ file: StaticString = #fileID, _ line: UInt = #line) -> T {
        pause(reason, file, line)
        return code
    }

    #else // !DEBUG
    /// Analog for *assert* providing ability to continue execution.
    ///
    /// - Returns: *code* passed an argument.
    ///
    /// - Note: It's a shortcut designed to be used like this:
    ///
    ///     `return KvDebug.pause(code: -1, "Unexpected input")`
    ///
    /// - Note: Prints reason, file and line to standard output and throws an error catching it immediately when *DEBUG* is true. Use *Swift Error Breakpoint* to pause execution.
    @inlinable
    public static func pause<T>(code: T, _ reason: String) -> T {
        pause(reason)
        return code
    }
    #endif // !DEBUG



    #if DEBUG
    /// Analog for *assert* providing ability to continue execution.
    ///
    /// - Returns: *error* passed an argument.
    ///
    /// - Note: It's a shortcut designed to be used like this:
    ///
    ///     `throw KvDebug.pause(KvError("Unexpected input"))`
    ///
    /// - Note: Prints reason, file and line to standard output and throws an error catching it immediately when *DEBUG* is true. Use *Swift Error Breakpoint* to pause execution.
    @discardableResult @inlinable
    public static func pause<E: Error>(_ error: E, _ file: StaticString = #fileID, _ line: UInt = #line) -> E {
        pause((error as? KvError)?.message ?? error.localizedDescription, file, line)
        return error
    }

    #else // !DEBUG
    /// Analog for *assert* providing ability to continue execution.
    ///
    /// - Returns: *error* passed an argument.
    ///
    /// - Note: It's a shortcut designed to be used like this:
    ///
    ///     `throw KvDebug.pause(KvError("Unexpected input"))`
    ///
    /// - Note: Prints reason, file and line to standard output and throws an error catching it immediately when *DEBUG* is true. Use *Swift Error Breakpoint* to pause execution.
    @discardableResult @inlinable
    public static func pause<E: Error>(_ error: E) -> E {
        pause((error as? KvError)?.message ?? error.localizedDescription)
        return error
    }
    #endif // !DEBUG



#if DEBUG
    /// Analog of standard ``Swift/assert``()  providing ability to continue execution.
    ///
    /// - Note: Use *Swift Error Breakpoint* to pause execution.
    ///
    /// In *RELEASE* does nothing. In *DEBUG* prints *message*, file and line to standard output and throws an error catching it immediately.
    @inlinable
    public static func assert(_ condition: @autoclosure () -> Bool, _ message: @autoclosure () -> String = String(), file: StaticString = #fileID, line: UInt = #line) {
        if !condition() {
            pause(message(), file, line)
        }
    }

#else // !DEBUG
    /// Analog of standard ``Swift/assert``() providing ability to continue execution.
    ///
    /// - Note: Use *Swift Error Breakpoint* to pause execution.
    ///
    /// In *RELEASE* does nothing. In *DEBUG* prints *message*, file and line to standard output and throws an error catching it immediately.
    @inlinable
    public static func assert(_ condition: @autoclosure () -> Bool, _ message: @autoclosure () -> String = String(), file: StaticString = #fileID, line: UInt = #line)
    { }
#endif // !DEBUG

}



// MARK: MacOS Alerts

#if canImport(AppKit)
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
#endif // os(AppKit)



// MARK: iOS Alerts

#if canImport(UIKit)
@available(iOS 13.0, *)
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
#endif // UIKit



// MARK: Diagnostic

extension KvDebug {

    #if DEBUG
    /// Executes *KvDebug.pause()* if invoked when *Thread.isMainThread* returns *false*.
    @inlinable
    public static func mainThreadCheck(_ description: @autoclosure () -> String = #function, _ file: StaticString = #fileID, _ line: UInt = #line) {
        guard !Thread.isMainThread else { return }

        pause("Main thread check has failed on \(Thread.current): \(description())", file, line)
    }

    #else // !DEBUG
    /// Executes *KvDebug.pause()* if invoked when *Thread.isMainThread* returns *false*.
    @inlinable
    public static func mainThreadCheck(_ description: @autoclosure () -> String = "") { }
    #endif // !DEBUG



    #if DEBUG
    /// Executes *KvDebug.pause()* if invoked when *Thread.isMainThread* returns *true*.
    @inlinable
    public static func nonmainThreadCheck(_ description: @autoclosure () -> String = #function, _ file: StaticString = #fileID, _ line: UInt = #line) {
        #if DEBUG
        guard Thread.isMainThread else { return }

        pause("Non-main thread check has failed on \(Thread.current): \(description())", file, line)
        #endif // DEBUG
    }

    #else // !DEBUG
    /// Executes *KvDebug.pause()* if invoked when *Thread.isMainThread* returns *true*.
    @inlinable
    public static func nonmainThreadCheck(_ description: @autoclosure () -> String = "") { }
    #endif // !DEBUG



    // MARK: .MainThreadCheck

    /// A property wrapper executing *KvDebug.mainThreadCheck()* on any access to *.wrappedValue*.
    ///
    /// Sometimes Xcode's Thread Sanitizer is not available.
    ///
    /// - Warning: Don't assign wrapped value in the change observers *willSet* or *didSet* to prevent recursion cycle.
    @propertyWrapper
    public struct MainThreadCheck<Value> {

        #if DEBUG
        public init(wrappedValue: Value, _ file: StaticString = #fileID, _ line: UInt = #line) {
            value = wrappedValue

            self.file = file
            self.line = line
        }

        #else // !DEBUG
        public init(wrappedValue: Value) {
            value = wrappedValue
        }
        #endif // !DEBUG



        private var value: Value

        #if DEBUG
        private let file: StaticString
        private let line: UInt
        #endif // DEBUG



        // MARK: .wrappedValue

        public var wrappedValue: Value {
            get {
                #if DEBUG
                mainThreadCheck(Constants.propertyReadWarningMessage, file, line)
                #else // !DEBUG
                mainThreadCheck(Constants.propertyReadWarningMessage)
                #endif // !DEBUG

                return value
            }
            set {
                #if DEBUG
                mainThreadCheck(Constants.propertyWriteWarningMessage, file, line)
                #else // !DEBUG
                mainThreadCheck(Constants.propertyWriteWarningMessage)
                #endif // !DEBUG

                value = newValue
            }
        }


        // MARK: .Constants

        private struct Constants {

            static var propertyReadWarningMessage: String { "⚠️ Attempt to get value of property in a non-main thread" }
            static var propertyWriteWarningMessage: String { "⚠️ Attempt to assign value to property in a non-main thread" }

        }

    }

}
