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
//  KvOperationQueueKit.swift
//  KvKit
//
//  Created by Svyatoslav Popov on 05.11.2020.
//

import Foundation



/// A collection of auxiliaries for standard OperationQueue.
public class KvOperationQueueKit { }



// MARK: .SerialQubqueue

extension KvOperationQueueKit {

    /// A serial subqueue on underlying queue. It organizes operations to be executed in addition order even if underlying queue is concurrent.
    public class SerialQubqueue {

        public let underlyingQueue: OperationQueue



        public init(on operationQueue: OperationQueue) {
            underlyingQueue = operationQueue
        }



        private let mutationLock = NSLock()

        private var lastOperation: Operation?



        // MARK: Managing Operations

        public func addOperation(_ operation: Operation) {
            KvThreadKit.locking(mutationLock) {
                if let lastOperation = lastOperation {
                    operation.addDependency(lastOperation)
                }

                lastOperation = operation
            }

            underlyingQueue.addOperation(operation)
        }



        @inlinable
        public func addOperation(_ block: @escaping () -> Void) { addOperation(BlockOperation(block: block)) }



        public func addOperations(_ operations: [Operation], waitUntilFinished waitFlag: Bool) {
            KvThreadKit.locking(mutationLock) {
                var operationIterator = operations.makeIterator()

                if var prevOperation = operationIterator.next() {
                    if let lastOperation = lastOperation {
                        prevOperation.addDependency(lastOperation)
                    }

                    while let operation = operationIterator.next() {
                        operation.addDependency(prevOperation)
                        prevOperation = operation
                    }

                    lastOperation = prevOperation
                }
            }

            underlyingQueue.addOperations(operations, waitUntilFinished: waitFlag)
        }

    }

}
