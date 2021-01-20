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
//  KvCGFloatCompatible.swift
//  KvKit
//
//  Created by Svyatoslav Popov on 27.06.2019.
//

#if canImport(CoreGraphics)



import CoreGraphics



/// It's designed to solve difficulties with implemention of generics related with `CGFloat`.
public protocol KvCGFloatCompatible {

    var isFinite: Bool { get }


    func cgFloat() -> CGFloat

}



// MARK: Float

extension Float : KvCGFloatCompatible {

    @inlinable
    public func cgFloat() -> CGFloat { .init(self) }

}



// MARK: Double

extension Double : KvCGFloatCompatible {

    @inlinable
    public func cgFloat() -> CGFloat { .init(self) }

}



// MARK: Float16

@available (iOS 14.0, *)
@available(macOS, unavailable)
@available(macCatalyst, unavailable)
extension Float16 : KvCGFloatCompatible {

    @inlinable
    public func cgFloat() -> CGFloat { .init(self) }

}



// MARK: Int

extension Int : KvCGFloatCompatible {

    @inlinable
    public var isFinite: Bool { true }


    @inlinable
    public func cgFloat() -> CGFloat { .init(self) }

}



// MARK: Int8

extension Int8 : KvCGFloatCompatible {

    @inlinable
    public var isFinite: Bool { true }


    @inlinable
    public func cgFloat() -> CGFloat { .init(self) }

}



// MARK: Int16

extension Int16 : KvCGFloatCompatible {

    @inlinable
    public var isFinite: Bool { true }


    @inlinable
    public func cgFloat() -> CGFloat { .init(self) }

}



// MARK: Int32

extension Int32 : KvCGFloatCompatible {

    @inlinable
    public var isFinite: Bool { true }


    @inlinable
    public func cgFloat() -> CGFloat { .init(self) }

}



// MARK: Int64

extension Int64 : KvCGFloatCompatible {

    @inlinable
    public var isFinite: Bool { true }


    @inlinable
    public func cgFloat() -> CGFloat { .init(self) }

}



// MARK: UInt

extension UInt : KvCGFloatCompatible {

    @inlinable
    public var isFinite: Bool { true }


    @inlinable
    public func cgFloat() -> CGFloat { .init(self) }

}



// MARK: UInt8

extension UInt8 : KvCGFloatCompatible {

    @inlinable
    public var isFinite: Bool { true }


    @inlinable
    public func cgFloat() -> CGFloat { .init(self) }

}



// MARK: UInt16

extension UInt16 : KvCGFloatCompatible {

    @inlinable
    public var isFinite: Bool { true }


    @inlinable
    public func cgFloat() -> CGFloat { .init(self) }

}



// MARK: UInt32

extension UInt32 : KvCGFloatCompatible {

    @inlinable
    public var isFinite: Bool { true }


    @inlinable
    public func cgFloat() -> CGFloat { .init(self) }

}



// MARK: UInt64

extension UInt64 : KvCGFloatCompatible {

    @inlinable
    public var isFinite: Bool { true }


    @inlinable
    public func cgFloat() -> CGFloat { .init(self) }

}



#endif // canImport(CoreGraphics)
