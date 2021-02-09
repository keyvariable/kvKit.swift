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

    @available (iOS 13.0, macOS 10.15, *)
    public func withData(for url: URL, completion: @escaping (Result<Data, Error>) -> Void) -> Cancellable {
        let task = dataTask(with: .init(url: url), completion: completion)
        defer { task.resume() }

        return AnyCancellable {
            task.cancel()
        }
    }



    /// - Note: Data objects passed to *completion* match order of *urls*. First data object is for first URL etc.
    ///
    /// - Note: Then download for any of *urls* fails then all other downloads are cancelled.
    @available (iOS 13.0, macOS 10.15, *)
    public func withData(for urls: [URL], completion: @escaping (Result<[Data], Error>) -> Void) -> Cancellable {
        let taskSet = URLSessionTaskSet<Data>(urls: urls)
        defer {
            taskSet.run(taskFabric: { (url, taskHandler) in dataTask(with: .init(url: url), completion: taskHandler) },
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



    private func dataTask(with urlRequest: URLRequest, completion: @escaping (Result<Data, Error>) -> Void) -> URLSessionDataTask {
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



    private func downloadTask(with urlRequest: URLRequest, completion: @escaping (Result<KvFileKit.TemporaryUrlToken, Error>) -> Void) -> URLSessionDownloadTask {
        let urlSession = self.urlSession

        return urlSession.downloadTask(with: urlRequest) { (url, response, error) in
            completion(.init {
                try Self.processTaskCompletion(urlRequest, response, error)

                guard let url = url else { throw KvError("There is no url downloaded with \(urlRequest)") }

                urlSession.configuration.urlCache?.storeCachedResponse(.init(response: response!, data: try .init(contentsOf: url)), for: urlRequest)

                return .init(with: url)
            })
        }
    }



    // MARK: .URLSessionTaskSet

    private class URLSessionTaskSet<T> : Cancellable {

        typealias TaskResult = Result<T, Error>
        typealias TaskHandler = (TaskResult) -> Void
        typealias TaskFabric = (URL, @escaping TaskHandler) -> URLSessionTask



        init(urls: [URL]) {
            items = urls.map { .init(url: $0) }
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

            let url: URL

            var result: TaskResult? {
                get { KvThreadKit.locking(mutationLock) { _result } }
                set { KvThreadKit.locking(mutationLock) { _result = newValue } }
            }


            init(url: URL) {
                self.url = url
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

                task = taskFabric(url) { [weak self] (result) in
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

}



#endif // canImport(Combine)
