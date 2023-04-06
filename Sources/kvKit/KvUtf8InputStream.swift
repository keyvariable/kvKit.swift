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
//  KvUtf8InputStream.swift
//  kvKit
//
//  Created by Svyatoslav Popov on 04.05.2019.
//

import Foundation



/// Wrapper for *UTF8* codec decoding bytes from an input stream.
public class KvUtf8InputStream {

    public init?(_ inputStream: InputStream) {
        sourceIterator = SourceIterator(inputStream)

        resultBuffer.reserveCapacity(Self.resultBufferSize / MemoryLayout<Unicode.Scalar>.size)
    }



    @inlinable
    public convenience init?(url: URL) {
        guard let inputStream = InputStream(url: url) else { return nil }

        self.init(inputStream)
    }



    @inlinable
    public convenience init?(path: String) {
        guard let inputStream = InputStream(fileAtPath: path) else { return nil }

        self.init(inputStream)
    }



    private static let resultBufferCapacity = (32 << 10) / MemoryLayout<Unicode.Scalar>.size



    private var sourceIterator: SourceIterator

    private var resultBuffer: [Unicode.Scalar] = .init()

}



// MARK: Constants

extension KvUtf8InputStream {

    public static let resultBufferSize = 32 << 10

}



// MARK: Operation

extension KvUtf8InputStream {

    /// - Note: *callback* can be invoked multiple times.
    public func run(_ callback: (Result<[Unicode.Scalar], Error>) -> Void) {

        func EmitResult(_ callback: (Result<[Unicode.Scalar], Error>) -> Void) {
            guard !resultBuffer.isEmpty else { return }

            callback(.success(resultBuffer))

            resultBuffer.removeAll(keepingCapacity: true)
        }


        var codec: UTF8 = .init()

        while true {
            switch codec.decode(&sourceIterator) {
            case .scalarValue(let scalar):
                resultBuffer.append(scalar)

                if resultBuffer.count >= KvUtf8InputStream.resultBufferCapacity {
                    EmitResult(callback)
                }

            case .emptyInput:
                return EmitResult(callback)

            case .error:
                return callback(.failure(KvError("Failed to decode Unicode scalars")))
            }
        }
    }

}



// MARK: Source Iterator

extension KvUtf8InputStream {

    private class SourceIterator : IteratorProtocol {

        init(_ stream: InputStream) {
            inputStream = stream

            inputStream.open()

            readBytes()
        }



        deinit {
            inputStream.close()
        }



        private static let readBufferCapacity = 4096



        private let inputStream: InputStream

        private var buffer: Data = .init(count: SourceIterator.readBufferCapacity)

        private var count = 0
        private var offset = 0



        func next() -> UInt8? {
            guard count > 0 else { return nil }

            defer {
                offset += 1

                if offset >= count {
                    readBytes()
                }
            }

            return buffer[offset]
        }



        private func readBytes() {
            count = buffer.withUnsafeMutableBytes { (pointer) in
                return inputStream.read(pointer.baseAddress!.bindMemory(to: UInt8.self, capacity: SourceIterator.readBufferCapacity), maxLength: SourceIterator.readBufferCapacity)
            }

            if count < 0 {
                fatalError("Input stream has failed with error: \(inputStream.streamError?.localizedDescription ?? "`nil`")")
            }

            offset = 0
        }

    }

}
