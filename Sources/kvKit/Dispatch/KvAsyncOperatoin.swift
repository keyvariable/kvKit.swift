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
//  KvAsyncOperatoin.swift
//  kvKit
//
//  Created by Svyatoslav Popov on 29.05.2018.
//

import Foundation



/// An implementation of an asynhronous block-based operation for standard *OperationQueue*.
public class KvAsyncOperation : Operation {

    public typealias Completion = () -> Void

    public typealias Block = (@escaping Completion) -> Void

    

    public var state: State {
        get {
            KvThreadKit.locking(mutationLock) { _state }
        }
        set {
            willChangeValue(forKey: _state.keyPath)
            willChangeValue(forKey: newValue.keyPath)

            defer {
                didChangeValue(forKey: _state.keyPath)
                didChangeValue(forKey: newValue.keyPath)
            }

            KvThreadKit.locking(mutationLock) {
                _state = newValue
            }
        }
    }



    public init(_ block: @escaping Block) {
        self.block = block
    }



    private var block: Block!


    /// - Warning: This property must never be mutated directly. Use *.state* instead.
    private var _state: State = .ready

    private let mutationLock = NSRecursiveLock()



    // MARK: Required Overrides

    public override var isReady: Bool {
        guard super.isReady else { return false }

        return state == .ready
    }

    public override var isExecuting: Bool { state == .executing }

    public override var isFinished: Bool { state == .finished }


    public override var isAsynchronous: Bool { true }



    open override func main() {
        block({
            self.state = .finished
        })
        block = nil
    }



    public override func start() {
        guard !isCancelled else {
            state = .finished

            return
        }

        do {
            state = .executing
        }

        main()
    }



    public override func cancel() {
        state = .finished
    }

}



// MARK: States

extension KvAsyncOperation {

    public enum State : String {

        case ready, executing, finished


        fileprivate var keyPath: String { "is" + rawValue.capitalized }

    }

}
