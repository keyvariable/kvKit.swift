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
//  KvCompressionKit.swift
//  KvKit
//
//  Created by Svyatoslav Popov on 13.09.2020.
//

#if canImport(Compression)



import Compression
import Foundation



/// High-level wrapper for *Compression* framework.
public class KvCompressionKit { }



// MARK: Constants

extension KvCompressionKit {

    /// Byte size of internal buffers.
    public static let bufferSize = 32 << 10

}



// MARK: Compression

extension KvCompressionKit {

    /// Performs *operation* using *algorithm* reading data from *input* and writting the result to *output*.
    @available (iOS 13.0, macOS 10.15, *)
    public static func run(_ operation: FilterOperation, using algorithm: Algorithm, input: Input, output: Output) throws {

        /// - Returns: Opens given *stream* when it's status is `.notOpen` and returns a RAII token closing the stream. Otherwise `nil` is returned.
        func OpenOfNotOpen(_ stream: Stream) throws -> KvRAII.Token? {
            guard stream.streamStatus == .notOpen else { return nil }

            stream.open()
            guard stream.streamStatus == .open else {
                throw KvError("Unable to open \(stream) stream")
            }

            return KvRAII.Token { (_, _) in
                stream.close()
            }
        }


        var tokens: (input: KvRAII.Token?, output: KvRAII.Token?) = (nil, nil)
        defer {
            // - Note: .release() is called to prevent the warning.
            tokens.input?.release()
            tokens.output?.release()
        }

        let outputFilter: OutputFilter = try {
            let writingBlock: (Data?) throws -> Void

            switch output {
            case .callback(let block):
                writingBlock = block

            case .stream(let outputStream):
                tokens.output = try OpenOfNotOpen(outputStream)

                writingBlock = {
                    guard let data = $0, !data.isEmpty else { return }

                    data.withUnsafeBytes { (rawBuffer) in
                        _ = outputStream.write(rawBuffer.baseAddress!.assumingMemoryBound(to: UInt8.self), maxLength: rawBuffer.count)
                    }
                }

            case let .url(url, overwriteFlag):
                let fileManager = FileManager.default
                let temporaryFileURL = try fileManager.url(for: .itemReplacementDirectory, in: .userDomainMask, appropriateFor: url, create: true)
                    .appendingPathComponent(ProcessInfo().globallyUniqueString)

                guard let outputStream = OutputStream(url: temporaryFileURL, append: false) else {
                    throw KvError("Unable to create an output stream for «\(temporaryFileURL)» URL")
                }

                outputStream.open()
                guard outputStream.streamStatus == .open else {
                    throw KvError("Unable to open an output stream for «\(temporaryFileURL)» URL")
                }

                writingBlock = {
                    switch $0 {
                    case .some(let data):
                        data.withUnsafeBytes { (rawBuffer) in
                            _ = outputStream.write(rawBuffer.baseAddress!.assumingMemoryBound(to: UInt8.self), maxLength: rawBuffer.count)
                        }

                    case .none:
                        outputStream.close()

                        do {
                            overwriteFlag
                                ? (_ = try fileManager.replaceItemAt(url, withItemAt: temporaryFileURL))
                                : try fileManager.moveItem(at: temporaryFileURL, to: url)

                        } catch {
                            do {
                                try fileManager.removeItem(at: temporaryFileURL)

                            } catch {
                                KvDebug.pause("Unable to remove a temporary file at \(temporaryFileURL) with error: \(error)")
                            }

                            throw KvError("Unable to \(overwriteFlag ? "replace a file at \(url) with temporary file at \(temporaryFileURL)" : "move a temporary file at \(temporaryFileURL) to \(url)") with error: \(error)")
                        }
                    }
                }
            }

            return try .init(operation, using: algorithm, writingTo: writingBlock)
        }()

        switch input {
        case .block(let block):
            try block(.init(for: outputFilter))

        case .stream(let inputStream):
            tokens.input = try OpenOfNotOpen(inputStream)

            let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
            defer { buffer.deallocate() }

            while true {
                let bytesRead = inputStream.read(buffer, maxLength: bufferSize)

                guard bytesRead > 0 else { break }

                try outputFilter.write(UnsafeRawBufferPointer(start: buffer, count: bufferSize))
            }
        }

        try outputFilter.finalize()
    }



    /// - Returns: Data object containing the result of *operation* using *algorithm*.
    @available (iOS 13.0, macOS 10.15, *) @inlinable
    public static func data(from input: Input, filter operation: FilterOperation, using algorithm: Algorithm) throws -> Data {
        let memoryStream = OutputStream(toMemory: ())

        try run(operation, using: algorithm, input: input, output: .stream(memoryStream))

        return memoryStream.property(forKey: .dataWrittenToMemoryStreamKey) as! Data
    }

}



// MARK: .Input

extension KvCompressionKit {

    public enum Input {

        /// This block is invoked at appropriate moment. This block should pass all the data to given interface.
        @available (iOS 13.0, macOS 10.15, *)
        case block((Interface) throws -> Void)

        /// All data currently available in the stream will be processed.
        case stream(InputStream)



        // MARK: .Interface

        @available (iOS 13.0, macOS 10.15, *)
        public struct Interface {

            fileprivate init(for outputFilter: OutputFilter) {
                self.outputFilter = outputFilter
            }


            private let outputFilter: OutputFilter


            // MARK: Output

            /// Writes bytes of *value* to the output.
            public func write<T>(value: T) throws { try withUnsafeBytes(of: value) { try outputFilter.write($0) } }


            /// Writes *data* to the output.
            public func write<D>(data: D) throws where D : DataProtocol { try outputFilter.write(data) }

        }

    }

}



// MARK: .Output

extension KvCompressionKit {

    public enum Output {

        /// The callback block is invoked with the resulting data chunks and `nil` at the end.
        case callback((Data?) throws -> Void)

        /// The resulting data is written to the stream.
        case stream(OutputStream)

        /// The resulting data is saved to a temporary file and then moved to the url.
        case url(url: URL, overwriting: Bool)

    }

}



#endif // canImport(Compression)
