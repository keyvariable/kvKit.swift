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
//  KvCVPixelBufferKit.swift
//  kvKit
//
//  Created by Svyatoslav Popov on 11.05.2021.
//

#if canImport(CoreImage)

import CoreImage
import Foundation

import simd



/// Collection of auxiliaries related to *CVPixelBuffer*.
public struct KvCVPixelBufferKit { private init() { } }



// MARK: .Sampler

extension KvCVPixelBufferKit {

    /// Reads pixel data from pixel buffers. Provides nearest and bilinear sampling algorithms.
    public class Sampler<Texel : SIMDScalar> {

        public typealias Texel = Texel



        public let buffer: CVPixelBuffer


        @usableFromInline
        let pointer: UnsafePointer<Texel>

        @usableFromInline
        let rowSize: Int
        @usableFromInline
        let maximumCoordinate: SIMD2<Int>

        /// Transformation of normalized coordinates to absolute coordinates.
        @usableFromInline
        let normalizedScale: simd_float2



        /// - Note: Sampler locks base address of buffer immediately and unlocks is when dealocated.
        public init(for buffer: CVPixelBuffer) {
            self.buffer = buffer

            CVPixelBufferLockBaseAddress(buffer, .readOnly)

            let baseAddress = CVPixelBufferGetBaseAddress(buffer)!

            pointer = .init(baseAddress.assumingMemoryBound(to: Texel.self))
            rowSize = CVPixelBufferGetBytesPerRow(buffer) / MemoryLayout<Texel>.stride

            let width = CVPixelBufferGetWidth(buffer)
            let height = CVPixelBufferGetHeight(buffer)

            maximumCoordinate = .init(x: width - 1, y: height - 1)
            normalizedScale = .init(x: Float(width), y: Float(height))
        }



        deinit {
            CVPixelBufferUnlockBaseAddress(buffer, .readOnly)
        }



        // MARK: .Mapping

        public enum Mapping {

            /// Coordinates are in pixels.
            case absolute

            /// Coordinates are relative to image size. 0 is mapped to the minimum image edge, 1 is mapped to the maximum image edge.
            case normalized

        }



        // MARK: Operations

        @inlinable
        public func load(x: Int, y: Int) -> Texel {
            pointer[clamp(y, 0, maximumCoordinate.y) * rowSize + clamp(x, 0, maximumCoordinate.x)]
        }



        @inlinable
        public func nearest(at location: simd_float2, mapping: Mapping = .absolute) -> Texel {
            let location = coordinate(for: location, mapping: mapping).rounded(.toNearestOrAwayFromZero)

            return load(x: Int(location.x), y: Int(location.y))
        }



        @inlinable
        public func coordinate(for location: simd_float2, mapping: Mapping) -> simd_float2 {
            switch mapping {
            case .absolute:
                return location
            case .normalized:
                return location * normalizedScale
            }
        }

    }

}



// MARK: .Sampler where Texel == BinaryFloatingPoint

extension KvCVPixelBufferKit.Sampler where Texel : BinaryFloatingPoint {

    @inlinable
    public func bilinear(at location: simd_float2, mapping: Mapping = .absolute) -> Texel {

        func Decomposition(of scalar: Float) -> (min: Int, max: Int, mix: Texel) {
            let (xMin, xMix) = { (Int($0.0), $0.1) }(modf(scalar - 0.5))

            return (xMin, xMin + 1, Texel(xMix))
        }


        let location = coordinate(for: location, mapping: mapping)
        let x = Decomposition(of: location.x), y = Decomposition(of: location.y)

        return mix(mix(load(x: x.min, y: y.min), load(x: x.max, y: y.min), t: x.mix),
                   mix(load(x: x.min, y: y.max), load(x: x.max, y: y.max), t: x.mix),
                   t: y.mix)
    }

}



// MARK: .Pool

extension KvCVPixelBufferKit {

    /// A wrapper for *CVPixelBufferPool*.
    public class Pool {

        public typealias PixelFormat = OSType



        public var pixelFormat: PixelFormat {
            didSet {
                guard pixelFormat != oldValue else { return }

                pixelBufferPool = nil
            }
        }

        public let options: Options


        /// In pixels.
        public var bufferSize: BufferSize = .zero {
            didSet {
                guard bufferSize != oldValue else { return }

                pixelBufferPool = nil
            }
        }



        public init(cvPixelFormat: PixelFormat = 0, options: Options = [ ]) {
            self.pixelFormat = cvPixelFormat
            self.options = options
        }



        private var pixelBufferPool: CVPixelBufferPool?

        private lazy var ciContext: CIContext = .init()



        // MARK: .Options

        public struct Options : OptionSet {

            public static let ioSurfaceCoreAnimationCompatibility = Self(rawValue: 1 << 0)


            // MARK: : OptionSet

            public let rawValue: UInt

            public init(rawValue: UInt) { self.rawValue = rawValue }

        }



        // MARK: .PixelSize

        public struct BufferSize : Equatable {

            public static let zero: Self = .init(width: 0, height: 0)


            public var width, height: Int


            public init(width: Int, height: Int) {
                self.width = width
                self.height = height
            }

        }



        // MARK: Operations

        public func configure(for pixelBuffer: CVPixelBuffer) {
            pixelFormat = CVPixelBufferGetPixelFormatType(pixelBuffer)

            bufferSize = BufferSize(width: CVPixelBufferGetWidth(pixelBuffer),
                                  height: CVPixelBufferGetHeight(pixelBuffer))
        }



        public func dequePixelBuffer(with content: CIImage? = nil) throws -> CVPixelBuffer {
            if pixelBufferPool == nil {
                pixelBufferPool = try newPixelBufferPool()
            }

            let pixelBuffer: CVPixelBuffer = try {
                var pixelBuffer: CVPixelBuffer?

                CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, pixelBufferPool!, &pixelBuffer)

                guard pixelBuffer != nil else { throw PoolError.unableToCreatePixelBuffer }

                return pixelBuffer!
            }()

            if let content = content {
                ciContext.render(content, to: pixelBuffer)
            }

            return pixelBuffer
        }



        // MARK: Auxiliaries

        private func newPixelBufferPool() throws -> CVPixelBufferPool {
            var pixelBufferPool: CVPixelBufferPool?

            let pixelBufferAttributes = [
                kCVPixelBufferPixelFormatTypeKey: pixelFormat,
                kCVPixelBufferWidthKey: bufferSize.width,
                kCVPixelBufferHeightKey: bufferSize.height,
                kCVPixelBufferCGImageCompatibilityKey: true,
                kCVPixelBufferIOSurfaceCoreAnimationCompatibilityKey: options.contains(.ioSurfaceCoreAnimationCompatibility),
            ] as [CFString : Any] as CFDictionary

            CVPixelBufferPoolCreate(kCFAllocatorDefault, nil, pixelBufferAttributes, &pixelBufferPool)

            guard pixelBufferPool != nil else { throw PoolError.unableToCreatePixelBufferPool }

            return pixelBufferPool!
        }

    }

}



// MARK: .PoolError

extension KvCVPixelBufferKit {

    public enum PoolError : LocalizedError {

        case unableToCreatePixelBuffer
        case unableToCreatePixelBufferPool


        // MARK: : LocalizedError

        public var errorDescription: String? {
            switch self {
            case .unableToCreatePixelBuffer:
                return "Unable to create a pixel buffer"
            case .unableToCreatePixelBufferPool:
                return "Unable to create a pixel buffer pool"
            }
        }

    }

}

#endif // canImport(CoreImage)
