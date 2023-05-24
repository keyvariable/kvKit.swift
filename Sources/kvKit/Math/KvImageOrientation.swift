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
//  KvImageOrientation.swift
//  kvKit
//
//  Created by Svyatoslav Popov on 01.12.2021.
//



/// Rotation followed by horizontal mirroring.
public enum KvImageOrientation : Hashable, CustomStringConvertible, CaseIterable {

    /// No rotation, no horizontal mirroring. (X', Y') = (X+, Y+).
    case deg0
    /// No rotation, horizontal mirroring. (X', Y') = (X–, Y+).
    case deg0m
    /// Rotation for 90°, no horizontal mirroring. (X', Y') = (Y+, X–).
    case deg90
    /// Rotation for 90°, horizontal mirroring. (X', Y') = (Y+, X+).
    case deg90m
    /// Rotation for 180°, no horizontal mirroring. (X', Y') = (X–, Y–).
    case deg180
    /// Rotation for 180°, horizontal mirroring. (X', Y') = (X+, Y–).
    case deg180m
    /// Rotation for 270°, no horizontal mirroring. (X', Y') = (Y–, X+).
    case deg270
    /// Rotation for 270°, horizontal mirroring. (X', Y') = (Y–, X–).
    case deg270m


    public var rotation: Rotation {
        switch self {
        case .deg0, .deg0m:
            return .deg0
        case .deg90, .deg90m:
            return .deg90
        case .deg180, .deg180m:
            return .deg180
        case .deg270, .deg270m:
            return .deg270
        }
    }

    public var isMirrored: Bool {
        switch self {
        case .deg0, .deg90, .deg180, .deg270:
            return false
        case .deg0m, .deg90m, .deg180m, .deg270m:
            return true
        }
    }


    // MARK: Fabrics

    @inlinable
    public static func with(_ rotation: Rotation, mirrored isMirrored: Bool) -> Self {
        switch (rotation, isMirrored) {
        case (.deg0, false):
            return .deg0
        case (.deg0, true):
            return .deg0m
        case (.deg90, false):
            return .deg90
        case (.deg90, true):
            return .deg90m
        case (.deg180, false):
            return .deg180
        case (.deg180, true):
            return .deg180m
        case (.deg270, false):
            return .deg270
        case (.deg270, true):
            return .deg270m
        }
    }


    // MARK: .Constants

    public enum Constants {

        public enum Matrices {

            /// Shortcut for rotating by 0° (identity) matrix.
            public static let d0:   simd_float2x2 = matrix_identity_float2x2
            /// Shortcut for rotating by 90° matrix.
            public static let d90:  simd_float2x2 = .init([ 0, 1 ], [ -1, 0 ])
            /// Shortcut for rotating by 180° matrix.
            public static let d180: simd_float2x2 = .init(diagonal: [ -1, -1 ])
            /// Shortcut for rotating by 270° matrix.
            public static let d270: simd_float2x2 = .init([ 0, -1 ], [ 1, 0 ])

            /// Shortcut for nonmirroring (identity) matrix.
            public static let i: simd_float2x2 = matrix_identity_float2x2
            /// Shortcut for mirroring matrix.
            public static let m: simd_float2x2 = .init(diagonal: [ -1, 1 ])

            /// Shortcut for translation by (–0.5, –0.5).
            public static let t₋: simd_float3x3 = .init([ 1, 0, 0 ], [ 0, 1, 0 ], [ -0.5, -0.5, 1 ])
            /// Shortcut for translation by (+0.5, +0.5).
            public static let t₊: simd_float3x3 = .init([ 1, 0, 0 ], [ 0, 1, 0 ], [ 0.5, 0.5, 1 ])

        }

    }


    // MARK: : CustomStringConvertible

    public var description: String {
        switch self {
        case .deg0:
            return ".deg0"
        case .deg0m:
            return ".deg0m"
        case .deg90:
            return ".deg90"
        case .deg90m:
            return ".deg90m"
        case .deg180:
            return ".deg180"
        case .deg180m:
            return ".deg180m"
        case .deg270:
            return ".deg270"
        case .deg270m:
            return ".deg270m"
        }
    }


    // MARK: Operations

    @inlinable
    public func mirrored() -> Self {
        switch self {
        case .deg0:
            return .deg0m
        case .deg0m:
            return .deg0
        case .deg90:
            return .deg90m
        case .deg90m:
            return .deg90
        case .deg180:
            return .deg180m
        case .deg180m:
            return .deg180
        case .deg270:
            return .deg270m
        case .deg270m:
            return .deg270
        }
    }


    @inlinable
    public var inverse: Self {
        switch self {
        case .deg0, .deg0m, .deg90m, .deg180, .deg180m, .deg270m:
            return self
        case .deg90:
            return .deg270
        case .deg270:
            return .deg90
        }
    }


    /// - Returns: Equavalent to the receiver's mirroring first and then the receiver's rotation.
    @inlinable
    public func swapped() -> Self {
        switch self {
        case .deg0, .deg0m, .deg90, .deg180, .deg180m, .deg270:
            return self
        case .deg90m:
            return .deg270m
        case .deg270m:
            return .deg90m
        }
    }


    /// - Returns: Transformation 2×2 matrix for the receiver.
    ///
    /// - Note: It's applicable to vectors.
    @inlinable
    public func transform2() -> simd_float2x2 {
        (isMirrored ? Constants.Matrices.m : Constants.Matrices.i) * rotation.transform()
    }

    /// - Returns: Inverse transformation 2×2 matrix for the receiver.
    ///
    /// - Note: It's applicable to vectors.
    @inlinable
    public func transform2⁻¹() -> simd_float2x2 {
        rotation.transform⁻¹() * (isMirrored ? Constants.Matrices.m : Constants.Matrices.i)
    }

    /// - Returns: Inverse transformation 2×2 matrix for the receiver.
    ///
    /// - Note: It's applicable to vectors.
    @inlinable
    public func inverseTransform2() -> simd_float2x2 { transform2⁻¹() }


    /// - Returns: 3×3 matrix reprentation of the receiver.
    ///
    /// - Note: It's applicable to normalized positons on images. Normalized position components are in 0...1.
    @inlinable
    public func transform() -> simd_float3x3 {
        Constants.Matrices.t₊ * KvMathFloatScope.make3(transform2()) * Constants.Matrices.t₋
    }

    /// - Returns: Inverse 3×3 matrix reprentation of the receiver.
    ///
    /// - Note: It's applicable to normalized positons on images. Normalized position components are in 0...1.
    @inlinable
    public func transform⁻¹() -> simd_float3x3 {
        Constants.Matrices.t₊ * KvMathFloatScope.make3(transform2⁻¹()) * Constants.Matrices.t₋
    }

    /// - Returns: Inverse 3×3 matrix reprentation of the receiver.
    ///
    /// - Note: It's applicable to normalized positons on images. Normalized position components are in 0...1.
    @inlinable
    public func inverseTransform() -> simd_float3x3 { transform⁻¹() }


    @inlinable
    public func concatenated(with rhs: Self) -> Self {
        switch self {
        case .deg0:
            return rhs
        case .deg0m:
            return rhs.mirrored()
        case .deg90:
            switch rhs {
            case .deg0: return .deg90
            case .deg0m: return .deg270m
            case .deg90: return .deg180
            case .deg90m: return .deg0m
            case .deg180:  return .deg270
            case .deg180m: return .deg90m
            case .deg270: return .deg0
            case .deg270m: return .deg180m
            }
        case .deg90m:
            switch rhs {
            case .deg0: return .deg90m
            case .deg0m: return .deg270
            case .deg90: return .deg180m
            case .deg90m: return .deg0
            case .deg180:  return .deg270m
            case .deg180m: return .deg90
            case .deg270: return .deg0m
            case .deg270m: return .deg180
            }
        case .deg180:
            switch rhs {
            case .deg0: return .deg180
            case .deg0m: return .deg180m
            case .deg90: return .deg270
            case .deg90m: return .deg270m
            case .deg180:  return .deg0
            case .deg180m: return .deg0m
            case .deg270: return .deg90
            case .deg270m: return .deg90m
            }
        case .deg180m:
            switch rhs {
            case .deg0: return .deg180m
            case .deg0m: return .deg180
            case .deg90: return .deg270m
            case .deg90m: return .deg270
            case .deg180:  return .deg0m
            case .deg180m: return .deg0
            case .deg270: return .deg90m
            case .deg270m: return .deg90
            }
        case .deg270:
            switch rhs {
            case .deg0: return .deg270
            case .deg0m: return .deg90m
            case .deg90: return .deg0
            case .deg90m: return .deg180m
            case .deg180:  return .deg90
            case .deg180m: return .deg270m
            case .deg270: return .deg180
            case .deg270m: return .deg0m
            }
        case .deg270m:
            switch rhs {
            case .deg0: return .deg270m
            case .deg0m: return .deg90
            case .deg90: return .deg0m
            case .deg90m: return .deg180
            case .deg180:  return .deg90m
            case .deg180m: return .deg270
            case .deg270: return .deg180m
            case .deg270m: return .deg0
            }
        }
    }


    @inlinable
    public static func *(lhs: Self, rhs: Self) -> Self { lhs.concatenated(with: rhs) }

    @inlinable
    public static func *=(lhs: inout Self, rhs: Self) { lhs = lhs.concatenated(with: rhs) }

}



// MARK: .Rotation

extension KvImageOrientation {

    public enum Rotation : Hashable, CustomStringConvertible, CaseIterable {

        case deg0, deg90, deg180, deg270


        // MARK: : CustomStringConvertible

        public var description: String {
            switch self {
            case .deg0:
                return ".deg0"
            case .deg90:
                return ".deg90"
            case .deg180:
                return ".deg180"
            case .deg270:
                return ".deg270"
            }
        }


        // MARK: Operations

        @inlinable
        public var inverse: Self {
            switch self {
            case .deg0:
                return .deg0
            case .deg90:
                return .deg270
            case .deg180:
                return .deg180
            case .deg270:
                return .deg90
            }
        }


        /// - Returns: Transformation matrix for the receiver.
        @inlinable
        public func transform() -> simd_float2x2 {
            switch self {
            case .deg0:
                return Constants.Matrices.d0
            case .deg90:
                return Constants.Matrices.d90
            case .deg180:
                return Constants.Matrices.d180
            case .deg270:
                return Constants.Matrices.d270
            }
        }

        /// - Returns: Inverse transformation matrix for the receiver.
        @inlinable
        public func transform⁻¹() -> simd_float2x2 {
            switch self {
            case .deg0:
                return Constants.Matrices.d0
            case .deg90:
                return Constants.Matrices.d270
            case .deg180:
                return Constants.Matrices.d180
            case .deg270:
                return Constants.Matrices.d90
            }
        }

        /// - Returns: Inverse transformation matrix for the receiver.
        @inlinable
        public func inverseTransform() -> simd_float2x2 { transform⁻¹() }


        @inlinable
        public func concatenated(with rhs: Self) -> Self {
            switch (self, rhs) {
            case (.deg0, .deg0), (.deg90, .deg270), (.deg180, .deg180), (.deg270, .deg90):
                return .deg0
            case (.deg0, .deg90), (.deg90, .deg0), (.deg180, .deg270), (.deg270, .deg180):
                return .deg90
            case (.deg0, .deg180), (.deg90, .deg90), (.deg180, .deg0), (.deg270, .deg270):
                return .deg180
            case (.deg0, .deg270), (.deg90, .deg180), (.deg180, .deg90), (.deg270, .deg0):
                return .deg270
            }
        }


        @inlinable
        public static func *(lhs: Self, rhs: Self) -> Self { lhs.concatenated(with: rhs) }

        @inlinable
        public static func *=(lhs: inout Self, rhs: Self) { lhs = lhs.concatenated(with: rhs) }

    }

}



// MARK: AVFoundation Auxiliaries

#if canImport(AVFoundation)

import AVFoundation


extension KvImageOrientation {

    /// - Returns: Transformation of uncorrected input from *videoConnection* at *position* to the portraint orientation (Y+ is up, X+ is right).
    @inlinable
    public static func from(videoConnection: AVCaptureConnection, position: AVCaptureDevice.Position) -> Self {
        let isMirrored: Bool = {
            switch position {
            case .front, .unspecified:
                return videoConnection.isVideoMirrored
            case .back:
                return !videoConnection.isVideoMirrored
            @unknown default:
                return videoConnection.isVideoMirrored
            }
        }()

        switch videoConnection.videoOrientation {
        case .portrait:
            return isMirrored ? .deg0m : .deg0
        case .portraitUpsideDown:
            return isMirrored ? .deg180m : .deg180
        case .landscapeLeft:
            return isMirrored ? .deg90m : .deg270
        case .landscapeRight:
            return isMirrored ? .deg270m : .deg90
        @unknown default:
            return isMirrored ? .deg0m : .deg0
        }
    }

}

#endif // canImport(AVFoundation)



// MARK: CoreGraphics Auxiliaries

#if canImport(CoreGraphics)

import CoreGraphics


extension KvImageOrientation {

    /// - Returns: Transformation from given image orientation to the portraint orientatoin (Y+ is up, X+ is right).
    @inlinable
    public static func from(_ cgOrientation: CGImagePropertyOrientation) -> Self {
        switch cgOrientation {
        case .down:
            return .deg180
        case .downMirrored:
            return .deg180m
        case .left:
            return .deg90
        case .leftMirrored:
            return .deg270m
        case .right:
            return .deg270
        case .rightMirrored:
            return .deg90m
        case .up:
            return .deg0
        case .upMirrored:
            return .deg0m
        }
    }


    @inlinable
    public var cgOrientation: CGImagePropertyOrientation {
        switch self {
        case .deg0:
            return .up
        case .deg0m:
            return .upMirrored
        case .deg90:
            return .left
        case .deg90m:
            return .rightMirrored
        case .deg180:
            return .down
        case .deg180m:
            return .downMirrored
        case .deg270:
            return .right
        case .deg270m:
            return .leftMirrored
        }
    }

}

#endif // canImport(CoreGraphics)



// MARK: UIKit Auxiliaries

#if canImport(UIKit)

import UIKit


extension KvImageOrientation {

    /// - Returns: Transformation from the portraint orientatoin (Y+ is up, X+ is right) to given UI orientation.
    @inlinable
    public static func to(_ orientation: UIInterfaceOrientation, mirrored isMirrored: Bool) -> Self {
        switch orientation {
        case .landscapeLeft:
            return isMirrored ? .deg90m : .deg90
        case .landscapeRight:
            return isMirrored ? .deg270m : .deg270
        case .portrait, .unknown:
            return isMirrored ? .deg0m : .deg0
        case .portraitUpsideDown:
            return isMirrored ? .deg180m : .deg180
        @unknown default:
            return isMirrored ? .deg0m : .deg0
        }
    }

}


extension KvImageOrientation.Rotation {

    /// - Returns: Transformation from the portraint orientatoin (Y+ is up, X+ is right) to given UI orientation.
    @inlinable
    public static func to(_ orientation: UIInterfaceOrientation) -> Self {
        switch orientation {
        case .landscapeLeft:
            return .deg90
        case .landscapeRight:
            return .deg270
        case .portrait, .unknown:
            return .deg0
        case .portraitUpsideDown:
            return .deg180
        @unknown default:
            return .deg0
        }
    }
    
}

#endif // canImport(UIKit)
