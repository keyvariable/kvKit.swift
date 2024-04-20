//===----------------------------------------------------------------------===//
//
//  Copyright (c) 2024 Svyatoslav Popov (info@keyvar.com).
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
//  URLSession.swift
//  KvKit
//
//  Created by Svyatoslav Popov on 19.04.2024.
//

// Non-Apple systems
#if !canImport(Darwin) && canImport(FoundationNetworking)

import Foundation
import FoundationNetworking



/// The missing auxiliary async methods.
extension URLSession {

    public func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        try await withCheckedThrowingContinuation { continuation in
            URLSession.shared
                .dataTask(with: request) {
                    URLSession.processTaskCompletion($0, $1, $2, continuation, "data task")
                }
                .resume()
        }
    }


    @inlinable
    public func data(from url: URL) async throws -> (Data, URLResponse) { try await data(for: URLRequest(url: url)) }


    public func upload(for request: URLRequest, fromFile fileURL: URL) async throws -> (Data, URLResponse) {
        try await withCheckedThrowingContinuation { continuation in
            URLSession.shared
                .uploadTask(with: request, fromFile: fileURL) {
                    URLSession.processTaskCompletion($0, $1, $2, continuation, "file upload task")
                }
                .resume()
        }
    }


    public func upload(for request: URLRequest, from bodyData: Data) async throws -> (Data, URLResponse) {
        try await withCheckedThrowingContinuation { continuation in
            URLSession.shared
                .uploadTask(with: request, from: bodyData) {
                    URLSession.processTaskCompletion($0, $1, $2, continuation, "data upload task")
                }
                .resume()
        }
    }


    private static func processTaskCompletion(
        _ data: Data?, _ response: URLResponse?, _ error: Error?,
        _ continuation: CheckedContinuation<(Data, URLResponse), Error>,
        _ taskLabel: @escaping @autoclosure () -> String
    ) {
        switch (data, response, error) {
        case (_, .some(let response), .none):
            continuation.resume(returning: (data ?? Data(), response))
        case (_, _, .some(let error)):
            continuation.resume(throwing: error)
        case (_, .none, .none):
            continuation.resume(throwing: KvError("Unexpected case: a \(taskLabel()) completed with no error and no response"))
        }
    }

}

#endif // !canImport(Darwin) && canImport(FoundationNetworking)
