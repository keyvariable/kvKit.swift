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
//  KvRoundedRectangle.swift
//  kvKit
//
//  Created by Svyatoslav Popov on 12.08.2021.
//

#if canImport(SwiftUI)

import SwiftUI



@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public struct KvRoundedRectangle : InsettableShape {

    public var radii: Radii
    public var segments: Segments

    public var inset: CGFloat



    @inlinable
    public init(radii: Radii, segments: Segments = .all, inset: CGFloat = 0.0) {
        self.radii = radii
        self.segments = segments
        self.inset = inset
    }



    // MARK: : Shape

    public func path(in rect: CGRect) -> Path {
        let rect = rect.insetBy(dx: min(inset, (0.5 as CGFloat) * rect.width), dy: min(inset, (0.5 as CGFloat) * rect.height))

        let radii = radii
            .inset(by: inset)
            .fitted(in: rect)


        enum Action {

            case move(to: CGPoint)
            case line(to: CGPoint)
            case arc(center: CGPoint, radius: CGFloat, startAngle: Double, endAngle: Double)


            func apply(to path: inout Path) {
                switch self {
                case let .arc(center, radius, startAngle, endAngle):
                    path.addArc(center: center, radius: radius, startAngle: .init(radians: startAngle), endAngle: .init(radians: endAngle), clockwise: true)
                case .line(to: let point):
                    path.addLine(to: point)
                case .move(to: let point):
                    path.move(to: point)
                }
            }

        }


        var actions: [Action] = .init()
        var lastMoveActionIndex: Int?

        var isLastSegmentVisible = segments.contains(.bottomLeft)


        func AddSegment(_ segment: Segments, from start: CGPoint, body: () -> Void) {
            switch segments.contains(segment) {
            case true:
                if !isLastSegmentVisible {
                    isLastSegmentVisible = true

                    lastMoveActionIndex = actions.endIndex

                    actions.append(.move(to: start))
                }

                body()

            case false:
                isLastSegmentVisible = false
            }
        }


        func AddLineSegment(_ segment: Segments, from start: CGPoint, to end: CGPoint) {
            AddSegment(segment, from: start) {
                actions.append(.line(to: end))
            }
        }


        func AddArcSegment(_ segment: Segments, from start: CGPoint, center: CGPoint, radius: CGFloat, startAngle: Double, endAngle: Double) {
            guard radius > .ulpOfOne else { return }

            AddSegment(segment, from: start) {
                actions.append(.arc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle))
            }
        }


        let p₀ = CGPoint(x: rect.minX + radii.bottomLeft, y: rect.maxY)

        do {
            let r₂ = radii.bottomRight, p₂ = CGPoint(x: rect.maxX - r₂, y: rect.maxY)

            AddLineSegment(.bottom, from: p₀, to: p₂)
            AddArcSegment(.bottomRight, from: p₂, center: .init(x: p₂.x, y: p₂.y - r₂), radius: r₂, startAngle: (0.5 as CGFloat) * CGFloat.pi, endAngle: 0.0 as CGFloat)
        }
        do {
            let r₁ = radii.bottomRight, p₁ = CGPoint(x: rect.maxX, y: rect.maxY - r₁)
            let r₂ = radii.topRight, p₂ = CGPoint(x: rect.maxX, y: rect.minY + r₂)

            AddLineSegment(.right, from: p₁, to: p₂)
            AddArcSegment(.topRight, from: p₂, center: .init(x: p₂.x - r₂, y: p₂.y), radius: r₂, startAngle: (0.0 as CGFloat), endAngle: (-0.5 as CGFloat) * CGFloat.pi)
        }
        do {
            let r₁ = radii.topRight, p₁ = CGPoint(x: rect.maxX - r₁, y: rect.minY)
            let r₂ = radii.topLeft, p₂ = CGPoint(x: rect.minX + r₂, y: rect.minY)

            AddLineSegment(.top, from: p₁, to: p₂)
            AddArcSegment(.topLeft, from: p₂, center: .init(x: p₂.x, y: p₂.y + r₂), radius: r₂, startAngle: (1.5 as CGFloat) * CGFloat.pi, endAngle: CGFloat.pi)
        }
        do {
            let r₁ = radii.topLeft, p₁ = CGPoint(x: rect.minX, y: rect.minY + r₁)
            let r₂ = radii.bottomLeft, p₂ = CGPoint(x: rect.minX, y: rect.maxY - r₂)

            AddLineSegment(.left, from: p₁, to: p₂)
            AddArcSegment(.bottomLeft, from: p₂, center: .init(x: p₂.x + r₂, y: p₂.y), radius: r₂, startAngle: CGFloat.pi, endAngle: (0.5 as CGFloat) * CGFloat.pi)
        }


        var path = Path()

        switch lastMoveActionIndex {
        case .some(let index):
            actions[index...].forEach { $0.apply(to: &path) }
            actions[..<index].forEach { $0.apply(to: &path) }

        case .none:
            path.move(to: p₀)
            actions.forEach { $0.apply(to: &path) }
            path.closeSubpath()
        }

        return path
    }



    // MARK: : InsettableShape

    @inlinable
    public func inset(by amount: CGFloat) -> some InsettableShape {
        var insetShape = self

        insetShape.inset += amount

        return insetShape
    }

}



// MARK: .Radii

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension KvRoundedRectangle {

    public struct Radii : ExpressibleByIntegerLiteral, ExpressibleByFloatLiteral, ExpressibleByArrayLiteral, Equatable {

        public var topLeft: CGFloat
        public var topRight: CGFloat
        public var bottomRight: CGFloat
        public var bottomLeft: CGFloat


        @inlinable
        public init(topLeft: CGFloat = 0, topRight: CGFloat = 0, bottomRight: CGFloat = 0, bottomLeft: CGFloat = 0) {
            self.topLeft = max(topLeft, 0)
            self.topRight = max(topRight, 0)
            self.bottomRight = max(bottomRight, 0)
            self.bottomLeft = max(bottomLeft, 0)
        }


        @inlinable
        public init(_ value: CGFloat) {
            self.init(topLeft: value, topRight: value, bottomRight: value, bottomLeft: value)
        }


        @inlinable
        public init(top: CGFloat = 0, bottom: CGFloat = 0) {
            self.init(topLeft: top, topRight: top, bottomRight: bottom, bottomLeft: bottom)
        }


        @inlinable
        public init(left: CGFloat = 0, right: CGFloat = 0) {
            self.init(topLeft: left, topRight: right, bottomRight: right, bottomLeft: left)
        }


        // MARK: : ExpressibleByIntegerLiteral

        @inlinable
        public init(integerLiteral value: CGFloat.IntegerLiteralType) {
            self.init(.init(integerLiteral: value))
        }


        // MARK: : ExpressibleByFloatLiteral

        @inlinable
        public init(floatLiteral value: CGFloat.FloatLiteralType) {
            self.init(.init(floatLiteral: value))
        }


        // MARK: : ExpressibleByArrayLiteral

        /// Initializes instance with given *elements* in the following order: *topLeft*, *topRight*, *bottomRight*, *bottomLeft*.
        ///
        /// - Note: Given *elemets* are repeated if needed.
        @inlinable
        public init(arrayLiteral elements: CGFloat.FloatLiteralType...) {
            assert(elements.count == 4, "elements.count have to be 4")

            self.init(topLeft: .init(floatLiteral: elements[0]),
                      topRight: .init(floatLiteral: elements[1]),
                      bottomRight: .init(floatLiteral: elements[2]),
                      bottomLeft: .init(floatLiteral: elements[3]))
        }


        // MARK: Operations

        @inlinable
        public func inset(by amount: CGFloat) -> Self {
            .init(topLeft: topLeft - amount,
                  topRight: topRight - amount,
                  bottomRight: bottomRight - amount,
                  bottomLeft: bottomLeft - amount)
        }


        public func fitted(in rect: CGRect) -> Self {

            func ScaleIfNeeded(r₁: inout CGFloat, r₂: inout CGFloat, edge: CGFloat) {
                guard r₁ + r₂ > edge else { return }

                let scale = edge / (r₁ + r₂)

                r₁ *= scale
                r₂ *= scale
            }


            var radii = self

            ScaleIfNeeded(r₁: &radii.topLeft, r₂: &radii.topRight, edge: rect.width)
            ScaleIfNeeded(r₁: &radii.bottomLeft, r₂: &radii.bottomRight, edge: rect.width)

            ScaleIfNeeded(r₁: &radii.topLeft, r₂: &radii.bottomLeft, edge: rect.height)
            ScaleIfNeeded(r₁: &radii.topRight, r₂: &radii.bottomRight, edge: rect.height)

            return radii
        }


        @inlinable
        public func with(minimum: CGFloat) -> Self {
            .init(topLeft: max(minimum, topLeft),
                  topRight: max(minimum, topRight),
                  bottomRight: max(minimum, bottomRight),
                  bottomLeft: max(minimum, bottomLeft))
        }

    }

}



// MARK: .Segments

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension KvRoundedRectangle {

    public struct Segments : OptionSet {

        public static let topLeft = Self(rawValue: 1 << 0)
        public static let top = Self(rawValue: 1 << 1)
        public static let topRight = Self(rawValue: 1 << 2)

        public static let right = Self(rawValue: 1 << 3)

        public static let bottomRight = Self(rawValue: 1 << 4)
        public static let bottom = Self(rawValue: 1 << 5)
        public static let bottomLeft = Self(rawValue: 1 << 6)

        public static let left = Self(rawValue: 1 << 7)


        public static let topSide: Self = [ .topLeft, .top, .topRight ]
        public static let bottomSide: Self = [ .bottomLeft, .bottom, .bottomRight ]

        public static let leftSide: Self = [ .topLeft, .left, .bottomLeft ]
        public static let rightSide: Self = [ .topRight, .right, .bottomRight ]

        public static let all: Self = [ .topSide, .bottomSide, .left, .right ]


        // MARK: : OptionSet

        public let rawValue: UInt

        public init(rawValue: UInt) { self.rawValue = rawValue }
    }

}

#endif // canImport(SwiftUI)
