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
//  KvPixelMapping.swift
//  kvKit
//
//  Created by Svyatoslav Popov on 24.12.2018.
//

import Foundation

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif // AppKit



/// Rounds any values to exact pixel coordinates taking screen scale into account.
public class KvPixelMapping {

    public var scale: CGFloat = 1 {
        didSet {
            guard abs(scale - oldValue) >= KvPixelMapping.eps else { return }

            if abs(scale) < KvPixelMapping.eps {
                KvDebug.pause("Warning: .scale = \(scale) is too small in absolute value")
            }

            update()
        }
    }


    // px = x * pixelMult
    public private(set) var pixelFactor: CGFloat = 1

    // dp = px * dpMult
    public private(set) var dpFactor: CGFloat = 1



    public init() { }

}



// MARK: Mappping

extension KvPixelMapping {

    public func range(for range: Range<CGFloat>) -> Range<CGFloat> {
        let pixelRange = pixelFactor * range.lowerBound ..< pixelFactor * range.upperBound

        if pixelRange.upperBound - pixelRange.lowerBound >= 1 {
            return floor(pixelRange.lowerBound + 0.5) * dpFactor ..< floor(pixelRange.upperBound + 0.5) * dpFactor

        } else {
            let pixelCenter = floor(0.5 * (pixelRange.lowerBound + pixelRange.upperBound)) + 0.5

            return (pixelCenter - 0.5) * dpFactor ..< (pixelCenter + 0.5) * dpFactor
        }
    }



    @inlinable
    public func rect(for rect: CGRect) -> CGRect {
        let ranges = (x: range(for: rect.minX ..< rect.maxX),
                      y: range(for: rect.minY ..< rect.maxY))

        return .init(x: ranges.x.lowerBound, y: ranges.y.lowerBound, width: ranges.x.upperBound - ranges.x.lowerBound, height: ranges.y.upperBound - ranges.y.lowerBound)
    }



    @inlinable
    public func dot(at x: CGFloat, of radius: CGFloat) -> CGFloat {
        let segment = range(for: (x - radius) ..< (x + radius))

        return 0.5 * (segment.lowerBound + segment.upperBound)
    }



    @inlinable
    public func linePoint(for x: CGFloat, _ y: CGFloat, of width: CGFloat) -> CGPoint {
        let halfWidth = 0.5 * width

        let pointRange = rect(for: .init(x: x - halfWidth, y: y - halfWidth, width: width, height: width))

        return .init(x: pointRange.midX, y: pointRange.midY)
    }

}



// MARK: Auxiliaries

extension KvPixelMapping {

#if canImport(UIKit)
    /// Set *scale* property equal to scale of a window given *view* is presented in.
    @inlinable
    public func setScale(for view: UIView) {
        scale = view.window?.screen.scale ?? 1
    }


#elseif canImport(AppKit)

    /// Set *scale* property equal to scale of a window given *view* is presented in.
    @inlinable
    public func setScale(for view: NSView) {
        scale = view.window?.backingScaleFactor ?? 1
    }
#endif // canImport(AppKit)

}



// MARK: Maintaining of Mapping

fileprivate extension KvPixelMapping {

    static let eps: CGFloat = 1e-3



    private func update() {
        pixelFactor = abs(scale) >= KvPixelMapping.eps ? scale : 1

        dpFactor = 1 / pixelFactor
    }

}
