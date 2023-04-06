//===----------------------------------------------------------------------===//
//
//  Copyright (c) 2022 Svyatoslav Popov (info@keyvar.com).
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
        let descriptor = MTLTextureDescriptor.textureCubeDescriptor(pixelFormat: pattern.pixelFormat, size: size, mipmapped: false)
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
        case grayScale(white: Float, alpha: Float = 1, srgb: Bool = false)

        /// A value in standard hex format `0xAARRGGBB`.
        case hex(value: UInt32, srgb: Bool = false)

        /// Four normalized color components of *Float* type.
        case rgba(r: Float, g: Float, b: Float, a: Float = 1, srgb: Bool = false)

        /// A vector where RGBA components are XYZW components of associated vector.
        case uchar4(value: simd_uchar4, srgb: Bool = false)


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
            case let .grayScale(white: _, alpha: _, srgb: isSRGB):
                return isSRGB
            case let .hex(value: _, srgb: isSRGB):
                return isSRGB
            case let .rgba(r: _, g: _, b: _, a: _, srgb: isSRGB):
                return isSRGB
            case let .uchar4(value: _, srgb: isSRGB):
                return isSRGB
            }
        }

        @inlinable public var pixelFormat: MTLPixelFormat { isSRGB ? .rgba8Unorm_srgb : .rgba8Unorm }

    }



    // MARK: .CubeSlice

    /// Collection of auxiliaries to work with cube texture slices.
    ///
    /// - Note: Sequence of cases matches hardware layout of slices.
    public enum CubeSlice : Int, CaseIterable, Hashable, CustomStringConvertible {

        case xPlus = 0, xMinus = 1, yPlus = 2, yMinus = 3, zPlus = 4, zMinus = 5


        // MARK: : CustomStringConvertible

        @inlinable
        public var description: String {
            switch self {
            case .xPlus:
                return "X+"
            case .xMinus:
                return "X–"
            case .yPlus:
                return "Y+"
            case .yMinus:
                return "Y–"
            case .zPlus:
                return "Z+"
            case .zMinus:
                return "Z–"
            }
        }


        // MARK: Matrices

        /// - Returns: Transformation matrix to convert world coordinates and then render with camera having identity transformation. So single camera can be used to render any slice.
        @inlinable
        public func worldMatrix<Math : KvMathScope>(_ math: Math.Type) -> Math.Matrix4x4 {
            typealias Column = Math.Matrix4x4.Column

            switch self {
            case .xPlus:
                return Math.Matrix4x4(Column.unitNZ, Column.unitNY,  Column.unitX, Column.unitW)
            case .xMinus:
                return Math.Matrix4x4( Column.unitZ, Column.unitNY, Column.unitNX, Column.unitW)
            case .yPlus:
                return Math.Matrix4x4( Column.unitX,  Column.unitZ,  Column.unitY, Column.unitW)
            case .yMinus:
                return Math.Matrix4x4( Column.unitX, Column.unitNZ, Column.unitNY, Column.unitW)
            case .zPlus:
                return Math.Matrix4x4( Column.unitX, Column.unitNY,  Column.unitZ, Column.unitW)
            case .zMinus:
                return Math.Matrix4x4(Column.unitNX, Column.unitNY, Column.unitNZ, Column.unitW)
            }
        }


        /// - Returns: Perspective projection matrix to render into a cube texture slice.
        ///
        /// - Note: It's faster than implementations for arbitrary perspective projection matrices.
        @inlinable
        static public func perspectiveProjectionMatrix<Math>(_ math: Math.Type, zNear: Math.Scalar, zFar: Math.Scalar) -> Math.Matrix4x4
        where Math : KvMathScope {
            typealias Column = Math.Matrix4x4.Column

            let zLengthNegative⁻¹ = -1 / (zFar - zNear)

            return Math.Matrix4x4(Column.unitX,
                                  Column.unitY,
                                  Column.init(0, 0,   (zFar + zNear) * zLengthNegative⁻¹, -1),
                                  Column.init(0, 0, 2 * zFar * zNear * zLengthNegative⁻¹,  0))
        }

    }

}



// MARK: - Computations

extension KvMetalKit {

    // MARK: .ThreadGrid

    /// Configuration of a thread grid. It calculates parameters of the grid to dispatch threads and provides convenient shorthand methods to execute calculations.
    ///
    /// Typical usage:
    /// ```
    /// KvMetalKit.ThreadGrid(pipelineState, width: 1920, height: 1080)
    ///     .setAndDispatch(computeEncoder)
    /// ```
    public struct ThreadGrid {

        /// Pipeline state the grid is computed for.
        public let pipelineState: MTLComputePipelineState

        /// Size of the grid.
        ///
        /// See ``threadgroupSize``, ``threadgroupCount``.
        public let size: MTLSize
        /// The threadgroup size.
        ///
        /// See ``size``, ``threadgroupCount``.
        public let threadgroupSize: MTLSize


        /// Size of the griid in threadgroups.
        /// It's used to execute calculations using uniform threadgroups.
        /// See [Metal feature set tables](https://developer.apple.com/metal/Metal-Feature-Set-Tables.pdf).
        ///
        /// See ``size``, ``threadgroupSize``.
        @inlinable
        public var threadgroupCount: MTLSize {
            MTLSizeMake(Self.threadgroupCountComponent(gridSize: size.width , threadgroupSize: threadgroupSize.width ),
                        Self.threadgroupCountComponent(gridSize: size.height, threadgroupSize: threadgroupSize.height),
                        Self.threadgroupCountComponent(gridSize: size.depth , threadgroupSize: threadgroupSize.depth ))
        }


        /// Memberwise initializer.
        @inlinable
        public init(_ pipelineState: MTLComputePipelineState, size: MTLSize, threadgroupSize: MTLSize) {
            self.pipelineState = pipelineState
            self.size = size
            self.threadgroupSize = threadgroupSize
        }


        /// Calculates 1D-grid for given *pipelineState*.
        ///
        /// See ``init(_:texture1D:)``, ``threadgroupSize(_:width)``.
        @inlinable
        public init(_ pipelineState: MTLComputePipelineState, width: Int) {
            self.init(pipelineState,
                      size: MTLSizeMake(width, 1, 1),
                      threadgroupSize: Self.threadgroupSize(pipelineState, width: width))
        }


        /// Calculates 1D-grid for given *pipelineState* of the same size as given *texture1D*.
        ///
        /// See ``init(_:width:)``, ``threadgroupSize(_:width)``.
        @inlinable
        public init(_ pipelineState: MTLComputePipelineState, texture1D: MTLTexture) {
            self.init(pipelineState, width: texture1D.width)
        }


        /// Calculates 2D-grid for given *pipelineState*.
        ///
        /// See ``init(_:texture2D:)``, ``threadgroupSize(_:width:height:)``.
        @inlinable
        public init(_ pipelineState: MTLComputePipelineState, width: Int, height: Int) {
            self.init(pipelineState,
                      size: MTLSizeMake(width, height, 1),
                      threadgroupSize: Self.threadgroupSize(pipelineState, width: width, height: height))
        }


        /// Calculates 2D-grid for given *pipelineState* of the same size as given *texture2D*.
        ///
        /// See ``init(_:width:height:)``, ``threadgroupSize(_:width:height:)``.
        @inlinable
        public init(_ pipelineState: MTLComputePipelineState, texture2D: MTLTexture) {
            self.init(pipelineState, width: texture2D.width, height: texture2D.height)
        }


        // MARK: Opeprations

        /// Dispatches the threads using non-uniform theadgroups.
        ///
        /// - Warning: The device must support non-uniform threadgroups. See [Metal feature set tables](https://developer.apple.com/metal/Metal-Feature-Set-Tables.pdf).
        ///
        /// See: ``setAndDispatch(_:)``, ``dispatchUniform(_:)``.
        @inlinable
        public func dispatch(_ computeEncoder: MTLComputeCommandEncoder) {
            computeEncoder.dispatchThreads(size, threadsPerThreadgroup: threadgroupSize)
        }


        /// Dispatches the threads using uniform theadgroups.
        ///
        /// - Note: This method is supported by all devices but requires bound check for the thread position in the kernel.
        ///         If all target devices support non-uniform threadgroups then consider ``dispatch(_:)`` method.
        ///         See [Metal feature set tables](https://developer.apple.com/metal/Metal-Feature-Set-Tables.pdf).
        ///
        /// See: ``setAndDispatchUniform(_:)``, ``dispatch(_:)``.
        @inlinable
        public func dispatchUniform(_ computeEncoder: MTLComputeCommandEncoder) {
            computeEncoder.dispatchThreadgroups(threadgroupCount, threadsPerThreadgroup: threadgroupSize)
        }


        /// Sets the receiver's *pipelineState* to given *computeEncoder* and dispatches the threads using non-uniform theadgroups.
        ///
        /// - Warning: The device must support non-uniform threadgroups. See [Metal feature set tables](https://developer.apple.com/metal/Metal-Feature-Set-Tables.pdf).
        ///
        /// See: ``dispatch(_:)``, ``setAndDispatchUniform(_:)``.
        @inlinable
        public func setAndDispatch(_ computeEncoder: MTLComputeCommandEncoder) {
            computeEncoder.setComputePipelineState(pipelineState)

            dispatch(computeEncoder)
        }


        /// Sets the receiver's *pipelineState* to given *computeEncoder* and dispatches the threads using uniform theadgroups.
        ///
        /// - Note: This method is supported by all devices but requires bound check for the thread position in the kernel.
        ///         If all target devices support non-uniform threadgroups then consider ``setAndDispatch(_:)`` method.
        ///         See [Metal feature set tables](https://developer.apple.com/metal/Metal-Feature-Set-Tables.pdf).
        ///
        /// See: ``setAndDispatch(_:)``, ``dispatchUniform(_:)``.
        @inlinable
        public func setAndDispatchUniform(_ computeEncoder: MTLComputeCommandEncoder) {
            computeEncoder.setComputePipelineState(pipelineState)

            dispatchUniform(computeEncoder)
        }


        /// - Returns: The threadgroup size of 1D-grid for given *pipelineState*.
        ///
        /// See ``threadgroupSize(_:width:height:)``.
        @inlinable
        public static func threadgroupSize(_ pipelineState: MTLComputePipelineState, width: Int) -> MTLSize {
            return MTLSizeMake(min(width, pipelineState.maxTotalThreadsPerThreadgroup), 1, 1)
        }


        /// - Returns: The threadgroup size of 1D-grid for given *pipelineState*.
        ///
        /// See ``threadgroupSize(_:width:)``.
        @inlinable
        public static func threadgroupSize(_ pipelineState: MTLComputePipelineState, width: Int, height: Int) -> MTLSize {
            let maxThreads = pipelineState.maxTotalThreadsPerThreadgroup

            guard width * height > maxThreads else { return MTLSizeMake(width, height, 1) }

            let executionWidth = pipelineState.threadExecutionWidth

            // Simple initial size.
            var size = MTLSizeMake(executionWidth, maxThreads / executionWidth, 1)

            // Doubling threadgroup width while possible
            do {
                var nextSizeWidth = size.width << 1

                while size.height > height, nextSizeWidth <= width {
                    size.height >>= 1
                    size.width = nextSizeWidth

                    nextSizeWidth <<= 1
                }
            }
            // Doubling threadgroup height while possible
            do {
                var nextSizeHeight = size.height << 1

                while size.width > width, nextSizeHeight <= height {
                    size.width >>= 1
                    size.height = nextSizeHeight

                    nextSizeHeight <<= 1
                }
            }

            return size
        }


        @usableFromInline
        static func threadgroupCountComponent(gridSize: Int, threadgroupSize: Int) -> Int {
            max(1, threadgroupSize > 1 ? (gridSize / threadgroupSize) : gridSize)
        }

    }

}
