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
//  KvCIImageKit.swift
//  kvKit
//
//  Created by Svyatoslav Popov on 21.04.2022.
//

#if os(iOS)
import UIKit
#endif // os(iOS)
#if os(macOS)
import AppKit
#endif // os(macOS)



/// Collection of auxiliaries related to *CIImage*.
public struct KvCIImageKit { private init() { } }



// MARK: - Contertions

extension KvCIImageKit {

#if os(iOS)
    /// - Returns: A standard user interface image representing given *ciImage*. E.g. in iOS it's *UIImage*, in MacOS it's *NSImage*.
    @inlinable
    public static func uiImage(from ciImage: CIImage) -> KvUI.Image {
        UIImage(ciImage: ciImage)
    }

#elseif os(macOS)
    /// - Returns: A standard user interface image representing given *ciImage*. E.g. in iOS it's *UIImage*, in MacOS it's *NSImage*.
    public static func uiImage(from ciImage: CIImage) -> KvUI.Image {
        let representation = NSCIImageRep(ciImage: ciImage)
        let image = NSImage(size: representation.size)

        image.addRepresentation(representation)

        return image
    }

#endif // os(macOS)



#if os(iOS)
    /// - Parameter uiImage: E.g. *UIImage* in iOS, *NSImage* in MacOS.
    ///
    /// - Returns: Instance of *CIImage* type from given standard user interface image.
    @inlinable
    public static func from(_ uiImage: KvUI.Image) -> CIImage? {
        CIImage(image: uiImage)
    }

#elseif os(macOS)
    /// - Parameter uiImage: E.g. *UIImage* in iOS, *NSImage* in MacOS.
    ///
    /// - Returns: Instance of *CIImage* type from given standard user interface image.
    public static func from(_ nsImage: KvUI.Image) -> CIImage? {
        var rect = NSRect(origin: .zero, size: nsImage.size)

        return nsImage
            .cgImage(forProposedRect: &rect, context: NSGraphicsContext.current, hints: nil)
            .map(CIImage.init(cgImage:))
    }
#endif // os(macOS)

}
