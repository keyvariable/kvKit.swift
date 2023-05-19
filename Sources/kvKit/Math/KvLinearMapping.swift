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
//  KvLinearMapping.swift
//  KvKit
//
//  Created by Svyatoslav Popov on 22.04.2018.
//

import Foundation



// MARK: - KvLinearMappingProtocol

public protocol KvLinearMappingProtocol {

    associatedtype Value: BinaryFloatingPoint



    var k: Value { get }
    var b: Value { get }



    /// Initialize an instance mapping *x₁* to *y₁* and *x₂* to *y₂*.
    init(x₁: Value, y₁: Value, x₂: Value, y₂: Value)



    /// - Returns: The result of mapping at *x*.
    func y(at x: Value) -> Value

}



// MARK: Convenience Initializers

public extension KvLinearMappingProtocol {

    init(from: Range<Value>, to: Range<Value>) {
        self.init(x₁: from.lowerBound, y₁: to.lowerBound, x₂: from.upperBound, y₂: to.upperBound)
    }



    init(from: ClosedRange<Value>, to: ClosedRange<Value>) {
        self.init(x₁: from.lowerBound, y₁: to.lowerBound, x₂: from.upperBound, y₂: to.upperBound)
    }

}



// MARK: KvLinearMapping

/// Simple liear mapping.
///
/// - SeeAlso: KvShiftedLinearMapping
public struct KvLinearMapping<Value: BinaryFloatingPoint> {

    public var k, b: Value



    public init(k: Value = 0.0, b: Value = 0.0) {
        self.k = k
        self.b = b
    }

}



// MARK: : KvLinearMappingProtocol

extension KvLinearMapping : KvLinearMappingProtocol {

    public init(x₁: Value, y₁: Value, x₂: Value, y₂: Value) {
        precondition(abs(x₂ - x₁) >= Value.ulpOfOne, "Invalid arguments: x₁ and x₂ must not be equal")

        let d = 1.0 as Value / (x₂ - x₁) as Value

        self.init(k: (y₂ - y₁) * d, b: (y₁ * x₂ - y₂ * x₁) * d)
    }



    @inlinable
    public func y(at x: Value) -> Value { b.addingProduct(x, k) }

}



// MARK: : CustomStringConvertible

extension KvLinearMapping : CustomStringConvertible {

    public var description: String { "\(Self.self)<\(Value.self)>(\(k) × 𝑥 + \(b))" }

}



// MARK: - KvShiftedLinearMapping

/// Linear mapping with explicit origin.
///
/// - Note: It's designed to minimize floating point inaccuracy.
///
/// - SeeAlso: KvLiearMapping
public struct KvShiftedLinearMapping<Value: BinaryFloatingPoint> {

    public var k, y₀, x₀: Value



    public init(k: Value, x₀: Value, y₀: Value) {
        self.k = k
        self.x₀ = x₀
        self.y₀ = y₀
    }

}



// MARK: Auxiliary Initializers

extension KvShiftedLinearMapping {

    public init(_ comoment: KvStatistics.Covariance<Value>.Comoment, _ moment: Value) {
        self.init(k: moment > .ulpOfOne ? comoment.value / moment : 0, x₀: comoment.average.x, y₀: comoment.average.y)
    }

}



// MARK: : KvLinearMappingProtocol

extension KvShiftedLinearMapping : KvLinearMappingProtocol {

    @inlinable
    public var b: Value { y₀.addingProduct(-k, x₀) }



    public init(x₁: Value, y₁: Value, x₂: Value, y₂: Value) {
        precondition(abs(x₂ - x₁) >= .ulpOfOne, "Invalid arguments: x₁ and x₂ must not be equal")

        k = (y₂ - y₁) / (x₂ - x₁)
        y₀ = (y₁ + y₂) / 2
        x₀ = (x₁ + x₂) / 2
    }



    @inlinable
    public func y(at x: Value) -> Value { y₀.addingProduct(x - x₀, k) }

}



// MARK:  Protocol CustomStringConvertible

extension KvShiftedLinearMapping : CustomStringConvertible {

    public var description: String { "\(Self.self)<\(Value.self)>(\(k) × (𝑥 – \(x₀)) + \(y₀))" }

}
