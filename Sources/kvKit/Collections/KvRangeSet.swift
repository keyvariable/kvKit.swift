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
//  KvRangeSet.swift
//  kvKit
//
//  Created by Svyatoslav Popov on 16.11.2020.
//

import Foundation



public struct KvRangeSet<Bound : Comparable> {

    public typealias Element = Range<Bound>
    public typealias Elements = [Element]



    /// Array of nonoverlapping ranges ordered by ascendence.
    public private(set) var ranges: Elements = .init()

}



// MARK: Searching

extension KvRangeSet {

    /// - Returns: Index of first element intersecting with *range*.
    @inlinable
    public func firstIndex(in range: PartialRangeFrom<Bound>) -> Index {
        ranges.endIndex - KvSortedKit.index(for: range.lowerBound, inSorted: ranges.lazy.reversed().map { $0.upperBound }, by: >)
    }

}



// MARK: Mutation

extension KvRangeSet {

    public mutating func insert(_ range: Element) {
        guard !range.isEmpty else { return }

        let startIndex = KvSortedKit.index(for: range.lowerBound, inSorted: ranges.lazy.map { $0.upperBound }, by: <)

        guard startIndex < ranges.endIndex else {
            return ranges.append(range)
        }

        let startRange = ranges[startIndex]

        if range.upperBound < startRange.lowerBound {
            return ranges.insert(range, at: startIndex)

        } else if range.upperBound == startRange.lowerBound {
            ranges[startIndex] = range.lowerBound ..< startRange.upperBound
            return
        }

        let lowerBound = Swift.min(range.lowerBound, startRange.lowerBound)

        let endIndex = KvSortedKit.index(for: range.upperBound, inSorted: ranges.lazy.map { $0.upperBound }, by: <)

        guard endIndex < ranges.endIndex else {
            return ranges.replaceSubrange(startIndex..., with: CollectionOfOne(lowerBound ..< range.upperBound))
        }

        let endRange = ranges[endIndex]

        range.upperBound < endRange.lowerBound
            ? ranges.replaceSubrange(startIndex ..< endIndex, with: CollectionOfOne(lowerBound ..< range.upperBound))
            : ranges.replaceSubrange(startIndex ... endIndex, with: CollectionOfOne(lowerBound ..< endRange.upperBound))
    }



    public mutating func remove(_ range: Element) {
        guard !range.isEmpty else { return }

        var startIndex = KvSortedKit.index(for: range.lowerBound, inSorted: ranges.lazy.map { $0.upperBound }, by: <)

        guard startIndex < ranges.endIndex else { return }

        let startRange = ranges[startIndex]

        guard range.upperBound > startRange.lowerBound else { return }

        switch (range.upperBound < startRange.upperBound, startRange.lowerBound < range.lowerBound) {
        case (false, false):
            break

        case (false, true):
            ranges[startIndex] = startRange.lowerBound ..< range.lowerBound
            startIndex += 1     // Element at startIndex won't be deleted later.

        case (true, false):
            ranges[startIndex] = range.upperBound ..< startRange.upperBound
            return

        case (true, true):
            ranges[startIndex] = startRange.lowerBound ..< range.lowerBound
            ranges.insert(range.upperBound ..< startRange.upperBound, at: startIndex + 1)
            return
        }

        let endIndex = KvSortedKit.index(for: range.upperBound, inSorted: ranges.lazy.map { $0.upperBound }, by: <)

        guard endIndex < ranges.endIndex else {
            return ranges.removeSubrange(startIndex...)
        }

        let endRange = ranges[endIndex]

        guard range.upperBound < endRange.upperBound else {
            return ranges.removeSubrange(startIndex ... endIndex)
        }

        if endRange.lowerBound < range.upperBound {
            ranges[endIndex] = range.upperBound ..< endRange.upperBound
        }

        ranges.removeSubrange(startIndex ..< endIndex)
    }



    public mutating func removeAll() { ranges.removeAll() }



    public mutating func removeAll(keepingCapacity: Bool) { ranges.removeAll(keepingCapacity: keepingCapacity) }



    public mutating func intersect(with range: Element) {
        guard !range.isEmpty else {
            return removeAll()
        }

        intersect(with: range.lowerBound...)
        intersect(with: ..<range.upperBound)
    }



    public mutating func intersect(with range: PartialRangeFrom<Bound>) {
        guard let startRange = first else { return }
        guard range.lowerBound > startRange.lowerBound else { return }

        guard range.lowerBound >= startRange.upperBound else {
            ranges[startIndex] = range.lowerBound ..< startRange.upperBound
            return
        }

        let endIndex = KvSortedKit.index(for: range.lowerBound, inSorted: ranges.lazy.map { $0.upperBound }, by: <)

        guard endIndex < ranges.endIndex else {
            return ranges.removeAll()
        }

        let endRange = ranges[endIndex]

        guard range.lowerBound < endRange.upperBound else {
            return ranges.removeSubrange(...endIndex)
        }

        if endRange.lowerBound < range.lowerBound {
            ranges[endIndex] = range.lowerBound ..< endRange.upperBound
        }

        ranges.removeSubrange(..<endIndex)
    }



    public mutating func intersect(with range: PartialRangeUpTo<Bound>) {
        let startIndex = KvSortedKit.index(for: range.upperBound, inSorted: ranges.lazy.map { $0.upperBound }, by: <)

        guard startIndex < ranges.endIndex else { return }

        let startRangeLowerBound = ranges[startIndex].lowerBound

        switch startRangeLowerBound < range.upperBound {
        case false:
            ranges.removeSubrange(startIndex...)

        case true:
            ranges[startIndex] = startRangeLowerBound ..< range.upperBound
            ranges.removeSubrange((startIndex + 1)...)
        }
    }

}



// MARK: : Sequence

extension KvRangeSet : Sequence {

    @inlinable
    public func makeIterator() -> Elements.Iterator { ranges.makeIterator() }

}



// MARK: : RandomAccessCollection

extension KvRangeSet : RandomAccessCollection {

    public typealias Index = Elements.Index



    @inlinable
    public var isEmpty: Bool { ranges.isEmpty }

    @inlinable
    public var startIndex: Index { ranges.startIndex }
    @inlinable
    public var endIndex: Index { ranges.endIndex }

    @inlinable
    public var first: Element? { ranges.first }
    @inlinable
    public var last: Element? { ranges.last }



    @inlinable
    public subscript(position: Index) -> Element { ranges[position] }

}



// MARK: : Equatable

extension KvRangeSet : Equatable {

    @inlinable
    public static func ==(lhs: Self, rhs: Self) -> Bool { lhs.ranges == rhs.ranges }

}



// MARK: : Hashable

extension KvRangeSet : Hashable where Bound : Hashable {

    @inlinable
    public func hash(into hasher: inout Hasher) { hasher.combine(ranges) }

}
