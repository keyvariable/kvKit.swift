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
//  KvRangeKit.swift
//  kvKit
//
//  Created by Svyatoslav Popov on 14.04.2019.
//

import Foundation



/// A collection of auxiliary methods for managing ranges.
public class KvRangeKit { }



// MARK: Expansion

extension KvRangeKit {

    @inlinable
    public static func expanding<T: Numeric>(_ range: Range<T>, for delta: T) -> Range<T> {
        (range.lowerBound - delta) ..< (range.upperBound + delta)
    }



    @inlinable
    public static func expanding<T: Numeric>(_ range: ClosedRange<T>, for delta: T) -> ClosedRange<T> {
        (range.lowerBound - delta) ... (range.upperBound + delta)
    }

}



// MARK: Union Operation

extension KvRangeKit {

    @inlinable
    public static func unioning<T>(_ lhs: Range<T>, _ rhs: Range<T>) -> Range<T> {
        min(lhs.lowerBound, rhs.lowerBound) ..< max(lhs.upperBound, rhs.upperBound)
    }



    @inlinable
    public static func unioning<T>(_ first: Range<T>, _ second: Range<T>, _ others: Range<T>...) -> Range<T> {
        others.reduce(unioning(first, second), unioning)
    }



    @inlinable
    public static func unioning<T>(_ lhs: Range<T>?, _ rhs: Range<T>?) -> Range<T>? {
        switch (lhs, rhs) {
        case (.some, .some):
            return unioning(lhs!, rhs!)
        case (.some, .none):
            return lhs
        case (.none, .some):
            return rhs
        case (.none, .none):
            return nil
        }
    }



    @inlinable
    public static func unioning<T>(_ first: Range<T>?, _ second: Range<T>?, _ others: Range<T>?...) -> Range<T>? {
        others.reduce(unioning(first, second), unioning)
    }



    @inlinable
    public static func unioning<T>(_ lhs: ClosedRange<T>, _ rhs: ClosedRange<T>) -> ClosedRange<T> {
        min(lhs.lowerBound, rhs.lowerBound) ... max(lhs.upperBound, rhs.upperBound)
    }



    @inlinable
    public static func unioning<T>(_ first: ClosedRange<T>, _ second: ClosedRange<T>, _ others: ClosedRange<T>...) -> ClosedRange<T> {
        others.reduce(unioning(first, second), unioning)
    }



    @inlinable
    public static func unioning<T>(_ lhs: ClosedRange<T>?, _ rhs: ClosedRange<T>?) -> ClosedRange<T>? {
        switch (lhs, rhs) {
        case (.some, .some):
            return unioning(lhs!, rhs!)
        case (.some, .none):
            return lhs
        case (.none, .some):
            return rhs
        case (.none, .none):
            return nil
        }
    }



    @inlinable
    public static func unioning<T>(_ first: ClosedRange<T>?, _ second: ClosedRange<T>?, _ others: ClosedRange<T>?...) -> ClosedRange<T>? {
        others.reduce(unioning(first, second), unioning)
    }



    @inlinable
    public static func unioning<T: BinaryInteger>(_ range: Range<T>, _ value: T) -> Range<T> {
        min(value, range.lowerBound) ..< max(value + 1, range.upperBound)
    }



    @inlinable
    public static func unioning<T: BinaryInteger>(_ range: Range<T>?, _ value: T) -> Range<T>? {
        range != nil ? unioning(range!, value) : (value ..< (value + 1))
    }



    @inlinable
    public static func unioning<T>(_ range: ClosedRange<T>, _ value: T) -> ClosedRange<T> {
        min(value, range.lowerBound) ... max(value, range.upperBound)
    }



    @inlinable
    public static func unioning<T>(_ range: ClosedRange<T>?, _ value: T) -> ClosedRange<T>? {
        range != nil ? unioning(range!, value) : (value ... value)
    }

}



// MARK: Bounding Ranges

extension KvRangeKit {

    @inlinable
    public static func bounding<S>(_ values: S) -> Range<S.Element>? where S : Sequence, S.Element : BinaryInteger {
        var iterator = values.makeIterator()

        guard let first = iterator.next() else { return nil }

        return IteratorSequence(iterator).reduce(first ..< (first + 1), unioning)
    }



    @inlinable
    public static func bounding<S>(_ values: S) -> ClosedRange<S.Element>? where S : Sequence {
        var iterator = values.makeIterator()

        guard let first = iterator.next() else { return nil }

        return IteratorSequence(iterator).reduce(first ... first, unioning)
    }

}



// MARK: Shifting Ranges

extension KvRangeKit {

    @inlinable
    public static func shifted<T>(_ range: Range<T>, for offset: T) -> Range<T> where T: AdditiveArithmetic & Comparable {
        (range.lowerBound + offset) ..< (range.upperBound + offset)
    }



    @inlinable
    public static func shifted<T>(_ range: ClosedRange<T>, for offset: T) -> ClosedRange<T> where T: AdditiveArithmetic & Comparable {
        (range.lowerBound + offset) ... (range.upperBound + offset)
    }



    @inlinable
    public static func shifted<T>(_ range: PartialRangeFrom<T>, for offset: T) -> PartialRangeFrom<T> where T: AdditiveArithmetic & Comparable {
        (range.lowerBound + offset)...
    }



    @inlinable
    public static func shifted<T>(_ range: PartialRangeUpTo<T>, for offset: T) -> PartialRangeUpTo<T> where T: AdditiveArithmetic & Comparable {
        ..<(range.upperBound + offset)
    }



    @inlinable
    public static func shifted<T>(_ range: PartialRangeThrough<T>, for offset: T) -> PartialRangeThrough<T> where T: AdditiveArithmetic & Comparable {
        ...(range.upperBound + offset)
    }

}
