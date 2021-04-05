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
    public func withData(for url: URL, completion: @escaping (KvCancellableResult<Data>) -> Void) -> Cancellable? {
        withData(for: .init(url: url), completion: completion)
    }



    @available(iOS 13.0, macOS 10.15, *)
    @discardableResult
    public func withData(for urlRequest: URLRequest, completion: @escaping (KvCancellableResult<Data>) -> Void) -> Cancellable? {
        switch urlRequest.url {
        case let .some(url) where url.isFileURL:
            DispatchQueue.global(qos: .userInitiated).async {
                completion(.init { try .init(contentsOf: url) })
            }
            return nil

        default:
            let urlSession = self.urlSession

            let task = urlSession.dataTask(with: urlRequest) { (data, response, error) in
                completion(.init {
                    do {
                        guard error == nil else { throw error! }
                        guard let response = response else { throw KvError("Response is missing for download task with \(urlRequest)") }

                        switch response {
                        case let httpResponse as HTTPURLResponse:
                            guard httpResponse.statusCode == 200 else { throw KvError("Unexpected HTTP status code \(httpResponse.statusCode) downloading data with \(urlRequest)") }
                        default:
                            break
                        }
                    }

                    guard let data = data else { throw KvError("There is no data downloaded with \(urlRequest)") }

                    urlSession.configuration.urlCache?.storeCachedResponse(.init(response: response!, data: data), for: urlRequest)

                    return data
                })
            }

            defer { task.resume() }

            return AnyCancellable {
                task.cancel()
            }
        }
    }



    public typealias UrlRequestDataPair = KeyValuePairs<URLRequest, Data>.Element

    public typealias UrlRequestDataPairs = [UrlRequestDataPair]



    /// - Note: When download for any of *urls* fails then all other downloads are cancelled.
    @available(iOS 13.0, macOS 10.15, *)
    @discardableResult @inlinable
    public func withData<URLs>(for urls: URLs, completion: @escaping (KvCancellableResult<UrlRequestDataPairs>) -> Void) -> Cancellable?
    where URLs : Sequence, URLs.Element == URL
    {
        withData(for: urls.lazy.map { .init(url: $0) }, completion: completion)
    }



    /// - Note: When download for any of *urls* fails then all other downloads are cancelled.
    @available(iOS 13.0, macOS 10.15, *)
    @discardableResult
    public func withData<URLRequests>(for urlRequests: URLRequests, completion: @escaping (KvCancellableResult<UrlRequestDataPairs>) -> Void) -> Cancellable?
    where URLRequests : Sequence, URLRequests.Element == URLRequest
    {
        var iterator = urlRequests.makeIterator()

        guard let firstUrlRequest = iterator.next() else {
            defer { completion(.success(.init())) }
            return nil
        }


        func Run(_ urlRequest: URLRequest, in taskGroup: KvTaskGroup<UrlRequestDataPairs>) {
            taskGroup.enter {
                withData(for: urlRequest) { (dataResult) in
                    switch dataResult {
                    case .cancelled, .failure:
                        taskGroup.cancel()
                    case .success:
                        break
                    }

                    taskGroup.leave(with: dataResult.map { data in (urlRequest, data) })
                }
            }
        }


        let taskGroup = KvTaskGroup<UrlRequestDataPairs>()

        Run(firstUrlRequest, in: taskGroup)

        while let urlRequest = iterator.next() {
            Run(urlRequest, in: taskGroup)
        }

        taskGroup.notify(on: .global(qos: .userInitiated)) {
            completion($0.map { $0 ?? .init() })
        }

        return taskGroup
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
