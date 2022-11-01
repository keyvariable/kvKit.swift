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
//  KvCIFilterKit.swift
//  kvKit
//
//  Created by Svyatoslav Popov on 20.04.2022.
//

#if canImport(CoreImage)



import CoreImage



/// Collection of auxiliaries related to *CIFilter*.
public struct KvCIFilterKit { private init() { } }



// MARK: - Application of Filters

extension KvCIFilterKit {

    /// - Returns: The result of seqiential application of given filters to given image.
    public static func apply<CIFilters>(_ filters: CIFilters, to image: CIImage) throws -> CIImage
    where CIFilters : Sequence, CIFilters.Element == CIFilter {
        var result = image
        var iterator = filters.makeIterator()

        while let filter = iterator.next() {
            filter.setValue(result, forKey: kCIInputImageKey)

            guard let nextImage = filter.outputImage else { throw KvError("Failed to apply «\(filter.name)» core image filter") }

            result = nextImage
        }

        return result
    }


    #if os(iOS) || os(macOS)
    /// - Returns: The result of seqiential application of given filters to given image.
    ///
    /// - Note: Due to filters are applied to instances of *CIImage* type, method performs convertion of input to *CIImage* and the result from *CIImage*. Provide images of *CIImage* type if possible.
    @inlinable
    public static func apply<CIFilters>(_ filters: CIFilters, to image: KvUI.Image) throws -> KvUI.Image
    where CIFilters : Sequence, CIFilters.Element == CIFilter
    {
        guard let sourceImage = KvCIImageKit.from(image) else { throw KvError("Unable to represent input image as CIImage") }

        let ciImage = try apply(filters, to: sourceImage)

        return KvCIImageKit.uiImage(from: ciImage)
    }
    #endif // os(iOS) || os(macOS)

}



#endif // canImport(CoreImage)
