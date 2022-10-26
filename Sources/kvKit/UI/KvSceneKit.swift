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
