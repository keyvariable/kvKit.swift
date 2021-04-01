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
//  KvCachedAssets.swift
//  kvKit
//
//  Created by Svyatoslav Popov on 09.02.2021.
//

#if canImport(Combine)



import Combine
import Foundation



/// Caches downloaded resources in the system's cache and provides convenient features.
open class KvCachedAssets {

    public let urlSession: URLSession



    /// - Parameter urlCacheDiskCapacity: Disk capacity of the session's cache is expanded to *urlCacheDiskCapacity* when *urlCacheDiskCapacity* isn't *nil*, the session's cache isn't *nil* and
    ///                               the cache's disk capacity less then *urlCacheDiskCapacity*.
    public init(_ urlSession: URLSession = .shared, urlCacheDiskCapacity: Int? = nil) {
        self.urlSession = urlSession

        if let diskCapacity = urlCacheDiskCapacity,
           let urlCache = urlSession.configuration.urlCache,
           diskCapacity > urlCache.diskCapacity
        {
            urlCache.diskCapacity = diskCapacity
        }
    }

}



// MARK: Downloads

extension KvCachedAssets {

    @available(iOS 13.0, macOS 10.15, *)
    @discardableResult @inlinable
    public func withData(for url: URL, completion: @escaping (Result<Data, Error>) -> Void) -> Cancellable {
        withData(for: .init(url: url), completion: completion)
    }



    @available(iOS 13.0, macOS 10.15, *)
    @discardableResult
    public func withData(for urlRequest: URLRequest, completion: @escaping (Result<Data, Error>) -> Void) -> Cancellable {
        guard let task = dataTask(with: urlRequest, completion: completion)
        else {
            // TODO: Return nil.
            return AnyCancellable { }
        }

        defer { task.resume() }

        return AnyCancellable {
            task.cancel()
        }
    }



    /// - Note: Data objects passed to *completion* match order of *urls*. First data object is for first URL etc.
    ///
    /// - Note: Then download for any of *urls* fails then all other downloads are cancelled.
    @available(iOS 13.0, macOS 10.15, *)
    @discardableResult @inlinable
    public func withData<URLs>(for urls: URLs, completion: @escaping (Result<[Data], Error>) -> Void) -> Cancellable
    where URLs : Sequence, URLs.Element == URL
    {
        withData(for: urls.lazy.map { .init(url: $0) }, completion: completion)
    }



    /// - Note: Data objects passed to *completion* match order of *urls*. First data object is for first URL etc.
    ///
    /// - Note: Then download for any of *urls* fails then all other downloads are cancelled.
    @available(iOS 13.0, macOS 10.15, *)
    @discardableResult
    public func withData<URLRequests>(for urlRequests: URLRequests, completion: @escaping (Result<[Data], Error>) -> Void) -> Cancellable
    where URLRequests : Sequence, URLRequests.Element == URLRequest
    {
        let taskSet = URLSessionTaskSet<Data>(urlRequests: urlRequests)
        defer {
            taskSet.run(
                taskFabric: { (urlRequest, taskHandler) in dataTask(with: urlRequest, completion: taskHandler) },
                completion: completion)
        }

        return taskSet
    }



    private static func processTaskCompletion(_ urlRequest: URLRequest, _ response: URLResponse?, _ error: Error?) throws {
        guard error == nil else { throw error! }
        guard let response = response else { throw KvError("Response is missing for download task with \(urlRequest)") }

        switch response {
        case let httpResponse as HTTPURLResponse:
            guard httpResponse.statusCode == 200 else { throw KvError("Unexpected HTTP status code \(httpResponse.statusCode) downloading data with \(urlRequest)") }
        default:
            break
        }
    }



    private func dataTask(with urlRequest: URLRequest, completion: @escaping (Result<Data, Error>) -> Void) -> URLSessionDataTask? {
        switch urlRequest.url {
        case let .some(url) where url.isFileURL:
            completion(.init { try .init(contentsOf: url) })

            return nil

        default:
            let urlSession = self.urlSession

            return urlSession.dataTask(with: urlRequest) { (data, response, error) in
                completion(.init {
                    try Self.processTaskCompletion(urlRequest, response, error)

                    guard let data = data else { throw KvError("There is no data downloaded with \(urlRequest)") }

                    urlSession.configuration.urlCache?.storeCachedResponse(.init(response: response!, data: data), for: urlRequest)

                    return data
                })
            }
        }
    }



    // MARK: .URLSessionTaskSet

    private class URLSessionTaskSet<T> : Cancellable {

        typealias TaskResult = Result<T, Error>
        typealias TaskHandler = (TaskResult) -> Void
        typealias TaskFabric = (URLRequest, @escaping TaskHandler) -> URLSessionTask?



        init<URLRequests>(urlRequests: URLRequests)
        where URLRequests : Sequence, URLRequests.Element == URLRequest
        {
            items = urlRequests.map { .init(for: $0) }
        }



        private let items: [Item]



        // MARK: Life Cycle

        func run(taskFabric: TaskFabric, completion: @escaping (Result<[T], Error>) -> Void) {
            let dispatchGroup = DispatchGroup()

            items.forEach { item in
                dispatchGroup.enter()

                item.run(taskFabric) { [weak self] (result) in
                    defer { dispatchGroup.leave() }

                    if case .failure = result {
                        self?.cancel()
                    }
                }
            }

            // - Note: `self` is strongly captured to prevent it's release.
            dispatchGroup.notify(queue: .global(qos: .userInitiated)) {
                var payload: [T] = .init()
                var errorMessages: [String] = .init()

                self.items.forEach { context in
                    switch context.result {
                    case .success(let value):
                        payload.append(value)
                    case .failure(let error):
                        errorMessages.append(error.localizedDescription)
                    case .none:
                        errorMessages.append("Unknown error")
                    }
                }

                completion(errorMessages.isEmpty ? .success(payload) : .failure(KvError(errorMessages.joined(separator: "\n"))))
            }
        }



        func cancel() {
            items.forEach { $0.cancel() }
        }



        // MARK: .Item

        class Item {

            let urlRequest: URLRequest

            var result: TaskResult? {
                get { KvThreadKit.locking(mutationLock) { _result } }
                set { KvThreadKit.locking(mutationLock) { _result = newValue } }
            }


            init(for urlRequest: URLRequest) {
                self.urlRequest = urlRequest
            }


            private let mutationLock = NSLock()

            private var task: URLSessionTask? {
                didSet {
                    oldValue?.cancel()
                    task?.resume()
                }
            }

            private var _result: TaskResult? = nil


            // MARK: Life Cycle

            func run(_ taskFabric: TaskFabric, completion: @escaping (TaskResult) -> Void) {
                do {
                    mutationLock.lock()
                    defer { mutationLock.unlock() }

                    guard _result == nil else { return completion(_result!) }
                }

                task = taskFabric(urlRequest) { [weak self] (result) in
                    defer { completion(result) }

                    self?.result = result
                }
            }


            func cancel() {
                guard result == nil else { return }

                task = nil
            }

        }

    }

}



// MARK: Removal

extension KvCachedAssets {

    public func resetCache() { urlSession.configuration.urlCache?.removeAllCachedResponses() }



    public func removeCachedResponse(for urlRequest: URLRequest) {
        urlSession.configuration.urlCache?.removeCachedResponse(for: urlRequest)
    }

}



#endif // canImport(Combine)
