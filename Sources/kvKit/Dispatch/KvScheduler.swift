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
//  KvScheduler.swift
//  kvKit
//
//  Created by Svyatoslav Popov on 10.04.2019.
//

#if canImport(Combine)



import Combine
import Foundation



/// Manages asynchronous invocation of multiple tasks at given moments.
@available(iOS 13.0, macOS 10.15, *)
public class KvScheduler {

    public typealias Callback = (Task) -> Void


    public let accuracy: TimeInterval

    public private(set) var tasks: [Task] = .init()



    public init(accuracy: TimeInterval = 1e-2, on dispatchQueue: DispatchQueue) {
        self.accuracy = accuracy

        action = .init(on: dispatchQueue) { [weak self] (action) in
            guard let scheduler = self else {
                KvDebug.pause("A zombie action was detected")

                return action.cancel()
            }

            scheduler.handleAction()
        }
    }



    deinit {
        action.cancel()
    }



    private var action: KvDelayedAction!


    private let mutationLock = NSRecursiveLock()

}



// MARK: .Task

@available(iOS 13.0, macOS 10.15, *)
extension KvScheduler {

    public struct Task {

        public let fireDate: Date
        public let callback: Callback

        public let userData: Any?



        public init(fireDate: Date, userData: Any? = nil, callback: @escaping Callback) {
            self.fireDate = fireDate
            self.callback = callback
            self.userData = userData
        }



        fileprivate func execute() {
            callback(self)
        }

    }

}



// MARK: Task Management

@available(iOS 13.0, macOS 10.15, *)
extension KvScheduler {

    public func add(_ task: Task) {
        KvThreadKit.locking(mutationLock) {
            KvSortedKit.insert(task, inSorted: &tasks, by: { $0.fireDate < $1.fireDate })

            scheduleAction()
        }
    }



    public func remove(where predicate: (Task) -> Bool) {
        KvThreadKit.locking(mutationLock) {
            tasks.removeAll(where: predicate)

            scheduleAction()
        }
    }



    public func executeTasks(where predicate: (Task) -> Bool) {
        var tasksToExecute: [Task] = .init()

        KvThreadKit.locking(mutationLock) {
            tasks.removeAll { (task) -> Bool in
                guard predicate(task) else { return false }

                tasksToExecute.append(task)

                return true
            }
        }

        tasksToExecute.forEach { $0.execute() }

        scheduleAction()
    }



    private func handleAction() {
        let maxDate = max(action.fireDate, Date(timeIntervalSinceNow: accuracy))

        var tasksToExecute: [Task] = .init()

        KvThreadKit.locking(mutationLock) {
            do {
                let endIndex = tasks.firstIndex(where: { $0.fireDate >= maxDate }) ?? tasks.endIndex

                if endIndex > tasks.startIndex {
                    tasksToExecute.append(contentsOf: tasks[..<endIndex])
                    tasks.removeSubrange(..<endIndex)
                }
            }


            do {
                mutationLock.unlock()
                defer { mutationLock.lock() }

                tasksToExecute.forEach { $0.execute() }
            }


            if let nextFireDate = tasks.first?.fireDate {
                action.schedule(on: nextFireDate)

            } else {
                action.cancel()
            }
        }
    }

}



// MARK: Timer Management

@available(iOS 13.0, macOS 10.15, *)
extension KvScheduler {

    private func scheduleAction() {
        KvThreadKit.locking(mutationLock) {
            guard let nextFireDate = tasks.first?.fireDate
            else { return action.cancel() }

            guard !action.isScheduled || action.fireDate.timeIntervalSince(nextFireDate) >= accuracy else { return }

            action.schedule(on: nextFireDate)
        }
    }

}



#endif // canInport(Combine)
