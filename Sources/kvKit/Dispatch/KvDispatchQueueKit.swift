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
//  KvDispatchQueueKit.swift
//  kvKit
//
//  Created by Svyatoslav Popov on 14.08.18.
//

import Foundation



public enum KvDispatchQueueKit { }



// MARK: Auxiliary Queues

extension KvDispatchQueueKit {

    public enum GlobalSerialQueue {

        /// Serial dispatch queue executing tasks with *.background* quality of service.
        public static let background = DispatchQueue(label: "com.keyvar.GlobalSerialQueue.background", qos: .background, autoreleaseFrequency: .inherit)

        /// Serial dispatch queue executing tasks with *.userInitiated* quality of service.
        public static let userInitiated = DispatchQueue(label: "com.keyvar.GlobalSerialQueue.userInitiated", qos: .userInitiated, autoreleaseFrequency: .inherit)

        /// Serial dispatch queue executing tasks with *.utility* quality of service.
        public static let utility = DispatchQueue(label: "com.keyvar.GlobalSerialQueue.utility", qos: .utility, autoreleaseFrequency: .inherit)


        // TODO: Delete in 4.0.0
        @available(*, unavailable, renamed: "userInitiated")
        public static var userInitialted: DispatchQueue { self.userInitiated }

    }

}



// MARK: Conditional Invocations

extension KvDispatchQueueKit {

    /// Invokes *block* immediately when method is invoked on the main thread. Otherwise *block* is invoked on the main thread synchronously.
    public static func mainSyncIfNeeded<T>(_ block: @escaping () throws -> T) rethrows -> T {
        try Thread.isMainThread
            ? block()
            : DispatchQueue.main.sync(execute: block)
    }



    /// Invokes *block* immediately when method is invoked on the main thread. Otherwise *block* is invoked on the main thread asynchronously.
    public static func mainAsyncIfNeeded(_ block: @escaping () -> Void) {
        Thread.isMainThread
            ? block()
            : DispatchQueue.main.async(execute: block)
    }



    /// Invokes *block* immediately when method is invoked on a non-main thread. Otherwise *block* is invoked on the global dispatch queue with *qos* quality of service asynchronously.
    public static func nonMainAsyncIfNeeded(qos: DispatchQoS.QoSClass = .default, _ block: @escaping () -> Void) {
        Thread.isMainThread
            ? DispatchQueue.global(qos: .default).async(execute: block)
            : block()
    }



    /// Invokes *block* on the main thread synchronously if method is invoked on the main thread. Otherwise *block* is invoked on the main thread asynchronously.
    @available(*, deprecated, message: "Use DispatchQueue.global(qos:).async(execute:) instead")
    public static func globalAsyncIfNeeded(qos: DispatchQoS.QoSClass = .default, _ block: @escaping () -> Void) {
        let globalQueue = DispatchQueue.global(qos: qos)

        OperationQueue.current?.underlyingQueue === globalQueue
            ? block()
            : globalQueue.async(execute: block)
    }

}
