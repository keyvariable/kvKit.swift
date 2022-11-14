//===----------------------------------------------------------------------===//
//
//  Copyright (c) 2022 Svyatoslav Popov.
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
//  KvMetalKit.swift
//  kvKit
//
//  Created by Svyatoslav Popov on 21.04.2022.
//

import Metal
import simd



/// Collection of auxiliaries related to *MetalKit*.
public struct KvMetalKit { private init() { } }



// MARK: - Textures

extension KvMetalKit {

    /// - Returns: Given color component as an unsigned byte integer.
    @inlinable
    public static func colorComponent<T : BinaryFloatingPoint>(from value: T) -> UInt8 {
        UInt8(round(255 * clamp(value, 0, 1)))
    }


    /// - Returns: A cube texture filled with given *pattern* texel.
    public static func unicolorCubeTexture<Texel>(repeating pattern: Texel, with descriptor: MTLTextureDescriptor, on device: MTLDevice? = nil) throws -> MTLTexture {
        let device = try device ?? {
            switch MTLCreateSystemDefaultDevice() {
            case .some(let device):
                return device
            case .none:
                throw KvError("There is no system Metal device")
            }
        }()

        guard let texture = device.makeTexture(descriptor: descriptor) else { throw KvError("Failed to create unicolor cube texture with descriptor: \(descriptor)") }

        texture.label = "Unicolor"

        let sliceBytes = UnsafeMutableBufferPointer<Texel>.allocate(capacity: descriptor.width * descriptor.height)
        defer { sliceBytes.deallocate() }

        sliceBytes.assign(repeating: pattern)

        (0..<6).forEach { slice in
            texture.replace(region: .init(origin: .init(x: 0, y: 0, z: 0),
                                          size: .init(width: descriptor.width, height: descriptor.height, depth: 1)),
                            mipmapLevel: 0,
                            slice: slice,
                            withBytes: sliceBytes.baseAddress!,
                            bytesPerRow: descriptor.width * MemoryLayout<Texel>.stride,
                            bytesPerImage: descriptor.width * descriptor.height * MemoryLayout<Texel>.stride)
        }

        return texture
    }


    /// - Returns: A cube texture filled with given RGBA pattern.
    @inlinable
    public static func unicolorCubeTexture(
        repeating pattern: RGBA8,
        size: Int = 16,
        usage: MTLTextureUsage = .shaderRead,
        on device: MTLDevice? = nil
    ) throws -> MTLTexture {
        let descriptor = MTLTextureDescriptor.textureCubeDescriptor(pixelFormat: .rgba8Unorm, size: size, mipmapped: false)
        descriptor.pixelFormat = pattern.pixelFormat
        descriptor.usage = usage

        return try unicolorCubeTexture(repeating: pattern.texel, with: descriptor, on: device)
    }


    @inlinable
    public static func generateMipmaps(for texture: MTLTexture, commandBuffer: MTLCommandBuffer) throws {
        guard let blitEncoder = commandBuffer.makeBlitCommandEncoder() else { throw KvError("Failed to create Metal blit command encoder") }

        blitEncoder.generateMipmaps(for: texture)

        blitEncoder.endEncoding()
    }


    @inlinable
    public static func generateMipmaps<Textures>(for textures: Textures, commandBuffer: MTLCommandBuffer) throws
    where Textures : Sequence, Textures.Element == MTLTexture {
        guard let blitEncoder = commandBuffer.makeBlitCommandEncoder() else { throw KvError("Failed to create Metal blit command encoder") }

        textures.forEach(blitEncoder.generateMipmaps(for:))

        blitEncoder.endEncoding()
    }



    // MARK: .RGBA8

    /// Input providing pixel format, color and opacity compnents.
    public enum RGBA8 {

        /// A gray scale color.
        case grayScale(Float, alpha: Float = 1, srgb: Bool = false)

        /// A value in standard hex format `0xAARRGGBB`.
        case hex(UInt32, srgb: Bool = false)

        /// Four normalized color components of *Float* type.
        case rgba(r: Float, g: Float, b: Float, a: Float = 1, srgb: Bool = false)

        /// A vector where RGBA components are XYZW components of associated vector.
        case uchar4(simd_uchar4, srgb: Bool = false)


        // MARK: Operations

        @inlinable
        public var texel: simd_uchar4 {
            switch self {
            case let .grayScale(white, alpha, srgb: _):
                return simd_uchar4(.init(repeating: colorComponent(from: white)), colorComponent(from: alpha))
            case let .hex(hex, srgb: _):
                return simd_uchar4(numericCast((hex >> 16) & 0xFF),
                                   numericCast((hex >>  8) & 0xFF),
                                   numericCast((hex      ) & 0xFF),
                                   numericCast((hex >> 24) & 0xFF))
            case let .rgba(r, g, b, a, srgb: _):
                return simd_uchar4(colorComponent(from: r), colorComponent(from: g), colorComponent(from: b), colorComponent(from: a))
            case let .uchar4(pattern, srgb: _):
                return pattern
            }
        }

        @inlinable
        public var isSRGB: Bool {
            switch self {
            case let .grayScale(_, _, srgb: isSRGB):
                return isSRGB
            case let .hex(_, srgb: isSRGB):
                return isSRGB
            case let .rgba(r: _, g: _, b: _, a: _, srgb: isSRGB):
                return isSRGB
            case let .uchar4(_, srgb: isSRGB):
                return isSRGB
            }
        }

        @inlinable public var pixelFormat: MTLPixelFormat { isSRGB ? .rgba8Unorm_srgb : .rgba8Unorm }

    }

}
