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
//  KvWeak.swift
//  kvKit
//
//  Created by Svyatoslav Popov on 09.08.2018.
//

import Foundation



/// A container for a weak reference.
@available(*, deprecated, message: "Use custom containers")
public struct KvWeak<T: AnyObject> {

    public private(set) weak var value: T?



    public init(_ value: T?) {
        self.value = value
        objectID = .init(value ?? NSNull())
    }



    private var objectID: ObjectIdentifier

}



// MARK: : Equatable

@available(*, deprecated, message: "Use custom containers")
extension KvWeak : Equatable {

    public static func ==(_ lhs: KvWeak<T>, _ rhs: KvWeak<T>) -> Bool {
        /// - Note: Object IDs are compared instead of values due to prevent inconsistency of collections like `Set<KvWeak>`. The problem is that consistenct set of two distinct objets can become
        ///         inconsistent having two instances of *KvWeak* having .value equal to *nil*.
        lhs.objectID == rhs.objectID
    }

}



// MARK: : Hashable

@available(*, deprecated, message: "Use custom containers")
extension KvWeak : Hashable where T: Hashable {

    public func hash(into hasher: inout Hasher) { objectID.hash(into: &hasher) }

}



// MARK: : ExpressibleByNilLiteral

@available(*, deprecated, message: "Use custom containers")
extension KvWeak : ExpressibleByNilLiteral {

    public init(nilLiteral: ()) {
        self.init(nil)
    }

}
