//===----------------------------------------------------------------------===//
//
//  Copyright (c) 2023 Svyatoslav Popov (info@keyvar.com).
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
//  KvBase64.swift
//  kvKit
//
//  Created by Svyatoslav Popov on 14.11.2023.
//

import Foundation



/// Collection of fast methods related to Base64 data encoding.
public struct KvBase64 { private init() { }

    // MARK: .Alphabet

    public enum Alphabet : Hashable, CaseIterable {

        case `default`

        /// Base 64 encoding with URL and filename safe alphabet. See [RFC 4648, section 5](https://datatracker.ietf.org/doc/html/rfc4648#section-5 ).
        case urlSafe

    }



    // MARK: Encoding

    // TODO: Add `borrowing` for `data` when Swift >= 5.9.
    /// - Returns: Base64 representation of given *data* with given *alphabet*.
    ///
    /// - SeeAlso: ``encodeAsString(_:alphabet:)``.
    @inlinable
    public static func encode(_ data: Data, alphabet: Alphabet? = nil) -> Data {
        var encoder = Encoder(sourceLength: data.count, alphabet)

        data.regions.forEach { region in
            region.withUnsafeBytes {
                encoder.process($0.baseAddress!.assumingMemoryBound(to: UInt8.self), limit: region.count)
            }
        }

        return encoder.finalize()
    }


    // TODO: Add `borrowing` for `data` when Swift >= 5.9.
    /// - Returns: Base64 representation of given *data* with given *alphabet*.
    ///
    /// - SeeAlso: ``encodeAsString(_:alphabet:)``.
    @inlinable
    public static func encode<D : DataProtocol>(_ data: D, alphabet: Alphabet? = nil) -> Data {
        var encoder = Encoder(sourceLength: data.count, alphabet)

        data.regions.forEach { region in
            region.withUnsafeBytes {
                encoder.process($0.baseAddress!.assumingMemoryBound(to: UInt8.self), limit: region.count)
            }
        }

        return encoder.finalize()
    }


    // TODO: Add `borrowing` for `data` when Swift >= 5.9.
    /// - Returns: Base64 representation of given *data* with given *alphabet*.
    ///
    /// - SeeAlso: ``encode(_:alphabet:)-84w6o``.
    @inlinable
    public static func encodeAsString<D : DataProtocol>(_ data: D, alphabet: Alphabet? = nil) -> String {
        var encoder = Encoder(sourceLength: data.count, alphabet)

        data.regions.forEach { region in
            region.withUnsafeBytes {
                encoder.process($0.baseAddress!.assumingMemoryBound(to: UInt8.self), limit: region.count)
            }
        }

        return .init(data: encoder.finalize(), encoding: .utf8)!
    }



    // MARK: .Encoder

    public struct Encoder {

        @inlinable
        public init(sourceLength: Int? = nil, _ alphabet: Alphabet?) {
            data = sourceLength.map { Data(capacity: (($0 + 2) / 3) * 4) } ?? .init()

            switch alphabet {
            case .default, .none:
                (char62, char63, padding) = (0x2B/* + */, 0x2F/* / */, 0x3D/* = */)
            case .urlSafe:
                (char62, char63, padding) = (0x2D/* - */, 0x5F/* _ */, 0)
            }
        }


        @usableFromInline
        var data: Data

        /// Lower 24 bits are the buffer, higher 8 bits are count of bytes in the buffer.
        @usableFromInline
        var buffer: UInt32 = 0

        @usableFromInline
        let char62, char63: UInt8
        /// 0 means no padding.
        @usableFromInline
        let padding: UInt8


        // MARK: Operations

        /// - Important: ``finalize()`` must be called when input is finished.
        @inlinable
        public mutating func process(_ pointer: UnsafePointer<UInt8>, limit: Int) {
            guard limit > 0 else { return }

            var pointer = pointer
            var limit = limit


            func appendCompleteBuffer() {
                for shift in stride(from: 18, through: 0, by: -6) {
                    data.append(encodedByte(shift: shift))
                }

                buffer = 0
            }


            // Processing of pending bytes

            switch buffer >> 24 {
            case 0:
                break

            case 1:
                buffer = (2 << 24) | (buffer & 0x00_FF0000) | ((numericCast(pointer.pointee) as UInt32) << 8)
                pointer = pointer.successor()
                limit -= 1

                guard limit > 0 else { return }

                fallthrough

            case 2:
                buffer = (3 << 24) | (buffer & 0x00_FFFF00) | (numericCast(pointer.pointee) as UInt32)
                pointer = pointer.successor()
                limit -= 1

                appendCompleteBuffer()

            default:
                assertionFailure("Unexpected count in buffer: \(String(format: "0x08X", buffer))")
            }

            // Processing complete triplets

            while limit >= 3 {
                let b0: UInt32 = numericCast(pointer.pointee) << 16
                pointer = pointer.successor()
                let b1: UInt32 = numericCast(pointer.pointee) << 8
                pointer = pointer.successor()

                assert(buffer == 0)
                buffer = b0 | b1 | (numericCast(pointer.pointee) as UInt32)

                appendCompleteBuffer()

                pointer = pointer.successor()
                limit -= 3
            }

            // Processing the rest

            switch limit {
            case 0:
                break
            case 1:
                buffer = (1 << 24) | ((numericCast(pointer.pointee) as UInt32) << 16)
            case 2:
                let b0: UInt32 = numericCast(pointer.pointee) << 16
                pointer = pointer.successor()
                buffer = (2 << 24) | b0 | ((numericCast(pointer.pointee) as UInt32) << 8)
            default:
                assertionFailure("Unexpected limit (\(limit)) at the end")
            }
        }


        /// - Important: The receiver becomes invalid when finalized.
        ///
        /// - SeeAlso: ``process(_:limit:)``.
        @inlinable
        public mutating func finalize() -> Data {
            let count: Int = numericCast(buffer >> 24)

            if count > 0 {
                var shift = 18

                for _ in 0...count {
                    data.append(encodedByte(shift: shift))
                    shift -= 6
                }

                if padding != 0 {
                    data.append(contentsOf: repeatElement(padding, count: 3 - count))
                }
            }

            return data
        }


        @inline(__always)
        @usableFromInline
        func encodedByte(shift: Int) -> UInt8 {
            let element = (buffer >> shift) & 0x3F

            return if element < 26 { numericCast(0x41 + element) }
            else if element < 52 { numericCast(0x61 + (element - 26)) }
            else if element < 62 { numericCast(0x30 + (element - 52)) }
            else if element == 62 { char62 }
            else { char63 }
        }

    }

}
