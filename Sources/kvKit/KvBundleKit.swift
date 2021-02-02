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
//  KvBundleKit.swift
//  kvKit
//
//  Created by Svyatoslav Popov on 02.02.2021.
//

#if os(macOS)
import Cocoa
#elseif os(iOS)
import UIKit
#endif // os(iOS)



/// Various utilities for standard *Bundle* class.
public class KvBundleKit { }



// MARK: Info Dictionary

extension KvBundleKit {

    /// - Returns: Value for *CFBundleName* key from the info dictionary of given *bundle*.
    public static func applicationName(_ bundle: Bundle = .main) -> String? {
        bundle.object(forInfoDictionaryKey: "CFBundleName") as? String
    }



    /// - Returns: Value for *CFBundleShortVersionString* key from the info dictionary of given *bundle*.
    public static func shortVersion(_ bundle: Bundle = .main) -> String? {
        bundle.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }



    /// - Returns: Value for *CFBundleVersion* key from the info dictionary of given *bundle*.
    public static func bundleVection(_ bundle: Bundle = .main) -> String? {
        bundle.object(forInfoDictionaryKey: "CFBundleVersion") as? String
    }

}



// MARK: NIB

extension KvBundleKit {

    #if os(macOS)
    /// An instantiation method with error checking.
    @discardableResult
    public static func viewFromNib<T: NSView>(named nibName: String, index: Int? = nil, bundle: Bundle = .main, owner: Any? = nil) throws -> T {
        var topLevelObjects: NSArray?

        guard bundle.loadNibNamed(nibName, owner: owner, topLevelObjects: &topLevelObjects) else {
            throw KvError("Internal inconsistency: unable to load views from NIB named ‘\(nibName)’ in \(bundle) bundle")
        }

        if let index = index {
            guard let view = topLevelObjects![index] as? T else {
                throw KvError("Internal inconsistency: ‘\(nibName)’ NIB contains item of unexpected class ‘\(type(of: topLevelObjects![index]))’ at index \(index)")
            }
            return view

        } else {
            guard let view = topLevelObjects!.lazy.compactMap({ $0 as? T }).first else {
                throw KvError("Internal inconsistency: ‘\(nibName)’ NIB contains no item of \(T.self) class")
            }
            return view
        }
    }
    #endif // macOS



    #if os(iOS)
    /// An instantiation method with error checking.
    @discardableResult
    public static func viewFromNib<T: UIView>(named nibName: String, index: Int? = nil, bundle: Bundle = .main, owner: Any? = nil) throws -> T {
        guard let topLevelObjects = bundle.loadNibNamed(nibName, owner: owner) else {
            throw KvError("Internal inconsistency: unable to load views from NIB named ‘\(nibName)’ in \(bundle) bundle")
        }

        if let index = index {
            guard let view = topLevelObjects[index] as? T else {
                throw KvError("Internal inconsistency: ‘\(nibName)’ NIB contains item of unexpected class ‘\(type(of: topLevelObjects[index]))’ at index \(index)")
            }
            return view

        } else {
            guard let view = topLevelObjects.lazy.compactMap({ $0 as? T }).first else {
                throw KvError("Internal inconsistency: ‘\(nibName)’ NIB contains no item of \(T.self) class")
            }
            return view
        }
    }
    #endif // macOS

}
