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
//  KvCancellableResult.swift
//  kvKit
//
//  Created by Svyatoslav Popov on 06.04.2021.
//

import Foundation



public enum KvCancellableResult<T> {

    case success(T), cancelled, failure(Error)

}



// MARK: Auxiliaries

extension KvCancellableResult {

    public init(catching body: () throws -> T) {
        do { self = .success(try body()) }
        catch { self.init(error) }
    }



    public init(_ error: Error) {
        switch error {
        case let nsError as NSError where nsError.code == NSURLErrorCancelled:
            self = .cancelled
        default:
            self = .failure(error)
        }
    }



    public init<E : Error>(from result: Result<T, E>) {
        switch result {
        case .failure(let error):
            self.init(error)
        case .success(let value):
            self = .success(value)
        }
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



    public func map<Y>(_ transform: (T) throws -> Y) -> KvCancellableResult<Y> {
        switch self {
        case .cancelled:
            return .cancelled
        case .failure(let error):
            return .failure(error)
        case .success(let value):
            do { return .success(try transform(value)) }
            catch { return .failure(error) }
        }
    }

}



// MARK: <Void>

extension KvCancellableResult where T == Void {

    // TODO: Delete in 5.0.0
    @available (*, deprecated, message: "It's deprecated due to equivalence to .map({ nil })")
    public func map<Y>() -> KvCancellableResult<Y> where Y : ExpressibleByNilLiteral {
        switch self {
        case .cancelled:
            return .cancelled
        case .failure(let error):
            return .failure(error)
        case .success:
            return .success(nil)
        }
    }



    @inlinable
    public func map<Y>(_ transform: () throws -> Y) -> KvCancellableResult<Y> {
        map({ _ in try transform() })
    }

}
