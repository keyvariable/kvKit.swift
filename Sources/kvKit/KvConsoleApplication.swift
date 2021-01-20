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
//  KvConsoleApplication.swift
//  KvKit
//
//  Created by Svyatoslav Popov on 22.04.2020.
//

import CoreFoundation
import Foundation



// MARK: - KvConsoleApplicationDelegate

public protocol KvConsoleApplicationDelegate {

    /// It's invoked just before the main run loop is started.
    func consoleApplicationShouldStart(_ application: KvConsoleApplication) -> Bool

    /// It's invoked on the main run loop just after it has been started.
    func consoleApplicationDidStart(_ application: KvConsoleApplication)

    func consoleApplicationWillStop(_ application: KvConsoleApplication)

}



// MARK: - KvConsoleApplication

/// A class providing the main run loop for console applications.
///
/// It is designed as a simple analog of Apple's *UIApplication* and *NSApplication*.
///
/// Usage. Invoke *main(with:)* passing the delegate. Ivoke *setNeedsStop()* to stop running application.
///
/// - Note: The application holds a strong reference to the delegate while *main(with:)* is being executed.
public final class KvConsoleApplication {

    public private(set) static var shared: KvConsoleApplication! {
        didSet {
            guard oldValue == nil else {
                KvDebug.pause("Internal inconsistency: attempt to simultaneously run two applications")

                shared = oldValue
                return
            }
        }
    }



    public let delegate: KvConsoleApplicationDelegate



    private init(with delegate: KvConsoleApplicationDelegate) {
        self.delegate = delegate
    }



    private static let mutationLock = NSRecursiveLock()

    private static var needsStop: Bool {
        KvThreadKit.locking(mutationLock) { shared.needsStop }
    }


    private var needsStop: Bool = false {
        didSet {
            switch (needsStop, oldValue) {
            case (true, false):
                KvDispatchQueueKit.mainAsyncIfNeeded {
                    CFRunLoopStop(RunLoop.main.getCFRunLoop())
                }

            default:
                break
            }
        }
    }

}



// MARK: Execution

extension KvConsoleApplication {

    public static func main(with delegate: KvConsoleApplicationDelegate) {
        KvDebug.mainThreadCheck()


        KvThreadKit.locking(mutationLock) { () -> Void in
            guard shared == nil else {
                return KvDebug.pause("Attempt to simultaneously run two applications")
            }

            let application = Self(with: delegate)

            shared = application
        }


        guard delegate.consoleApplicationShouldStart(shared) else { return }

        DispatchQueue.main.async {
            delegate.consoleApplicationDidStart(shared)
        }

        while !shared.needsStop && RunLoop.main.run(mode: .default, before: .distantFuture) {
        }

        delegate.consoleApplicationWillStop(shared)
    }



    public func setNeedsStop() {
        KvThreadKit.locking(Self.mutationLock) {
            precondition(self === Self.shared, "Internal inconsistency: unexpected application instance")
            
            needsStop = true
        }
    }

}

