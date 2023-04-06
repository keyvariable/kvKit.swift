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
//  KvTaskGroup.swift
//  kvKit
//
//  Created by Svyatoslav Popov on 04.04.2021.
//

#if canImport(Combine)
import Combine
#endif // canImport(Combine)

import Foundation



/// Manages execution of tasks like *DispatchGroup* collecting results. Supports *Cancelable* protocol.
@available (macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public class KvTaskGroup<T> {

    public init() { }



    private let mutationLock = NSRecursiveLock()

    private let dispatchGroup = DispatchGroup()

    private var resultAccumulator: ResultAccumulator = .init()

    private lazy var cancellables: [Cancellable] = .init()

}



// MARK: Managing Tasks

@available (macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension KvTaskGroup {

    public func enter(_ cancellable: Cancellable? = nil) {
        dispatchGroup.enter()

        if let cancellable = cancellable {
            KvThreadKit.locking(mutationLock) {
                cancellables.append(cancellable)
            }
        }
    }



    @discardableResult
    public func enter(_ taskInitiator: () -> Cancellable?) -> Cancellable? {
        dispatchGroup.enter()

        let cancellable = taskInitiator()

        if cancellable != nil {
            KvThreadKit.locking(mutationLock) {
                cancellables.append(cancellable!)
            }
        }

        return cancellable
    }



    public func leave() { dispatchGroup.leave() }



    public func leave(_ value: T) {
        KvThreadKit.locking(mutationLock) {
            resultAccumulator.merge(with: value)
        }

        leave()
    }



    public func leave(_ error: Error) {
        KvThreadKit.locking(mutationLock) {
            resultAccumulator.merge(with: error)
        }

        leave()
    }



    @inlinable
    public func leave(valueProvider: () throws -> T) {
        do { leave(try valueProvider()) }
        catch { return leave(error) }
    }



    @inlinable
    public func leave(valueProvider: () throws -> Void) {
        do { try valueProvider() }
        catch { return leave(error) }

        leave()
    }



    public func leave(with result: KvCancellableResult<T?>) {
        KvThreadKit.locking(mutationLock) {
            resultAccumulator.merge(with: result)
        }

        leave()
    }



    public func leave(with result: KvCancellableResult<T>) {
        KvThreadKit.locking(mutationLock) {
            resultAccumulator.merge(with: result)
        }

        leave()
    }

}



// MARK: Managing Completion

@available (macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension KvTaskGroup {

    /// Provided *callback* is invoked when *leave()* is invoked the same times as *enter()*. The *callbcak* is invoked with *.success(.none)* if result value has never been provided.
    public func notify(on queue: DispatchQueue, callback: @escaping (KvCancellableResult<T?>) -> Void) {
        dispatchGroup.notify(queue: queue) {
            callback(KvThreadKit.locking(self.mutationLock) {
                self.cancellables.removeAll()
                defer { self.resultAccumulator.reset() }

                return self.resultAccumulator.result
            })
        }
    }



    /// Provided *callback* is invoked when *leave()* is invoked the same times as *enter()*.
    public func notifyUnwrapping(on queue: DispatchQueue, callback: @escaping (KvCancellableResult<T>) -> Void) {
        dispatchGroup.notify(queue: queue) {
            callback(KvThreadKit.locking(self.mutationLock) {
                self.cancellables.removeAll()
                defer { self.resultAccumulator.reset() }

                return self.resultAccumulator.result.map { value in
                    guard let value = value else { throw KvError("Force unwrapping nil result") }

                    return value
                }
            })
        }
    }

}



// MARK: : Cancellable

@available (macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension KvTaskGroup : Cancellable {

    public func cancel() {
        KvThreadKit.locking(mutationLock) {
            cancellables.forEach {
                $0.cancel()
            }

            cancellables.removeAll()
            resultAccumulator.cancel()
        }
    }

}



// MARK: AnyCancellable

@available (macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension KvTaskGroup {

    @inlinable
    public func eraseToAnyCancellable() -> AnyCancellable { .init(self) }

}



// MARK: .ResultAccumulator

@available (macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension KvTaskGroup {

    fileprivate struct ResultAccumulator {

        fileprivate var value: T?
        fileprivate var isCancelled = false
        fileprivate var errors: KvError.Accumulator<Error>?

        var result: KvCancellableResult<T?> {
            switch (errors, isCancelled) {
            case (.none, false):
                return .success(value)
            case (.none, true):
                return .cancelled
            case (.some(let error), _):
                return .failure(error)
            }
        }


        /// MARK: Operations

        mutating func merge(with value: T) {
            guard !isCancelled else { return }

            self.value = value
        }


        mutating func merge(with error: Error) {
            errors?.append(error)
                ?? (errors = .init(error))
            value = nil
        }


        mutating func merge(with result: KvCancellableResult<T?>) {
            switch result {
            case .cancelled:
                cancel()

            case .failure(let error):
                merge(with: error)

            case .success(let value):
                guard let value = value else { break }

                merge(with: value)
            }
        }


        mutating func merge(with result: KvCancellableResult<T>) {
            switch result {
            case .cancelled:
                cancel()

            case .failure(let error):
                merge(with: error)

            case .success(let value):
                merge(with: value)
            }
        }


        fileprivate mutating func cancel() {
            isCancelled = true
            value = nil
        }


        mutating func reset() {
            isCancelled = false
            value = nil
            errors = nil
        }

    }

}



// MARK: <RangeReplaceableCollection>

@available (macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension KvTaskGroup where T : RangeReplaceableCollection {

    public func leave(_ value: T.Element) {
        KvThreadKit.locking(mutationLock) {
            resultAccumulator.merge(with: value)
        }

        leave()
    }



    public func leave(with result: KvCancellableResult<T.Element>) {
        KvThreadKit.locking(mutationLock) {
            resultAccumulator.merge(with: result)
        }

        leave()
    }

}



// MARK: <RangeReplaceableCollection>.ResultAccumulator

@available (macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension KvTaskGroup.ResultAccumulator where T : RangeReplaceableCollection {

    mutating func merge(with value: T) {
        guard !isCancelled else { return }

        self.value?.append(contentsOf: value)
            ?? (self.value = .init(value))
    }


    mutating func merge(with value: T.Element) {
        guard !isCancelled else { return }

        self.value?.append(value)
            ?? (self.value = .init(CollectionOfOne(value)))
    }


    mutating func merge(with result: KvCancellableResult<T.Element>) {
        switch result {
        case .cancelled:
            cancel()

        case .failure(let error):
            merge(with: error)

        case .success(let value):
            merge(with: value)
        }
    }

}
