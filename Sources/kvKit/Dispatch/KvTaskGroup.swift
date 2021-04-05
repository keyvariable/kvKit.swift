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



// MARK: .Result

@available (macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension KvTaskGroup {

    public enum Result {

        case success(T?), cancelled, failure(Error)


        public init(catching body: () throws -> T?) {
            do { self = .success(try body()) }
            catch { self = .failure(error) }
        }


        public func get() throws -> T? {
            switch self {
            case .cancelled:
                return nil
            case .failure(let error):
                throw error
            case .success(let value):
                return value
            }
        }


        public func map<Y>(_ tranform: (T) -> Y?) -> KvTaskGroup<Y>.Result {
            switch self {
            case .cancelled:
                return .cancelled
            case .failure(let error):
                return .failure(error)
            case .success(let value):
                switch value {
                case .none:
                    return .success(nil)
                case .some(let value):
                    return .success(tranform(value))
                }
            }
        }

    }

}



// MARK: <Void>.Result

@available (macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension KvTaskGroup.Result {

    public func map<Y>() -> KvTaskGroup<Y>.Result {
        switch self {
        case .cancelled:
            return .cancelled
        case .failure(let error):
            return .failure(error)
        case .success:
            return .success(nil)
        }
    }

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



    @discardableResult @inlinable
    public func enter(_ taskInitiator: () -> Cancellable) -> Cancellable {
        let cancellable = taskInitiator()

        enter(taskInitiator())

        return cancellable
    }



    public func leave(with result: Result) {
        KvThreadKit.locking(mutationLock) {
            resultAccumulator.merge(with: result)
        }

        dispatchGroup.leave()
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



    public func leave(with result: Swift.Result<T, Error>) {
        KvThreadKit.locking(mutationLock) {
            resultAccumulator.merge(with: result)
        }

        leave()
    }



    public func leave(with result: Swift.Result<T?, Error>) {
        KvThreadKit.locking(mutationLock) {
            resultAccumulator.merge(with: result)
        }

        leave()
    }



    public func leave(catching body: () throws -> T?) {
        leave(with: .init(catching: body))
    }

}



// MARK: Managing Completion

@available (macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension KvTaskGroup {

    /// Provided *callback* is invoked when *leave()* is invoked the same times as *enter()*. The *callbcak* is invoked with *.success(.none)* if *cancel()* has been invoked.
    public func notify(on queue: DispatchQueue, callback: @escaping (Result) -> Void) {
        dispatchGroup.notify(queue: queue) {
            callback(KvThreadKit.locking(self.mutationLock) {
                self.cancellables.removeAll()
                defer { self.resultAccumulator.reset() }

                return self.resultAccumulator.result
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



// MARK: .ResultAccumulator

@available (macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension KvTaskGroup {

    fileprivate struct ResultAccumulator {

        fileprivate var value: T?
        fileprivate var isCancelled = false
        fileprivate var errors: Errors?

        var result: Result {
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


        mutating func merge(with result: Result) {
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


        mutating func merge(with result: Swift.Result<T, Error>) {
            switch result {
            case .failure(let error):
                merge(with: error)
            case .success(let value):
                merge(with: value)
            }
        }


        mutating func merge(with result: Swift.Result<T?, Error>) {
            switch result {
            case .failure(let error):
                merge(with: error)

            case .success(let value):
                guard let value = value else { break }

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



    public func leave(with result: KvTaskGroup<T.Element>.Result) {
        KvThreadKit.locking(mutationLock) {
            resultAccumulator.merge(with: result)
        }

        leave()
    }



    public func leave(with result: Swift.Result<T.Element, Error>) {
        KvThreadKit.locking(mutationLock) {
            resultAccumulator.merge(with: result)
        }

        leave()
    }



    public func leave(with result: Swift.Result<T.Element?, Error>) {
        KvThreadKit.locking(mutationLock) {
            resultAccumulator.merge(with: result)
        }

        leave()
    }



    public func leave(catching body: () throws -> T.Element?) {
        leave(with: .init(catching: body))
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


    mutating func merge(with result: KvTaskGroup<T.Element>.Result) {
        switch result {
        case .cancelled:
            cancel()
            
        case .failure(let error):
            merge(with: error)

        case .success(let value):
            guard let value = value else { return }

            merge(with: value)
        }
    }


    mutating func merge(with result: Result<T.Element, Error>) {
        switch result {
        case .failure(let error):
            merge(with: error)
        case .success(let value):
            merge(with: value)
        }
    }


    mutating func merge(with result: Result<T.Element?, Error>) {
        switch result {
        case .failure(let error):
            merge(with: error)

        case .success(let value):
            guard let value = value else { break }

            merge(with: value)
        }
    }

}



// MARK: .Errors

@available (macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension KvTaskGroup {

    public struct Errors : Error {

        public var elements: [Error] = .init()


        public init() { }


        public init(_ error: Error) {
            elements = [ error ]
        }


        public init<Errors>(_ errors: Errors) where Errors : Sequence, Errors.Element == Error {
            switch errors {
            case let errors as [Error]:
                elements = errors
            default:
                elements = .init(errors)
            }
        }


        // MARK: : Error

        public var localizedDescription: String { elements.lazy.map({ $0.localizedDescription }).joined(separator: "\n") }


        // MARK: Operations

        mutating public func append(_ error: Error) { elements.append(error) }


        mutating public func append<Errors>(contentsOf errors: Errors) where Errors : Sequence, Errors.Element == Error {
            elements.append(contentsOf: errors)
        }

    }

}
