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
//  KvSerialTaskController.swift
//  kvKit
//
//  Created by Svyatoslav Popov on 05.08.2021.
//

import Combine
import Foundation



// TODO: #warning("Move to kvKit")
/// Provides asynchronous and serial invocation of given task throttling requests until task being invoked finishes.
@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public class KvSerialTaskController<Input, Output> : NSLocking  {

    public typealias Task = (Input) throws -> Output

    public typealias Result = Swift.Result<Output, Error>



    /// A quete the tasks is invoked on.
    let queue: DispatchQueue

    fileprivate let task: Task

    /// Nil context cancels current task and doesn't start new task.
    public var input: Input? {
        get { mutationLock.withLock { _input } }
        set { mutationLock.withLock { _input = newValue } }
    }


    public var result: Result? { resultSubject.value }

    private(set) public lazy var publisher: AnyPublisher<Result?, Never> = resultSubject.share().eraseToAnyPublisher()



    /// - Parameter queue: A quete given *task* to be invoked on.
    public init(queue: DispatchQueue = .global(), task: @escaping Task) {
        self.queue = queue
        self.task = task
    }



    private let mutationLock = NSRecursiveLock()


    private var _input: Input? {
        didSet {
            switch _input {
            case .some:
                status.insert(.needsRun)

            case .none:
                status.remove(.needsRun)

                if status.contains(.running) {
                    status.insert(.cancelled)
                }
                else if resultSubject.value != nil {
                    resultSubject.send(nil)
                }
            }
        }
    }

    private let resultSubject = CurrentValueSubject<Result?, Never>(nil)


    private var status: Status = [ ] {
        didSet {
            guard status != oldValue else { return }

            run()
        }
    }



    // MARK: : NSLocking

    public func lock() { mutationLock.lock() }



    public func unlock() { mutationLock.unlock() }

}



// MARK: .Status

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension KvSerialTaskController {

    private struct Status : OptionSet {

        static var needsRun: Self { .init(rawValue: 1 << 0) }
        static var running: Self { .init(rawValue: 1 << 1) }
        static var cancelled: Self { .init(rawValue: 1 << 2) }


        var rawValue: UInt
    }

}



// MARK: Operations

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension KvSerialTaskController {

    private func run() {
        guard status.contains(.needsRun),
              !status.contains(.running)
        else { return }

        guard let input = _input else {
            KvDebug.pause("Warning: status contains .needsRun but there is no input")
            _ = status.remove(.needsRun)
            return
        }

        let task = task

        status.insert(.running)
        status.remove(.needsRun)

        queue.async { [weak self] in
            let result = Result { try task(input) }

            self?.commit(result)
        }
    }



    private func commit(_ result: Result) {
        do {
            mutationLock.lock()
            defer { mutationLock.unlock() }

            guard status.contains(.running) else { return KvDebug.pause("Warning: result is ignored due to status doesn't contain running flag") }

            // Ignoring result of a cancelled task.
            guard status.remove(.cancelled) == nil else { return }
        }

        // Result is committed when the lock is released.
        resultSubject.send(result)

        mutationLock.withLock {
            status.remove(.running)

            // Run next task if requested
            run()
        }
    }

}
