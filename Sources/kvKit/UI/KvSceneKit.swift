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
//  KvSceneKit.swift
//  kvKit
//
//  Created by Svyatoslav Popov on 26.10.2022.
//

#if canImport(SceneKit)

import SceneKit



/// Collection of auxiliaries for SceneKit.
public struct KvSceneKit { private init() { } }



// MARK: - Transactions

extension KvSceneKit {

#if DEBUG
#if !DEBUG
#warning("This code must never be enabled in a release build")
#endif // !DEBUG

    @inlinable
    public static func transaction(duration: CFTimeInterval? = nil, timingFunction: CAMediaTimingFunction? = nil,
                                   _ file: StaticString = #fileID, _ line: UInt = #line,
                                   body: () throws -> Void) rethrows
    {
        try __transaction(duration: duration, timingFunction: timingFunction) {
            try __measuringTransactionBodyDuration(file, line, body)
        }
    }

#else // !DEBUG
    @inlinable
    public static func transaction(duration: CFTimeInterval? = nil, timingFunction: CAMediaTimingFunction? = nil, body: () throws -> Void) rethrows {
        try __transaction(duration: duration, timingFunction: timingFunction, body: body)
    }
#endif // !DEBUG



    @inlinable
    public static func __transaction(duration: CFTimeInterval? = nil, timingFunction: CAMediaTimingFunction? = nil, body: () throws -> Void) rethrows {
        SCNTransaction.begin()
        defer { SCNTransaction.commit() }

        duration.map { SCNTransaction.animationDuration = $0 }
        timingFunction.map { SCNTransaction.animationTimingFunction = $0 }

        try body()
    }



#if DEBUG
    @usableFromInline
    internal static func __measuringTransactionBodyDuration<T>(_ file: StaticString = #fileID, _ line: UInt = #line, _ body: () throws -> T) rethrows -> T {
        let startDate = Date()
        defer {
            let lockTimeInterval = -startDate.timeIntervalSinceNow
            if lockTimeInterval > 0.02 {
                print("⚠️\(file):\(line) SCNTransaction has been locked for \(lockTimeInterval * 1e3) ms")
            }
        }

        return try body()
    }
#endif // DEBUG

}



// MARK: Transaction Lock

extension KvSceneKit {

    public static let transactionLock: NSLocking = TransactionLock.shared



#if DEBUG
#if !DEBUG
#warning("This code must never be enabled in a release build")
#endif // !DEBUG

    @inlinable
    public static func locking<T>(_ file: StaticString = #fileID, _ line: UInt = #line, body: () throws -> T) rethrows -> T {
        try KvThreadKit.locking(KvSceneKit.transactionLock) {
            try __measuringTransactionBodyDuration(file, line, body)
        }
    }

#else // !DEBUG
    @inlinable
    public static func locking<T>(body: () throws -> T) rethrows -> T {
        try KvThreadKit.locking(KvSceneKit.transactionLock, body: body)
    }
#endif // !DEBUG



    // MARK: .TransactionLock

    class TransactionLock : NSLocking {

        static let shared: TransactionLock = .init()


        private init() { }


        // MARK: : NSLocking

        func lock() { SCNTransaction.lock() }


        func unlock() { SCNTransaction.unlock() }

    }

}



// MARK: - Screenshots

extension KvSceneKit {

    public static func takeScreenshot(of scene: SCNScene, atTime time: CFTimeInterval = 0,
                                      with size: CGSize, antialiasingMode: SCNAntialiasingMode = .multisampling4X,
                                      on device: MTLDevice? = nil)
    throws -> KvUI.Image
    {
        let device = try device ?? {
            guard let device = $0 else { throw KvError("Unable to get default system Metal device") }
            return device
        }(MTLCreateSystemDefaultDevice())

        let renderer = SCNRenderer(device: device)

        guard renderer.prepare(scene, shouldAbortBlock: nil) else { throw KvError("Failed to prepare \(scene) scene for rendering") }

        renderer.scene = scene

        return renderer.snapshot(atTime: time, with: size, antialiasingMode: antialiasingMode)
    }

}



// MARK: - Textures

extension KvSceneKit {

    public static func colorComponent<C>(from value: Float) -> C
    where C : BinaryInteger
    {
        C(round(255 * simd_clamp(value, 0, 1)))
    }



    public static func unicolorTexture(white: Float, alpha: Float = 1, size: Int = 32, isCube: Bool = false) -> MDLTexture {
        unicolorTexture(texel: { [ $0, $0, $0, $1 ] }(colorComponent(from: white), colorComponent(from: alpha)),
                        channelCount: 4, channelEncoding: .uint8, size: size, isCube: isCube)
    }



    public static func unicolorTexture(r: Float, g: Float, b: Float, alpha: Float = 1, size: Int = 32, isCube: Bool = false) -> MDLTexture {
        unicolorTexture(texel: [ colorComponent(from: r), colorComponent(from: g), colorComponent(from: b), colorComponent(from: alpha) ],
                        channelCount: 4, channelEncoding: .uint8, size: size, isCube: isCube)
    }



    public static func unicolorTexture<T>(texel: T, channelCount: Int, channelEncoding: MDLTextureChannelEncoding, size: Int = 32, isCube: Bool = false) -> MDLTexture
    where T : DataProtocol
    {
        let dimensions = simd_int2(numericCast(size), numericCast(isCube ? 6 * size : size))

        return .init(data: .init(repeatElement(texel, count: numericCast(dimensions.x * dimensions.y)).joined()),
                     topLeftOrigin: true,
                     name: "Unicolor",
                     dimensions: dimensions,
                     rowStride: numericCast(dimensions.x) * texel.count,
                     channelCount: channelCount,
                     channelEncoding: channelEncoding,
                     isCube: isCube)
    }

}



// MARK: - Node Hierarchy

extension KvSceneKit {

    /// Invokes *body* for given *node* and it's decendand nodes depending on result of *body* invocations.
    public static func traverseHierarchy(from node: SCNNode, body: (SCNNode) throws -> NodeHierarchyBodyResult) rethrows {

        /// - Returns: A boolean value indicating whether the enumeration should continue.
        func RunIteration(for node: SCNNode, body: (SCNNode) throws -> NodeHierarchyBodyResult) rethrows -> Bool {
            switch try body(node) {
            case .continue:
                return try node.childNodes.allSatisfy { child in
                    try RunIteration(for: child, body: body)
                }

            case .ignoreChildren:
                return true

            case .stop:
                return false
            }
        }


        _ = try RunIteration(for: node, body: body)
    }



    // MARK: .NodeHierarchyBodyResult

    public enum NodeHierarchyBodyResult { case `continue`, ignoreChildren, stop }

}



// MARK: - Geometry

extension KvSceneKit {

    public static func withIterator<R>(for element: SCNGeometryElement, body: (AnyIterator<Int>) -> R) -> R {

        func MakeIterator<T : BinaryInteger>(_ buffer: UnsafeRawBufferPointer, elementType: T.Type) -> AnyIterator<Int> {
            var iterator = buffer.bindMemory(to: T.self).makeIterator()

            return.init({ iterator.next().map(numericCast) })
        }


        let indexCount: Int

        switch element.primitiveType {
        case .line:
            indexCount = 2 * element.primitiveCount
        case .point:
            indexCount = element.primitiveCount
        case .polygon:
            return KvDebug.pause(code: body(.init([ ].makeIterator())), "Unable to iterate geometry element having \(element.primitiveType) primitive type")
        case .triangleStrip:
            indexCount = 2 + element.primitiveCount
        case .triangles:
            indexCount = 3 * element.primitiveCount
        @unknown default:
            return KvDebug.pause(code: body(.init([ ].makeIterator())), "Unable to iterate geometry element having unexpected \(element.primitiveType) primitive type")
        }

        let byteSize = element.bytesPerIndex * indexCount
        let data = element.data[..<byteSize]

        switch element.bytesPerIndex {
        case 1:
            var iterator = data.makeIterator()

            return body(.init({ iterator.next().map(numericCast) }))

        case 2:
            return data.withUnsafeBytes { body(MakeIterator($0, elementType: Int16.self)) }

        case 4:
            return data.withUnsafeBytes { body(MakeIterator($0, elementType: Int32.self)) }

        default:
            return KvDebug.pause(code: body(.init([ ].makeIterator())), "Unable to iterate geometry element where index size is \(element.bytesPerIndex)")
        }
    }



    public static func withPositions<R>(in sources: [SCNGeometrySource], body: (UnsafeBufferPointer<Float3>) -> R) -> R {
        assert(MemoryLayout<Float3>.stride == 3 * MemoryLayout<Float>.size)


        guard let positionSource = sources.first(where: { $0.semantic == .vertex }) else {
            KvDebug.pause("Unable to access positions in geometry having to positions")
            return ([ ] as [Float3]).withUnsafeBufferPointer(body)
        }

        guard positionSource.usesFloatComponents,
              positionSource.componentsPerVector == 3,
              positionSource.bytesPerComponent == MemoryLayout<Float>.stride
        else {
            KvDebug.pause("Unable to enumerate triangles in geometry where type of positions isn't float triplet")
            return ([ ] as [Float3]).withUnsafeBufferPointer(body)
        }

        return positionSource.data
            .advanced(by: positionSource.dataOffset)[..<(positionSource.dataStride * positionSource.vectorCount)]
            .withUnsafeBytes { body($0.bindMemory(to: Float3.self)) }
    }



    @inlinable
    public static func withPositions<R>(in geometry: SCNGeometry, body: (UnsafeBufferPointer<Float3>) -> R) -> R {
        withPositions(in: geometry.sources, body: body)
    }



    public static func forEachTriangle(sources: [SCNGeometrySource],
                                       elements: [SCNGeometryElement]?,
                                       body: (simd_float3, simd_float3, simd_float3) -> Void)
    {
        withPositions(in: sources) { positions in
            guard !positions.isEmpty else { return }

            switch elements {
            case .some(let elements):
                elements.forEach { element in
                    switch element.primitiveType {
                    case .triangles:
                        withIterator(for: element) { iterator in
                            while let i₁ = iterator.next(), let i₂ = iterator.next(), let i₃ = iterator.next() {
                                body(positions[i₁].simd, positions[i₂].simd, positions[i₃].simd)
                            }
                        }

                    case .triangleStrip:
                        withIterator(for: element) { iterator in
                            guard let i₁ = iterator.next(), let i₂ = iterator.next() else { return }

                            var p₁ = positions[i₁].simd, p₂ = positions[i₂].simd

                            while let i₃ = iterator.next() {
                                let p₃ = positions[i₃].simd

                                body(p₁, p₂, p₃)

                                p₁ = p₂
                                p₂ = p₃
                            }
                        }

                    default:
                        KvDebug.pause("Unable to enumerate triangles for geometry element having \(element.primitiveType) primitive type")
                    }
                }

            case .none:
                var iterator = positions.makeIterator()

                while let p₁ = iterator.next(), let p₂ = iterator.next(), let p₃ = iterator.next() {
                    body(p₁.simd, p₂.simd, p₃.simd)
                }
            }
        }
    }



    @inlinable
    public static func forEachTriangle(in geometry: SCNGeometry, body: (simd_float3, simd_float3, simd_float3) -> Void) {
        forEachTriangle(sources: geometry.sources, elements: geometry.elements, body: body)
    }



    // MARK: .Float3

    /// Container for Float triplet having the stride equal to size.
    public struct Float3 : Hashable {

        public var x, y, z: Float


        public init(x: Float, y: Float, z: Float) {
            self.x = x
            self.y = y
            self.z = z
        }


        // MARK: Operations

        public var simd: simd_float3 { .init(x, y, z) }

    }

}



// MARK: - Geometry Builder

// MARK: KvSCNGeometrySourceVertex

/// Base type for source vertex descriptions.
///
/// See ``KvSCNGeometrySourcePosition3``, ``KvSCNGeometrySourceNormal3``, ``KvSCNGeometrySourceTx0uv``. Combine theese protocols to provide data for the geometry sources.
public protocol KvSCNGeometrySourceVertex { }



// MARK: KvSCNGeometrySourcePosition3

/// Prodides a position in 3D coordinate space.
public protocol KvSCNGeometrySourcePosition3 : KvSCNGeometrySourceVertex {

    var position: SCNVector3 { get }

}


extension KvSCNGeometrySourcePosition3 {

    fileprivate static func builder<Vertex : KvSCNGeometrySourceVertex>(for vertex: Vertex.Type) -> (put: (Vertex) -> Void, build: () -> SCNGeometrySource) {
        var positions: [SCNVector3] = .init()

        return (
            put: { positions.append(($0 as! KvSCNGeometrySourcePosition3).position) },
            build: { .init(vertices: positions) }
        )
    }

}



// MARK: KvSCNGeometrySourceNormal3

/// Prodides a normal in 3D coordinate space.
public protocol KvSCNGeometrySourceNormal3 : KvSCNGeometrySourceVertex {

    var normal: SCNVector3 { get }

}


extension KvSCNGeometrySourceNormal3 {

    fileprivate static func builder<Vertex : KvSCNGeometrySourceVertex>(for vertex: Vertex.Type) -> (put: (Vertex) -> Void, build: () -> SCNGeometrySource) {
        var normals: [SCNVector3] = .init()

        return (
            put: { normals.append(($0 as! KvSCNGeometrySourceNormal3).normal) },
            build: { .init(normals: normals) }
        )
    }

}



// MARK: KvSCNGeometrySourceTx0uv

/// Provides a 2D texture coordinate in 0 slot.
public protocol KvSCNGeometrySourceTx0uv : KvSCNGeometrySourceVertex {

    var tx0: CGPoint { get }

}


extension KvSCNGeometrySourceTx0uv {

    fileprivate static func builder<Vertex : KvSCNGeometrySourceVertex>(for vertex: Vertex.Type) -> (put: (Vertex) -> Void, build: () -> SCNGeometrySource) {
        var tx0: [CGPoint] = .init()

        return (
            put: { tx0.append(($0 as! KvSCNGeometrySourceTx0uv).tx0) },
            build: { .init(textureCoordinates: tx0) }
        )
    }

}



// MARK: .GeometryBuilder

extension KvSceneKit {

    /// Collecting primitives and materials then creates instance of *SCNGeometry*.
    ///
    /// Combine ``KvSCNGeometrySourcePosition3``, ``KvSCNGeometrySourceNormal3``, ``KvSCNGeometrySourceTx0uv`` to provide complete vertex description.
    public class GeometryBuilder<Vertex : KvSCNGeometrySourceVertex, Index : FixedWidthInteger> {

        public private(set) var vertexCount: Int = 0



        public init() {
            var putVertexBlocks: [(Vertex) -> Void] = .init()
            var buildSourceBlocks: [() -> SCNGeometrySource] = .init()

            if let providerType = Vertex.self as? KvSCNGeometrySourcePosition3.Type {
                let builder = providerType.builder(for: Vertex.self)

                putVertexBlocks.append(builder.put)
                buildSourceBlocks.append(builder.build)
            }
            if let providerType = Vertex.self as? KvSCNGeometrySourceNormal3.Type {
                let builder = providerType.builder(for: Vertex.self)

                putVertexBlocks.append(builder.put)
                buildSourceBlocks.append(builder.build)
            }
            if let providerType = Vertex.self as? KvSCNGeometrySourceTx0uv.Type {
                let builder = providerType.builder(for: Vertex.self)

                putVertexBlocks.append(builder.put)
                buildSourceBlocks.append(builder.build)
            }

            self.putVertexBlocks = putVertexBlocks
            self.buildSourceBlocks = buildSourceBlocks
        }



        private let putVertexBlocks: [(Vertex) -> Void]
        private let buildSourceBlocks: [() -> SCNGeometrySource]

        private var indices: [ElementID : [Index]] = .init()



        // MARK: Operations

        public func build() -> SCNGeometry {
            let sources = buildSourceBlocks.map { block in
                block()
            }

            let (materials, elements): ([SCNMaterial], [SCNGeometryElement]) = indices.reduce(into: ([], [])) { accumulator, pair in
                accumulator.0.append(pair.key.material ?? SCNMaterial())
                accumulator.1.append(.init(indices: pair.value, primitiveType: pair.key.primitiveType))
            }

            let geometry = SCNGeometry(sources: sources, elements: elements)
            geometry.materials = materials

            return geometry
        }



        public func putVertex(_ vertex: Vertex) {
            putVertexBlocks.forEach { block in
                block(vertex)
            }

            vertexCount += 1
        }


        public func putTriange(_ i0: Index, _ i1: Index, _ i2: Index, material: SCNMaterial? = nil) {
            _ = { indices in
                indices.append(i0)
                indices.append(i1)
                indices.append(i2)
            }(&indices[.init(material: material, primitiveType: .triangles), default: .init()])
        }


        public func putLine(_ i0: Index, _ i1: Index, material: SCNMaterial? = nil) {
            _ = { indices in
                indices.append(i0)
                indices.append(i1)
            }(&indices[.init(material: material, primitiveType: .line), default: .init()])
        }



        // MARK: .ElementID

        private struct ElementID : Hashable {

            let material: SCNMaterial?
            let primitiveType: SCNGeometryPrimitiveType

        }

    }

}



#endif // canImport(SceneKit)
