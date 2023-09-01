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
//  KvByteOrderKit.swift
//  kvKit
//
//  Created by Svyatoslav Popov on 27.02.2021.
//

import CoreFoundation



// MARK: - KvByteOrderKit

public class KvByteOrderKit { }



// MARK: Swap

extension KvByteOrderKit {

    /// A boolean value indicating whether the host's byte-order doesn't mach the canonical byte-order (big-endian).
    public static var needsSwapBytes: Bool { CFByteOrderGetCurrent() == CFByteOrderLittleEndian.rawValue }



    public static func swapBytesIfNeeded<T>(to destination: UnsafeMutableBufferPointer<T>, from source: UnsafeBufferPointer<T>) where T : FixedWidthInteger {
        guard needsSwapBytes else { return }

        _swapBytes(to: destination, from: source)
    }



    @inlinable
    public static func swapBytesIfNeeded<T>(_ pointer: UnsafeMutableBufferPointer<T>) where T : FixedWidthInteger {
        swapBytesIfNeeded(to: pointer, from: .init(pointer))
    }



    public static func swapBytesIfNeeded(to destination: UnsafeMutableBufferPointer<Float>, from source: UnsafeBufferPointer<Float>) {
        guard needsSwapBytes else { return }

        _swapBytes(to: destination, from: source)
    }



    @inlinable
    public static func swapBytesIfNeeded(_ pointer: UnsafeMutableBufferPointer<Float>) {
        swapBytesIfNeeded(to: pointer, from: .init(pointer))
    }



    public static func swapBytesIfNeeded(to destination: UnsafeMutableBufferPointer<Double>, from source: UnsafeBufferPointer<Double>) {
        guard needsSwapBytes else { return }

        _swapBytes(to: destination, from: source)
    }



    @inlinable
    public static func swapBytesIfNeeded(_ pointer: UnsafeMutableBufferPointer<Double>) {
        swapBytesIfNeeded(to: pointer, from: .init(pointer))
    }



#if canImport(CoreGraphics)

    public static func swapBytesIfNeeded(to destination: UnsafeMutableBufferPointer<CGFloat>, from source: UnsafeBufferPointer<CGFloat>) {
        guard needsSwapBytes else { return }

        _swapBytes(to: destination, from: source)
    }



    @inlinable
    public static func swapBytesIfNeeded(_ pointer: UnsafeMutableBufferPointer<CGFloat>) {
        swapBytesIfNeeded(to: pointer, from: .init(pointer))
    }

#endif // canImport(CoreGraphics)



    @inlinable
    public static func swapBytesIfNeeded(to destination: UnsafeMutableRawBufferPointer, from source: UnsafeRawBufferPointer, stride: Int) {
        guard needsSwapBytes else { return }

        swapBytes(to: destination, from: source, stride: stride)
    }



    @inlinable
    public static func swapBytesIfNeeded(_ pointer: UnsafeMutableRawBufferPointer, stride: Int) {
        swapBytesIfNeeded(to: pointer, from: .init(pointer), stride: stride)
    }



    public static func swapBytes<T>(to destination: UnsafeMutableBufferPointer<T>, from source: UnsafeBufferPointer<T>) where T : FixedWidthInteger { _swapBytes(to: destination, from: source) }



    @inlinable
    public static func swapBytes<T>(_ pointer: UnsafeMutableBufferPointer<T>) where T : FixedWidthInteger { swapBytes(to: pointer, from: .init(pointer)) }



    public static func swapBytes(to destination: UnsafeMutableBufferPointer<Float>, from source: UnsafeBufferPointer<Float>) { _swapBytes(to: destination, from: source) }



    @inlinable
    public static func swapBytes(_ pointer: UnsafeMutableBufferPointer<Float>) { swapBytes(to: pointer, from: .init(pointer)) }



    public static func swapBytes(to destination: UnsafeMutableBufferPointer<Double>, from source: UnsafeBufferPointer<Double>) { _swapBytes(to: destination, from: source) }



    @inlinable
    public static func swapBytes(_ pointer: UnsafeMutableBufferPointer<Double>) { swapBytes(to: pointer, from: .init(pointer)) }



#if canImport(CoreGraphics)

    public static func swapBytes(to destination: UnsafeMutableBufferPointer<CGFloat>, from source: UnsafeBufferPointer<CGFloat>) { _swapBytes(to: destination, from: source) }



    @inlinable
    public static func swapBytes(_ pointer: UnsafeMutableBufferPointer<CGFloat>) { swapBytes(to: pointer, from: .init(pointer)) }

#endif // canImport(CoreGraphics)



    public static func swapBytes(to destination: UnsafeMutableRawBufferPointer, from source: UnsafeRawBufferPointer, stride: Int) {
        switch stride {
        case ...1:
            _swapBytes(to: destination.bindMemory(to: UInt8.self), from: source.bindMemory(to: UInt8.self))
        case 2:
            _swapBytes(to: destination.bindMemory(to: UInt16.self), from: source.bindMemory(to: UInt16.self))
        case 4:
            _swapBytes(to: destination.bindMemory(to: UInt32.self), from: source.bindMemory(to: UInt32.self))
        case 8:
            _swapBytes(to: destination.bindMemory(to: UInt64.self), from: source.bindMemory(to: UInt64.self))
        default:
            _swapBytes(to: destination, from: source, stride: stride)
        }
    }



    @inlinable
    public static func swapBytes(_ pointer: UnsafeMutableRawBufferPointer, stride: Int) { swapBytes(to: pointer, from: .init(pointer), stride: stride) }



    private static func _swapBytes<T>(to destination: UnsafeMutableBufferPointer<T>, from source: UnsafeBufferPointer<T>)
    where T : FixedWidthInteger
    {
        assert(source.count == destination.count)

        guard var src = source.baseAddress, var dest = destination.baseAddress else { return }

        (0 ..< source.count).forEach { _ in
            dest.pointee = src.pointee.byteSwapped
            src += 1
            dest += 1
        }
    }



    private static func _swapBytes<T>(to destination: UnsafeMutableBufferPointer<T>, from source: UnsafeBufferPointer<T>)
    where T : KvFixedWidthFloatingPoint
    {
        destination.withMemoryRebound(to: T.BitPattern.self) { dest in
            source.withMemoryRebound(to: T.BitPattern.self) { src in
                _swapBytes(to: dest, from: src)
            }
        }
    }



    private static func _swapBytes(to destination: UnsafeMutableRawBufferPointer, from source: UnsafeRawBufferPointer, stride: Int) {
        assert(stride >= 1)
        assert(source.count.isMultiple(of: stride))
        assert(source.count == destination.count)

        guard var src = source.bindMemory(to: UInt8.self).baseAddress,
              var dest = destination.bindMemory(to: UInt8.self).baseAddress
        else { return }

        switch stride > 1 {
        case true:
            (0 ..< (source.count / stride)).forEach { _ in
                var s1 = src, s2 = src + (stride - 1)
                var d1 = dest, d2 = dest + (stride - 1)

                while s1 < s2 {
                    // - Note: This value is stored to prevent memory corruption when source and destination are the same.
                    let t = s2.pointee

                    d2.pointee = s1.pointee
                    d1.pointee = t

                    s1 = s1.successor(); s2 = s2.predecessor()
                    d1 = d1.successor(); d2 = d2.predecessor()
                }

                if s1 == s2 {
                    d1.pointee = s1.pointee
                }

                src += stride
                dest += stride
            }

        case false:
            guard src.distance(to: dest) != 0 else { break }

            destination.copyMemory(from: source)
        }
    }

}



// MARK: Auxiliaries

extension KvByteOrderKit {

    @inlinable
    public static func toCanonical<T>(to destination: UnsafeMutableBufferPointer<T>, from source: UnsafeBufferPointer<T>) where T : FixedWidthInteger { swapBytesIfNeeded(to: destination, from: source) }

    @inlinable
    public static func toCanonical<T>(_ pointer: UnsafeMutableBufferPointer<T>) where T : FixedWidthInteger { swapBytesIfNeeded(pointer) }


    @inlinable
    public static func toCanonical(to destination: UnsafeMutableBufferPointer<Float>, from source: UnsafeBufferPointer<Float>) { swapBytesIfNeeded(to: destination, from: source) }

    @inlinable
    public static func toCanonical(_ pointer: UnsafeMutableBufferPointer<Float>) { swapBytesIfNeeded(pointer) }


    @inlinable
    public static func toCanonical(to destination: UnsafeMutableBufferPointer<Double>, from source: UnsafeBufferPointer<Double>) { swapBytesIfNeeded(to: destination, from: source) }

    @inlinable
    public static func toCanonical(_ pointer: UnsafeMutableBufferPointer<Double>) { swapBytesIfNeeded(pointer) }


#if canImport(CoreGraphics)

    @inlinable
    public static func toCanonical(to destination: UnsafeMutableBufferPointer<CGFloat>, from source: UnsafeBufferPointer<CGFloat>) { swapBytesIfNeeded(to: destination, from: source) }

    @inlinable
    public static func toCanonical(_ pointer: UnsafeMutableBufferPointer<CGFloat>) { swapBytesIfNeeded(pointer) }

#endif // canImport(CoreGraphics)


    @inlinable
    public static func toCanonical(to destination: UnsafeMutableRawBufferPointer, from source: UnsafeRawBufferPointer, stride: Int) { swapBytesIfNeeded(to: destination, from: source, stride: stride) }

    @inlinable
    public static func toCanonical(_ pointer: UnsafeMutableRawBufferPointer, stride: Int) { swapBytesIfNeeded(pointer, stride: stride) }



    @inlinable
    public static func toHost<T>(to destination: UnsafeMutableBufferPointer<T>, from source: UnsafeBufferPointer<T>) where T : FixedWidthInteger { swapBytesIfNeeded(to: destination, from: source) }

    @inlinable
    public static func toHost<T>(_ pointer: UnsafeMutableBufferPointer<T>) where T : FixedWidthInteger { swapBytesIfNeeded(pointer) }


    @inlinable
    public static func toHost(to destination: UnsafeMutableBufferPointer<Float>, from source: UnsafeBufferPointer<Float>) { swapBytesIfNeeded(to: destination, from: source) }

    @inlinable
    public static func toHost(_ pointer: UnsafeMutableBufferPointer<Float>) { swapBytesIfNeeded(pointer) }


    @inlinable
    public static func toHost(to destination: UnsafeMutableBufferPointer<Double>, from source: UnsafeBufferPointer<Double>) { swapBytesIfNeeded(to: destination, from: source) }

    @inlinable
    public static func toHost(_ pointer: UnsafeMutableBufferPointer<Double>) { swapBytesIfNeeded(pointer) }


#if canImport(CoreGraphics)

    @inlinable
    public static func toHost(to destination: UnsafeMutableBufferPointer<CGFloat>, from source: UnsafeBufferPointer<CGFloat>) { swapBytesIfNeeded(to: destination, from: source) }

    @inlinable
    public static func toHost(_ pointer: UnsafeMutableBufferPointer<CGFloat>) { swapBytesIfNeeded(pointer) }

#endif // canImport(CoreGraphics)


    @inlinable
    public static func toHost(to destination: UnsafeMutableRawBufferPointer, from source: UnsafeRawBufferPointer, stride: Int) { swapBytesIfNeeded(to: destination, from: source, stride: stride) }

    @inlinable
    public static func toHost(_ pointer: UnsafeMutableRawBufferPointer, stride: Int) { swapBytesIfNeeded(pointer, stride: stride) }

}



// MARK: - KvFixedWidthFloatingPoint

protocol KvFixedWidthFloatingPoint : FloatingPoint {

    associatedtype BitPattern where BitPattern : FixedWidthInteger


    var bitPattern: BitPattern { get }


    init(bitPattern: BitPattern)

}


extension Float : KvFixedWidthFloatingPoint { }

extension Double : KvFixedWidthFloatingPoint { }

#if canImport(CoreGraphics)

extension CGFloat : KvFixedWidthFloatingPoint { }

#endif // canImport(CoreGraphics)
