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
//  KvBase16.swift
//  kvKit
//
//  Created by Svyatoslav Popov on 27.10.2023.
//

import Foundation



/// Collection of fast methods related to Base16 data encoding also known as hexadecimal representation.
public struct KvBase16 {

    private init() { }



    // MARK: .Options

    /// Options of Base64 encoding.
    public struct Options : OptionSet {

        /// Makes encoder to use uppercase letters. Lowercase letters are used by default.
        static let uppercase = Self(rawValue: 1 << 0)


        // MARK: : OptionSet

        public let rawValue: UInt

        @inlinable public init(rawValue: UInt) { self.rawValue = rawValue }
    }



    // MARK: Encoding

    // TODO: Add `borrowing` for `data` when Swift >= 5.9.
    /// - Returns: Hexadecimal representation of given *data* with given *ooptions*.
    @inlinable
    public static func encode(_ data: Data, options: Options = [ ]) -> String {
        if #available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *) {
            return encode_modern(data, options: options)
        } else {
            return encode_universal(data, options: options)
        }
    }

    @available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *)
    @inline(__always)
    @usableFromInline
    static func encode_modern(_ data: Data, options: Options) -> String {
        let lut = LUT.for(options)
        let capacity = 2 * data.count

        return String(unsafeUninitializedCapacity: capacity, initializingUTF8With: { buffer in
            var ptr1 = buffer.baseAddress!
            var ptr2 = ptr1.successor()

            data.regions.forEach { region in
                region.withUnsafeBytes {
                    var src = $0.baseAddress!
                    stride(from: 0, to: $0.count, by: 1).forEach { _ in
                        (ptr1.pointee, ptr2.pointee) = lut[numericCast(src.load(as: UInt8.self))]
                        src = src.successor()
                        ptr1 += 2
                        ptr2 += 2
                    }
                }
            }

            return capacity
        })
    }

    @inline(__always)
    @usableFromInline
    static func encode_universal(_ data: Data, options: Options) -> String {
        let lut = LUT.for(options)
        let capacity = 2 * data.count

        var result = String()
        result.reserveCapacity(capacity)

        data.regions.forEach { region in
            region.withUnsafeBytes {
                var src = $0.baseAddress!
                stride(from: 0, to: $0.count, by: 1).forEach { _ in
                    let values = lut[numericCast(src.load(as: UInt8.self))]
                    src = src.successor()
                    result.append(Character(.init(values.0)))
                    result.append(Character(.init(values.1)))
                }
            }
        }

        return result
    }


    // TODO: Add `borrowing` for `data` when Swift >= 5.9.
    /// - Returns: Hexadecimal representation of given *data* with given *ooptions*.
    @inlinable
    public static func encode<D>(_ data: D, options: Options = [ ]) -> String
    where D : DataProtocol
    {
        if #available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *) {
            return encode_modern(data, options: options)
        } else {
            return encode_universal(data, options: options)
        }
    }

    @available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *)
    @inline(__always)
    @usableFromInline
    static func encode_modern<D>(_ data: D, options: Options = [ ]) -> String
    where D : DataProtocol
    {
        let lut = LUT.for(options)
        let capacity = 2 * data.count

        return String(unsafeUninitializedCapacity: capacity, initializingUTF8With: { buffer in
            var ptr1 = buffer.baseAddress!
            var ptr2 = ptr1.successor()

            data.regions.forEach { region in
                region.withUnsafeBytes {
                    var src = $0.baseAddress!
                    stride(from: 0, to: $0.count, by: 1).forEach { _ in
                        (ptr1.pointee, ptr2.pointee) = lut[numericCast(src.load(as: UInt8.self))]
                        src = src.successor()
                        ptr1 += 2
                        ptr2 += 2
                    }
                }
            }

            return capacity
        })
    }

    @inline(__always)
    @usableFromInline
    static func encode_universal<D>(_ data: D, options: Options = [ ]) -> String
    where D : DataProtocol
    {
        let lut = LUT.for(options)
        let capacity = 2 * data.count

        var result = String()
        result.reserveCapacity(capacity)

        data.regions.forEach { region in
            region.withUnsafeBytes {
                var src = $0.baseAddress!
                stride(from: 0, to: $0.count, by: 1).forEach { _ in
                    let values = lut[numericCast(src.load(as: UInt8.self))]
                    src = src.successor()
                    result.append(Character(.init(values.0)))
                    result.append(Character(.init(values.1)))
                }
            }
        }

        return result
    }



    // MARK: Decoding

    // TODO: Add `borrowing` for `data` when Swift >= 5.9.
    /// - Returns: Data object represented by given hexadecimal string.
    @inlinable
    public static func decode<S>(_ string: S) -> Data?
    where S : StringProtocol
    {
        let digits = string.utf8

        guard (digits.count & 1) == 0 else { return nil }

        let count = digits.count >> 1
        let pointer = UnsafeMutablePointer<UInt8>.allocate(capacity: count)

        var dest = pointer
        var higherHalfFlag = true

        digits.withContiguousStorageIfAvailable { buffer -> Void? in
            var src = buffer.baseAddress!

            for _ in stride(from: 0, to: buffer.count, by: 1) {
                guard let halfByte = hexValue(ascii: src.pointee)
                else { return nil } // Any non-ASCII-7 UTF-8 character will fail here due to higher bit.

                switch higherHalfFlag {
                case true:
                    //higherHalfFlag = false
                    dest.pointee = halfByte << 4
                case false:
                    //higherHalfFlag = true
                    dest.pointee |= halfByte
                    dest = dest.successor()
                }

                higherHalfFlag.toggle()
                src = src.successor()
            }
        }
        ?? {
            for byte in digits {
                guard let halfByte = hexValue(ascii: byte)
                else { return nil } // Any non-ASCII-7 UTF-8 character will fail here due to higher bit.

                switch higherHalfFlag {
                case true:
                    dest.pointee = halfByte << 4
                case false:
                    dest.pointee |= halfByte
                    dest = dest.successor()
                }

                higherHalfFlag.toggle()
            }
        }()

        return .init(bytesNoCopy: pointer, count: count, deallocator: .free)
    }



    // MARK: Auxiliaries

    @inline(__always)
    @usableFromInline
    static func hexValue(ascii: UInt8) -> UInt8? {
        if ascii >= 0x30, ascii <= 0x39 {
            return ascii - 0x30
        }
        else if ascii >= 0x61, ascii <= 0x66 {
            return ascii - 0x61 + 0xA
        }
        else if ascii >= 0x41, ascii <= 0x46 {
            return ascii - 0x41 + 0xA
        }
        else { return nil }
    }



    // MARK: .LUT

    @usableFromInline
    struct LUT {

        @usableFromInline
        typealias Values = ContiguousArray<(UInt8, UInt8)>


        @usableFromInline
        static let lowercased: Values = [
            (0x30, 0x30), (0x30, 0x31), (0x30, 0x32), (0x30, 0x33), (0x30, 0x34), (0x30, 0x35), (0x30, 0x36), (0x30, 0x37), (0x30, 0x38), (0x30, 0x39), (0x30, 0x61), (0x30, 0x62), (0x30, 0x63), (0x30, 0x64), (0x30, 0x65), (0x30, 0x66),
            (0x31, 0x30), (0x31, 0x31), (0x31, 0x32), (0x31, 0x33), (0x31, 0x34), (0x31, 0x35), (0x31, 0x36), (0x31, 0x37), (0x31, 0x38), (0x31, 0x39), (0x31, 0x61), (0x31, 0x62), (0x31, 0x63), (0x31, 0x64), (0x31, 0x65), (0x31, 0x66),
            (0x32, 0x30), (0x32, 0x31), (0x32, 0x32), (0x32, 0x33), (0x32, 0x34), (0x32, 0x35), (0x32, 0x36), (0x32, 0x37), (0x32, 0x38), (0x32, 0x39), (0x32, 0x61), (0x32, 0x62), (0x32, 0x63), (0x32, 0x64), (0x32, 0x65), (0x32, 0x66),
            (0x33, 0x30), (0x33, 0x31), (0x33, 0x32), (0x33, 0x33), (0x33, 0x34), (0x33, 0x35), (0x33, 0x36), (0x33, 0x37), (0x33, 0x38), (0x33, 0x39), (0x33, 0x61), (0x33, 0x62), (0x33, 0x63), (0x33, 0x64), (0x33, 0x65), (0x33, 0x66),
            (0x34, 0x30), (0x34, 0x31), (0x34, 0x32), (0x34, 0x33), (0x34, 0x34), (0x34, 0x35), (0x34, 0x36), (0x34, 0x37), (0x34, 0x38), (0x34, 0x39), (0x34, 0x61), (0x34, 0x62), (0x34, 0x63), (0x34, 0x64), (0x34, 0x65), (0x34, 0x66),
            (0x35, 0x30), (0x35, 0x31), (0x35, 0x32), (0x35, 0x33), (0x35, 0x34), (0x35, 0x35), (0x35, 0x36), (0x35, 0x37), (0x35, 0x38), (0x35, 0x39), (0x35, 0x61), (0x35, 0x62), (0x35, 0x63), (0x35, 0x64), (0x35, 0x65), (0x35, 0x66),
            (0x36, 0x30), (0x36, 0x31), (0x36, 0x32), (0x36, 0x33), (0x36, 0x34), (0x36, 0x35), (0x36, 0x36), (0x36, 0x37), (0x36, 0x38), (0x36, 0x39), (0x36, 0x61), (0x36, 0x62), (0x36, 0x63), (0x36, 0x64), (0x36, 0x65), (0x36, 0x66),
            (0x37, 0x30), (0x37, 0x31), (0x37, 0x32), (0x37, 0x33), (0x37, 0x34), (0x37, 0x35), (0x37, 0x36), (0x37, 0x37), (0x37, 0x38), (0x37, 0x39), (0x37, 0x61), (0x37, 0x62), (0x37, 0x63), (0x37, 0x64), (0x37, 0x65), (0x37, 0x66),
            (0x38, 0x30), (0x38, 0x31), (0x38, 0x32), (0x38, 0x33), (0x38, 0x34), (0x38, 0x35), (0x38, 0x36), (0x38, 0x37), (0x38, 0x38), (0x38, 0x39), (0x38, 0x61), (0x38, 0x62), (0x38, 0x63), (0x38, 0x64), (0x38, 0x65), (0x38, 0x66),
            (0x39, 0x30), (0x39, 0x31), (0x39, 0x32), (0x39, 0x33), (0x39, 0x34), (0x39, 0x35), (0x39, 0x36), (0x39, 0x37), (0x39, 0x38), (0x39, 0x39), (0x39, 0x61), (0x39, 0x62), (0x39, 0x63), (0x39, 0x64), (0x39, 0x65), (0x39, 0x66),
            (0x61, 0x30), (0x61, 0x31), (0x61, 0x32), (0x61, 0x33), (0x61, 0x34), (0x61, 0x35), (0x61, 0x36), (0x61, 0x37), (0x61, 0x38), (0x61, 0x39), (0x61, 0x61), (0x61, 0x62), (0x61, 0x63), (0x61, 0x64), (0x61, 0x65), (0x61, 0x66),
            (0x62, 0x30), (0x62, 0x31), (0x62, 0x32), (0x62, 0x33), (0x62, 0x34), (0x62, 0x35), (0x62, 0x36), (0x62, 0x37), (0x62, 0x38), (0x62, 0x39), (0x62, 0x61), (0x62, 0x62), (0x62, 0x63), (0x62, 0x64), (0x62, 0x65), (0x62, 0x66),
            (0x63, 0x30), (0x63, 0x31), (0x63, 0x32), (0x63, 0x33), (0x63, 0x34), (0x63, 0x35), (0x63, 0x36), (0x63, 0x37), (0x63, 0x38), (0x63, 0x39), (0x63, 0x61), (0x63, 0x62), (0x63, 0x63), (0x63, 0x64), (0x63, 0x65), (0x63, 0x66),
            (0x64, 0x30), (0x64, 0x31), (0x64, 0x32), (0x64, 0x33), (0x64, 0x34), (0x64, 0x35), (0x64, 0x36), (0x64, 0x37), (0x64, 0x38), (0x64, 0x39), (0x64, 0x61), (0x64, 0x62), (0x64, 0x63), (0x64, 0x64), (0x64, 0x65), (0x64, 0x66),
            (0x65, 0x30), (0x65, 0x31), (0x65, 0x32), (0x65, 0x33), (0x65, 0x34), (0x65, 0x35), (0x65, 0x36), (0x65, 0x37), (0x65, 0x38), (0x65, 0x39), (0x65, 0x61), (0x65, 0x62), (0x65, 0x63), (0x65, 0x64), (0x65, 0x65), (0x65, 0x66),
            (0x66, 0x30), (0x66, 0x31), (0x66, 0x32), (0x66, 0x33), (0x66, 0x34), (0x66, 0x35), (0x66, 0x36), (0x66, 0x37), (0x66, 0x38), (0x66, 0x39), (0x66, 0x61), (0x66, 0x62), (0x66, 0x63), (0x66, 0x64), (0x66, 0x65), (0x66, 0x66),
        ]

        @usableFromInline
        static let uppercased: Values = [
            (0x30, 0x30), (0x30, 0x31), (0x30, 0x32), (0x30, 0x33), (0x30, 0x34), (0x30, 0x35), (0x30, 0x36), (0x30, 0x37), (0x30, 0x38), (0x30, 0x39), (0x30, 0x41), (0x30, 0x42), (0x30, 0x43), (0x30, 0x44), (0x30, 0x45), (0x30, 0x46),
            (0x31, 0x30), (0x31, 0x31), (0x31, 0x32), (0x31, 0x33), (0x31, 0x34), (0x31, 0x35), (0x31, 0x36), (0x31, 0x37), (0x31, 0x38), (0x31, 0x39), (0x31, 0x41), (0x31, 0x42), (0x31, 0x43), (0x31, 0x44), (0x31, 0x45), (0x31, 0x46),
            (0x32, 0x30), (0x32, 0x31), (0x32, 0x32), (0x32, 0x33), (0x32, 0x34), (0x32, 0x35), (0x32, 0x36), (0x32, 0x37), (0x32, 0x38), (0x32, 0x39), (0x32, 0x41), (0x32, 0x42), (0x32, 0x43), (0x32, 0x44), (0x32, 0x45), (0x32, 0x46),
            (0x33, 0x30), (0x33, 0x31), (0x33, 0x32), (0x33, 0x33), (0x33, 0x34), (0x33, 0x35), (0x33, 0x36), (0x33, 0x37), (0x33, 0x38), (0x33, 0x39), (0x33, 0x41), (0x33, 0x42), (0x33, 0x43), (0x33, 0x44), (0x33, 0x45), (0x33, 0x46),
            (0x34, 0x30), (0x34, 0x31), (0x34, 0x32), (0x34, 0x33), (0x34, 0x34), (0x34, 0x35), (0x34, 0x36), (0x34, 0x37), (0x34, 0x38), (0x34, 0x39), (0x34, 0x41), (0x34, 0x42), (0x34, 0x43), (0x34, 0x44), (0x34, 0x45), (0x34, 0x46),
            (0x35, 0x30), (0x35, 0x31), (0x35, 0x32), (0x35, 0x33), (0x35, 0x34), (0x35, 0x35), (0x35, 0x36), (0x35, 0x37), (0x35, 0x38), (0x35, 0x39), (0x35, 0x41), (0x35, 0x42), (0x35, 0x43), (0x35, 0x44), (0x35, 0x45), (0x35, 0x46),
            (0x36, 0x30), (0x36, 0x31), (0x36, 0x32), (0x36, 0x33), (0x36, 0x34), (0x36, 0x35), (0x36, 0x36), (0x36, 0x37), (0x36, 0x38), (0x36, 0x39), (0x36, 0x41), (0x36, 0x42), (0x36, 0x43), (0x36, 0x44), (0x36, 0x45), (0x36, 0x46),
            (0x37, 0x30), (0x37, 0x31), (0x37, 0x32), (0x37, 0x33), (0x37, 0x34), (0x37, 0x35), (0x37, 0x36), (0x37, 0x37), (0x37, 0x38), (0x37, 0x39), (0x37, 0x41), (0x37, 0x42), (0x37, 0x43), (0x37, 0x44), (0x37, 0x45), (0x37, 0x46),
            (0x38, 0x30), (0x38, 0x31), (0x38, 0x32), (0x38, 0x33), (0x38, 0x34), (0x38, 0x35), (0x38, 0x36), (0x38, 0x37), (0x38, 0x38), (0x38, 0x39), (0x38, 0x41), (0x38, 0x42), (0x38, 0x43), (0x38, 0x44), (0x38, 0x45), (0x38, 0x46),
            (0x39, 0x30), (0x39, 0x31), (0x39, 0x32), (0x39, 0x33), (0x39, 0x34), (0x39, 0x35), (0x39, 0x36), (0x39, 0x37), (0x39, 0x38), (0x39, 0x39), (0x39, 0x41), (0x39, 0x42), (0x39, 0x43), (0x39, 0x44), (0x39, 0x45), (0x39, 0x46),
            (0x41, 0x30), (0x41, 0x31), (0x41, 0x32), (0x41, 0x33), (0x41, 0x34), (0x41, 0x35), (0x41, 0x36), (0x41, 0x37), (0x41, 0x38), (0x41, 0x39), (0x41, 0x41), (0x41, 0x42), (0x41, 0x43), (0x41, 0x44), (0x41, 0x45), (0x41, 0x46),
            (0x42, 0x30), (0x42, 0x31), (0x42, 0x32), (0x42, 0x33), (0x42, 0x34), (0x42, 0x35), (0x42, 0x36), (0x42, 0x37), (0x42, 0x38), (0x42, 0x39), (0x42, 0x41), (0x42, 0x42), (0x42, 0x43), (0x42, 0x44), (0x42, 0x45), (0x42, 0x46),
            (0x43, 0x30), (0x43, 0x31), (0x43, 0x32), (0x43, 0x33), (0x43, 0x34), (0x43, 0x35), (0x43, 0x36), (0x43, 0x37), (0x43, 0x38), (0x43, 0x39), (0x43, 0x41), (0x43, 0x42), (0x43, 0x43), (0x43, 0x44), (0x43, 0x45), (0x43, 0x46),
            (0x44, 0x30), (0x44, 0x31), (0x44, 0x32), (0x44, 0x33), (0x44, 0x34), (0x44, 0x35), (0x44, 0x36), (0x44, 0x37), (0x44, 0x38), (0x44, 0x39), (0x44, 0x41), (0x44, 0x42), (0x44, 0x43), (0x44, 0x44), (0x44, 0x45), (0x44, 0x46),
            (0x45, 0x30), (0x45, 0x31), (0x45, 0x32), (0x45, 0x33), (0x45, 0x34), (0x45, 0x35), (0x45, 0x36), (0x45, 0x37), (0x45, 0x38), (0x45, 0x39), (0x45, 0x41), (0x45, 0x42), (0x45, 0x43), (0x45, 0x44), (0x45, 0x45), (0x45, 0x46),
            (0x46, 0x30), (0x46, 0x31), (0x46, 0x32), (0x46, 0x33), (0x46, 0x34), (0x46, 0x35), (0x46, 0x36), (0x46, 0x37), (0x46, 0x38), (0x46, 0x39), (0x46, 0x41), (0x46, 0x42), (0x46, 0x43), (0x46, 0x44), (0x46, 0x45), (0x46, 0x46),
        ]


        private init() { }


        @inline(__always)
        @usableFromInline
        static func `for`(_ options: Options) -> Values {
            !options.contains(.uppercase) ? lowercased : uppercased
        }

    }

}