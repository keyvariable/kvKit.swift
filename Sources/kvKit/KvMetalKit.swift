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


    /// - Returns: A cube texture filled with given RGBA pattern vector.
    @inlinable
    public static func unicolorCubeTexture(
        rgba: simd_uchar4 = [ 0, 0, 0, 255 ],
        size: Int = 16,
        pixelFormat: MTLPixelFormat = .rgba8Unorm,
        on device: MTLDevice? = nil
    ) throws -> MTLTexture {
        let descriptor = MTLTextureDescriptor.textureCubeDescriptor(pixelFormat: pixelFormat, size: size, mipmapped: false)
        descriptor.usage = .shaderRead

        return try unicolorCubeTexture(repeating: rgba, with: descriptor, on: device)
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

}
