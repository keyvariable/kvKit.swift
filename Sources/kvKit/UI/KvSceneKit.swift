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
//  KvSceneKit.swift
//  kvKit
//
//  Created by Svyatoslav Popov on 25.02.2021.
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
    public static func locking<T>(file: StaticString = #fileID, line: UInt = #line, _ body: () throws -> T) rethrows -> T {
        try KvThreadKit.locking(KvSceneKit.transactionLock) {
            try __measuringTransactionBodyDuration(file, line, body)
        }
    }

#else // !DEBUG
    @inlinable
    public static func locking<T>(_ body: () throws -> T) rethrows -> T {
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

    /// - Returns: Given color component as an unsigned byte integer.
    @inlinable
    public static func colorComponent<T : BinaryFloatingPoint>(from value: T) -> UInt8 {
        UInt8(round((255.0 as T) * clamp(value, 0.0 as T, 1.0 as T)))
    }


    /// - Parameter white: A gray scale value.
    @inlinable
    public static func unicolorTexture<T>(white: T, alpha: T = 1.0, size: Int = 32, isCube: Bool = false) -> MDLTexture
    where T : BinaryFloatingPoint {
        unicolorTexture(texel: { [ $0, $0, $0, $1 ] }(colorComponent(from: white), colorComponent(from: alpha)),
                        channelCount: 4, channelEncoding: .uint8, size: size, isCube: isCube)
    }


    @inlinable
    public static func unicolorTexture<T>(r: T, g: T, b: T, alpha: T = 1.0, size: Int = 32, isCube: Bool = false) -> MDLTexture
    where T : BinaryFloatingPoint {
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

    /// - Returns: Root note of the hierarchy *node* is contained in.
    @inlinable
    public static func rootNode(containing node: SCNNode) -> SCNNode {
        var node = node

        while let parent = node.parent {
            node = parent
        }

        return node
    }


    /// - Returns: A boolean value indicating whether *node* is a descendant of *ancestor* node. If *node* is the same as *ancestor* then `false` is returned.
    @inlinable
    public static func isAncestor(_ ancestor: SCNNode, of node: SCNNode) -> Bool {
        var node = node

        while let parent = node.parent {
            if parent === ancestor { return true }
            node = parent
        }

        return false
    }


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

    /// - Returns: A boolean value indicating whether given goemtry source contains vectors of *Float* components.
    ///
    /// See ``isFloatVectorSource(_:numberOfScalars:)``.
    @inlinable
    public static func isFloatVectorSource(_ source: SCNGeometrySource) -> Bool {
        source.usesFloatComponents
        && source.bytesPerComponent == MemoryLayout<Float>.stride
    }


    /// - Returns: A boolean value indicating whether given goemtry source contains vectors of *numberOfScalars* *Float* components.
    ///
    /// See ``isFloatVectorSource(_:)``.
    @inlinable
    public static func isFloatVectorSource(_ source: SCNGeometrySource, numberOfScalars: Int) -> Bool {
        isFloatVectorSource(source)
        && source.componentsPerVector == numberOfScalars
    }



    /// Invokes *body* with content of given *source* represented as a collection of vectors of given type.
    @inlinable
    public static func withVectors<Vector, R>(
        of vectorType: Vector.Type,
        in source: SCNGeometrySource,
        body: (KvCollectionKit.Sparce<Vector>) throws -> R
    ) rethrows -> R {
        try source.data.withUnsafeBytes { buffer in
            try body(KvCollectionKit.Sparce(origin: buffer.baseAddress!.advanced(by: source.dataOffset),
                                            stride: source.dataStride,
                                            count: source.vectorCount))
        }
    }


    /// Invokes *body* with content of given *source* represented as a collection of vectors of 2 Float components.
    ///
    /// See ``isFloatVectorSource(_:numberOfScalars:)``, ``withVectors3F(in:body:)``, ``withVectors4F(in:body:)``, ``withVectors(of:in:body:)``.
    @inlinable
    public static func withVectors2F<R>(
        in source: SCNGeometrySource,
        body: (KvCollectionKit.Sparce<(Float, Float)>) throws -> R
    ) rethrows -> R {
        try withVectors(of: (Float, Float).self, in: source, body: body)
    }


    /// Invokes *body* with content of given *source* represented as a collection of vectors of 3 Float components.
    ///
    /// See ``isFloatVectorSource(_:numberOfScalars:)``, ``withVectors2F(in:body:)``, ``withVectors4F(in:body:)``, ``withVectors(of:in:body:)``.
    @inlinable
    public static func withVectors3F<R>(
        in source: SCNGeometrySource,
        body: (KvCollectionKit.Sparce<(Float, Float, Float)>) throws -> R
    ) rethrows -> R {
        try withVectors(of: (Float, Float, Float).self, in: source, body: body)
    }


    /// Invokes *body* with content of given *source* represented as a collection of vectors of 4 Float components.
    ///
    /// See ``isFloatVectorSource(_:numberOfScalars:)``, ``withVectors2F(in:body:)``, ``withVectors3F(in:body:)``, ``withVectors(of:in:body:)``.
    @inlinable
    public static func withVectors4F<R>(
        in source: SCNGeometrySource,
        body: (KvCollectionKit.Sparce<(Float, Float, Float, Float)>) throws -> R
    ) rethrows -> R {
        try withVectors(of: (Float, Float, Float, Float).self, in: source, body: body)
    }



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


    /// Invokes body with triangle indices defined by given element. Method does nothing when given element doen't produce triangles.
    @inlinable
    public static func forEachTriangle(in element: SCNGeometryElement, body: (Int, Int, Int) -> Void) {
        switch element.primitiveType {
        case .triangles:
            withIterator(for: element) { iterator in
                while let i₁ = iterator.next(), let i₂ = iterator.next(), let i₃ = iterator.next() {
                    body(i₁, i₂, i₃)
                }
            }

        case .triangleStrip:
            withIterator(for: element) { iterator in
                guard var i₁ = iterator.next(),
                      var i₂ = iterator.next()
                else { return }

                while let i₃ = iterator.next() {
                    body(i₁, i₂, i₃)

                    i₁ = i₂
                    i₂ = i₃
                }
            }

        case .line, .point, .polygon:
            break
        @unknown default:
            break
        }
    }


    /// Invokes body with triangle indices from given elements.
    ///
    /// - Note: Method does nothing when given elements produce no triangles.
    ///
    /// See ``forEachTriangle(sources:body:)``, ``forEachTriangle(in:sources:body:)``, ``forEachTriangle(geometry:body:)``.
    @inlinable
    public static func forEachTriangle<Elements>(in elements: Elements, body: (Int, Int, Int) -> Void)
    where Elements : Sequence, Elements.Element == SCNGeometryElement {
        elements.forEach { element in
            forEachTriangle(in: element, body: body)
        }
    }


    /// Invokes body with triangle indices as given collection of sources is rendered as unindexed.
    ///
    /// - Note: Method does nothing when given sources produce no triangles.
    ///
    /// See ``forEachTriangle(in:body:)-4ga00``, ``forEachTriangle(in:sources:body:)``, ``forEachTriangle(geometry:body:)``.
    @inlinable
    public static func forEachTriangle<Sources>(sources: Sources, body: (Int, Int, Int) -> Void)
    where Sources : Sequence, Sources.Element == SCNGeometrySource {
        let vertexCount = sources
            .lazy.map { $0.vectorCount }
            .min()!

        var iterator = (0 ..< vertexCount).makeIterator()

        while let i₁ = iterator.next(), let i₂ = iterator.next(), let i₃ = iterator.next() {
            body(i₁, i₂, i₃)
        }
    }


    /// Invokes body with triangle indices from given combination of geometry sources and elements.
    ///
    /// - Note: Method does nothing when given sources and elements produce no triangles.
    /// - Note: If *elements* is *nil* then *sources* are interpretted as unindexed vertices.
    ///
    /// See ``forEachTriangle(in:body:)-4ga00``, ``forEachTriangle(sources:body:)``, ``forEachTriangle(geometry:body:)``.
    @inlinable
    public static func forEachTriangle<Sources>(in elements: [SCNGeometryElement]?, sources: Sources, body: (Int, Int, Int) -> Void)
    where Sources : Sequence, Sources.Element == SCNGeometrySource {
        if let elements = elements, !elements.isEmpty {
            forEachTriangle(in: elements, body: body)
        } else {
            forEachTriangle(sources: sources, body: body)
        }
    }


    // TODO: Rename to forEachTriangle(in:body:) in 5.0.0
    /// Invokes body with triangle indices from given geometry. Method does nothing when given geometry has no triangles.
    ///
    /// See ``forEachTriangle(in:body:)-4ga00``, ``forEachTriangle(sources:body:)``, ``forEachTriangle(in:sources:body:)``.
    @inlinable
    public static func forEachTriangle(geometry: SCNGeometry, body: (Int, Int, Int) -> Void) {
        forEachTriangle(in: geometry.elements, sources: geometry.sources, body: body)
    }



    // TODO: Delete in 5.0.0
    @available(*, deprecated)
    public static func withPositions<R>(in sources: [SCNGeometrySource], body: (UnsafeBufferPointer<Float3>) -> R) -> R {
        assert(MemoryLayout<Float3>.stride == 3 * MemoryLayout<Float>.size)


        guard let positionSource = sources.first(where: { $0.semantic == .vertex }) else {
            KvDebug.pause("Unable to access positions in geometry having to positions")
            return ([ ] as [Float3]).withUnsafeBufferPointer(body)
        }

        guard positionSource.usesFloatComponents,
              positionSource.componentsPerVector == 3,
              positionSource.bytesPerComponent == MemoryLayout<Float>.stride,
              positionSource.dataStride == 3 * positionSource.bytesPerComponent
        else {
            KvDebug.pause("Unable to enumerate triangles in geometry where type of positions isn't float triplet")
            return ([ ] as [Float3]).withUnsafeBufferPointer(body)
        }

        return positionSource.data
            .advanced(by: positionSource.dataOffset)[..<(positionSource.dataStride * positionSource.vectorCount)]
            .withUnsafeBytes { body($0.bindMemory(to: Float3.self)) }
    }



    // TODO: Delete in 5.0.0
    @available(*, deprecated)
    @inlinable
    public static func withPositions<R>(in geometry: SCNGeometry, body: (UnsafeBufferPointer<Float3>) -> R) -> R {
        withPositions(in: geometry.sources, body: body)
    }



    // TODO: Delete in 5.0.0
    @available(*, deprecated)
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



    // TODO: Delete in 5.0.0
    @available(*, deprecated)
    @inlinable
    public static func forEachTriangle(in geometry: SCNGeometry, body: (simd_float3, simd_float3, simd_float3) -> Void) {
        forEachTriangle(sources: geometry.sources, elements: geometry.elements, body: body)
    }



    // MARK: .Float3

    // TODO: Delete in 5.0.0
    @available(*, deprecated)
    /// Container for *Float* triplet having the stride equal to size and the same allignment as *Float* type.
    public struct Float3 : Hashable {

        public var x, y, z: Float


        @inlinable
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

    var simdPosition: simd_float3 { get }


    // TODO: Delete in 5.0.0
    @available(*, deprecated, message: "Migrate to .simdPosition")
    var position: SCNVector3 { get }

}


extension KvSCNGeometrySourcePosition3 {

    fileprivate static func builder<Vertex : KvSCNGeometrySourceVertex>(for vertex: Vertex.Type) -> (put: (Vertex) -> Void, build: () -> SCNGeometrySource) {
        var data: Data = .init()
        var count = 0

        return (
            put: { vertex in
                withUnsafeBytes(of: (vertex as! KvSCNGeometrySourcePosition3).simdPosition) {
                    data.append($0.baseAddress!.assumingMemoryBound(to: UInt8.self), count: $0.count)
                }
                count += 1
            },
            build: {
                .init(data: data,
                      semantic: .vertex,
                      vectorCount: count,
                      usesFloatComponents: true,
                      componentsPerVector: simd_float3.scalarCount,
                      bytesPerComponent: MemoryLayout<simd_float3.Scalar>.size,
                      dataOffset: 0,
                      dataStride: data.count / count)
            }
        )
    }


    // TODO: Delete in 5.0.0
    @available(*, deprecated, message: "Migrate to .simdPosition")
    @inlinable public var position: SCNVector3 { .init(simdPosition) }

}



// MARK: KvSCNGeometrySourceNormal3

/// Prodides a normal in 3D coordinate space.
public protocol KvSCNGeometrySourceNormal3 : KvSCNGeometrySourceVertex {

    var simdNormal: simd_float3 { get }


    // TODO: Delete in 5.0.0
    @available(*, deprecated, message: "Migrate to .simdNormal")
    var normal: SCNVector3 { get }

}


extension KvSCNGeometrySourceNormal3 {

    fileprivate static func builder<Vertex : KvSCNGeometrySourceVertex>(for vertex: Vertex.Type) -> (put: (Vertex) -> Void, build: () -> SCNGeometrySource) {
        var data: Data = .init()
        var count = 0

        return (
            put: { vertex in
                withUnsafeBytes(of: (vertex as! KvSCNGeometrySourceNormal3).simdNormal) {
                    data.append($0.baseAddress!.assumingMemoryBound(to: UInt8.self), count: $0.count)
                }
                count += 1
            },
            build: {
                .init(data: data,
                      semantic: .normal,
                      vectorCount: count,
                      usesFloatComponents: true,
                      componentsPerVector: simd_float3.scalarCount,
                      bytesPerComponent: MemoryLayout<simd_float3.Scalar>.size,
                      dataOffset: 0,
                      dataStride: data.count / count)
            }
        )
    }


    // TODO: Delete in 5.0.0
    @available(*, deprecated, message: "Migrate to .simdNormal")
    @inlinable public var normal: SCNVector3 { .init(simdNormal) }

}



// MARK: KvSCNGeometrySourceTx0uv

/// Provides a 2D texture coordinate in 0 slot.
public protocol KvSCNGeometrySourceTx0uv : KvSCNGeometrySourceVertex {

    var simdTx0: simd_float2 { get }


    // TODO: Delete in 5.0.0
    @available(*, deprecated, message: "Migrate to .simdTx0")
    var tx0: CGPoint { get }

}


extension KvSCNGeometrySourceTx0uv {

    fileprivate static func builder<Vertex : KvSCNGeometrySourceVertex>(for vertex: Vertex.Type) -> (put: (Vertex) -> Void, build: () -> SCNGeometrySource) {
        var data: Data = .init()
        var count = 0

        return (
            put: { vertex in
                withUnsafeBytes(of: (vertex as! KvSCNGeometrySourceTx0uv).simdTx0) {
                    data.append($0.baseAddress!.assumingMemoryBound(to: UInt8.self), count: $0.count)
                }
                count += 1
            },
            build: {
                .init(data: data,
                      semantic: .texcoord,
                      vectorCount: count,
                      usesFloatComponents: true,
                      componentsPerVector: simd_float2.scalarCount,
                      bytesPerComponent: MemoryLayout<simd_float2.Scalar>.size,
                      dataOffset: 0,
                      dataStride: data.count / count)
            }
        )
    }


    // TODO: Delete in 5.0.0
    @available(*, deprecated, message: "Migrate to .simdTx0")
    @inlinable public var tx0: CGPoint { .init(x: CGFloat(simdTx0.x), y: CGFloat(simdTx0.y)) }

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
