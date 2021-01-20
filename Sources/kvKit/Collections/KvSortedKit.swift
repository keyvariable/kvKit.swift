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
//  KvSortedKit.swift
//  kvKit
//
//  Created by Svyatoslav Popov on 16.06.18.
//

import Foundation



/// A set of auxiliary methods to manage standard collections as sorted in ascending order.
public class KvSortedKit {

    public typealias LessPredicate<T> = (_ lhs: T, _ rhs: T) -> Bool


    /// Inserts *value* in *collection* at appropriate index preserving ascending order.
    ///
    /// - Parameter by: A less relation predicate.
    ///
    /// - Returns: Index the item has been inserted at.
    @discardableResult
    public static func insert<T, C>(_ value: T, inSorted collection: inout C, by isLess: LessPredicate<T>) -> C.Index
    where C : BidirectionalCollection & RangeReplaceableCollection, C.Element == T, C.Index : BinaryInteger
    {
        let indexToInsert = index(for: value, inSorted: collection, by: isLess)
        collection.insert(value, at: indexToInsert)

        return indexToInsert
    }



    /// Inserts *value* in *collection* at appropriate index preserving ascending order.
    ///
    /// - Returns: Index the item has been inserted at.
    @discardableResult @inlinable
    public static func insert<T, C>(_ value: T, inSorted collection: inout C) -> C.Index
    where T : Comparable, C : BidirectionalCollection & RangeReplaceableCollection, C.Element == T, C.Index : BinaryInteger
    {
        insert(value, inSorted: &collection, by: <)
    }



    /// - Parameter isLess: A less relation predicate.
    ///
    /// - Returns: An index where *value* have to be inserted preserving ascending order of the collection.
    ///
    /// - Note: If there is an item equal to given one at some index then the index is returned.
    public static func index<T, C>(for value: T, inSorted collection: C, by isLess: LessPredicate<T>) -> C.Index
    where C : BidirectionalCollection, C.Element == T, C.Index : BinaryInteger
    {
        guard collection.count > 1 else {
            let firstItem = collection.first
            return firstItem != nil && isLess(firstItem!, value) ? collection.endIndex : collection.startIndex
        }

        guard isLess(collection.first!, value) else { return collection.startIndex }
        guard isLess(value, collection.last!) else {
            return isLess(collection.last!, value) ? collection.endIndex : (collection.endIndex - 1)
        }


        var lIndex = collection.startIndex
        var rIndex = collection.endIndex - 1

        while lIndex + 1 < rIndex {
            let mIndex = (lIndex & rIndex) + ((lIndex ^ rIndex) >> 1)       // Overflow-safe equivalent for `(lIndex + rIndex) >> 1` where indices are nonnegative.
            let mItem = collection[mIndex]

            if isLess(mItem, value) {
                lIndex = mIndex
            } else if isLess(value, mItem) {
                rIndex = mIndex
            } else {
                return mIndex
            }
        }

        return rIndex
    }



    /// - Returns: An index where *value* have to be inserted preserving ascending order of the collection.
    ///
    /// - Note: If there is an item equal to given one at some index then the index is returned.
    @inlinable
    public static func index<T, C>(for value: T, inSorted collection: C) -> C.Index
    where T : Comparable, C : BidirectionalCollection, C.Element == T, C.Index : BinaryInteger
    {
        index(for: value, inSorted: collection, by: <)
    }



    /// - Parameter isLess: A less relation predicate.
    ///
    /// - Returns: An index range where corresponding collection items persist to *valueRange*. Any collection item outside resulting index range is out of *valueRange*.
    public static func indexRange<T, C>(for valueRange: Range<T>, inSorted collection: C, by isLess: LessPredicate<T>) -> Range<C.Index>
    where C : BidirectionalCollection, C.Element == T, C.Index : BinaryInteger
    {
        var startIndex = index(for: valueRange.lowerBound, inSorted: collection, by: isLess)
        while startIndex > collection.startIndex, !isLess(collection[startIndex - 1], valueRange.lowerBound) {
            startIndex -= 1
        }

        var endIndex = index(for: valueRange.upperBound, inSorted: collection, by: isLess)
        while endIndex > startIndex, !isLess(collection[endIndex - 1], valueRange.upperBound) {
            endIndex -= 1
        }

        return startIndex ..< endIndex
    }



    /// - Returns: An index range where corresponding collection items persist to *valueRange*. Any collection item outside resulting index range is out of *valueRange*.
    @inlinable
    public static func indexRange<T, C>(for valueRange: Range<T>, inSorted collection: C) -> Range<C.Index>
    where T : Comparable, C : BidirectionalCollection, C.Element == T, C.Index : BinaryInteger
    {
        indexRange(for: valueRange, inSorted: collection, by: <)
    }



    /// - Parameter isLess: A less relation predicate.
    ///
    /// - Returns: An index range where corresponding collection items persist to *valueRange*. Any collection item outside resulting index range is out of *valueRange*.
    public static func indexRange<T, C>(for valueRange: ClosedRange<T>, inSorted collection: C, by isLess: LessPredicate<T>) -> Range<C.Index>
    where C : BidirectionalCollection, C.Element == T, C.Index : BinaryInteger
    {
        var startIndex = index(for: valueRange.lowerBound, inSorted: collection, by: isLess)
        while startIndex > collection.startIndex, !isLess(collection[startIndex - 1], valueRange.lowerBound) {
            startIndex -= 1
        }

        var endIndex = index(for: valueRange.upperBound, inSorted: collection, by: isLess)
        while endIndex < collection.endIndex, !isLess(valueRange.upperBound, collection[endIndex]) {
            endIndex += 1
        }

        return startIndex ..< endIndex
    }



    /// - Returns: An index range where corresponding collection items persist to *valueRange*. Any collection item outside resulting index range is out of *valueRange*.
    @inlinable
    public static func indexRange<T, C>(for valueRange: ClosedRange<T>, inSorted collection: C) -> Range<C.Index>
    where T : Comparable, C : BidirectionalCollection, C.Element == T, C.Index : BinaryInteger
    {
        indexRange(for: valueRange, inSorted: collection, by: <)
    }



    /// - Parameter isLess: A less relation predicate.
    ///
    /// - Returns: An index range where corresponding collection items persist to *valueRange*. Any collection item outside resulting index range is out of *valueRange*.
    public static func indexRange<T, C>(for valueRange: PartialRangeFrom<T>, inSorted collection: C, by isLess: LessPredicate<T>) -> Range<C.Index>
    where C : BidirectionalCollection, C.Element == T, C.Index : BinaryInteger
    {
        var startIndex = index(for: valueRange.lowerBound, inSorted: collection, by: isLess)
        while startIndex > collection.startIndex, !isLess(collection[startIndex - 1], valueRange.lowerBound) {
            startIndex -= 1
        }

        return startIndex ..< collection.endIndex
    }



    /// - Returns: An index range where corresponding collection items persist to *valueRange*. Any collection item outside resulting index range is out of *valueRange*.
    @inlinable
    public static func indexRange<T, C>(for valueRange: PartialRangeFrom<T>, inSorted collection: C) -> Range<C.Index>
    where T : Comparable, C : BidirectionalCollection, C.Element == T, C.Index : BinaryInteger
    {
        indexRange(for: valueRange, inSorted: collection, by: <)
    }



    /// - Parameter isLess: A less relation predicate.
    ///
    /// - Returns: An index range where corresponding collection items persist to *valueRange*. Any collection item outside resulting index range is out of *valueRange*.
    public static func indexRange<T, C>(for valueRange: PartialRangeUpTo<T>, inSorted collection: C, by isLess: LessPredicate<T>) -> Range<C.Index>
    where C : BidirectionalCollection, C.Element == T, C.Index : BinaryInteger
    {
        var endIndex = index(for: valueRange.upperBound, inSorted: collection, by: isLess)
        while endIndex > collection.startIndex, !isLess(collection[endIndex - 1], valueRange.upperBound) {
            endIndex -= 1
        }

        return collection.startIndex ..< endIndex
    }



    /// - Returns: An index range where corresponding collection items persist to *valueRange*. Any collection item outside resulting index range is out of *valueRange*.
    @inlinable
    public static func indexRange<T, C>(for valueRange: PartialRangeUpTo<T>, inSorted collection: C) -> Range<C.Index>
    where T : Comparable, C : BidirectionalCollection, C.Element == T, C.Index : BinaryInteger
    {
        indexRange(for: valueRange, inSorted: collection, by: <)
    }



    /// - Parameter isLess: A less relation predicate.
    ///
    /// - Returns: An index range where corresponding collection items persist to *valueRange*. Any collection item outside resulting index range is out of *valueRange*.
    public static func indexRange<T, C>(for valueRange: PartialRangeThrough<T>, inSorted collection: C, by isLess: LessPredicate<T>) -> Range<C.Index>
    where C : BidirectionalCollection, C.Element == T, C.Index : BinaryInteger
    {
        var endIndex = index(for: valueRange.upperBound, inSorted: collection, by: isLess)
        while endIndex < collection.endIndex, !isLess(valueRange.upperBound, collection[endIndex]) {
            endIndex += 1
        }

        return collection.startIndex ..< endIndex
    }



    /// - Returns: An index range where corresponding collection items persist to *valueRange*. Any collection item outside resulting index range is out of *valueRange*.
    @inlinable
    public static func indexRange<T, C>(for valueRange: PartialRangeThrough<T>, inSorted collection: C) -> Range<C.Index>
    where T : Comparable, C : BidirectionalCollection, C.Element == T, C.Index : BinaryInteger
    {
        indexRange(for: valueRange, inSorted: collection, by: <)
    }



    /// - Parameter isLess: A less relation predicate.
    ///
    /// - Returns: An index range where collection items equal to *value* are located at. Any collection item outside resulting index range is not equa to *value*.
    ///
    /// - Note: This method is faster then range version. There is no need to use this method when *collection* doesn't contain equal elements.
    public static func indexRange<T, C>(for value: T, inSorted collection: C, by isLess: LessPredicate<T>) -> Range<C.Index>
    where C : BidirectionalCollection, C.Element == T, C.Index : BinaryInteger
    {
        var startIndex = index(for: value, inSorted: collection, by: isLess)
        var endIndex = startIndex

        while startIndex > collection.startIndex, !isLess(collection[startIndex - 1], value) {
            startIndex -= 1
        }
        while endIndex < collection.endIndex, !isLess(value, collection[endIndex]) {
            endIndex += 1
        }

        return startIndex ..< endIndex
    }



    /// - Returns: An index range where collection items equal to *value* are located at. Any collection item outside resulting index range is not equa to *value*.
    ///
    /// - Note: This method is faster then range version. There is no need to use this method when *collection* doesn't contain equal elements.
    @inlinable
    public static func indexRange<T, C>(for value: T, inSorted collection: C) -> Range<C.Index>
    where T : Comparable, C : BidirectionalCollection, C.Element == T, C.Index : BinaryInteger
    {
        indexRange(for: value, inSorted: collection, by: <)
    }



    /// - Parameter isLess: A less relation predicate.
    ///
    /// - Returns: An index where *item* is located at in *collection* or `nil`.
    public static func index<T, C>(of value: T, inSorted collection: C, by isLess: LessPredicate<T>) -> C.Index?
    where C : BidirectionalCollection, C.Element == T, C.Index : BinaryInteger
    {
        let firstItem = collection.first

        guard collection.count > 1 else {
            return firstItem != nil && !isLess(firstItem!, value) && !isLess(value, firstItem!) ? collection.startIndex : nil
        }


        if isLess(value, firstItem!) {
            return nil
        } else if !isLess(firstItem!, value) {
            return 0
        }


        let lastItem = collection.last!

        if isLess(lastItem, value) {
            return nil
        } else if !isLess(value, lastItem) {
            return collection.endIndex - 1
        }


        var lIndex = collection.startIndex
        var rIndex = collection.endIndex - 1

        while lIndex + 1 < rIndex {
            let mIndex = (lIndex & rIndex) + ((lIndex ^ rIndex) >> 1)       // Overflow-safe equivalent for `(lIndex + rIndex) >> 1` where indices are nonnegative.

            if isLess(collection[mIndex], value) {
                lIndex = mIndex
            } else if isLess(value, collection[mIndex]) {
                rIndex = mIndex
            } else {
                return mIndex
            }
        }

        return nil
    }



    /// - Returns: An index where *item* is located at in *collection* or `nil`.
    @inlinable
    public static func index<T, C>(of value: T, inSorted collection: C) -> C.Index?
    where T : Comparable, C : BidirectionalCollection, C.Element == T, C.Index : BinaryInteger
    {
        index(of: value, inSorted: collection, by: <)
    }



    /// - Parameter isLess: A less relation predicate.
    ///
    /// - Returns: A boolean value indicating whether *collection* contains *item* using binary search.
    @inlinable
    public static func isItem<C, T>(_ item: T, containedInSorted collection: C, by isLess: LessPredicate<T>) -> Bool
    where C : BidirectionalCollection, C.Element == T, C.Index : BinaryInteger
    {
        index(of: item, inSorted: collection, by: isLess) != nil
    }


    /// - Returns: A boolean value indicating whether *collection* contains *item* using binary search.
    @inlinable
    public static func isItem<C, T>(_ item: T, containedInSorted collection: C) -> Bool
    where T : Comparable, C : BidirectionalCollection, C.Element == T, C.Index : BinaryInteger
    {
        isItem(item, containedInSorted: collection, by: <)
    }



    /// - Parameter isLess: A less relation predicate.
    ///
    /// - Returns: A boolean value indicating whether order of items in *collection* are in increasing or  non-decreasing order depending on *options* argument.
    public static func isSorted<C, T>(_ collection: C, options: SortCheckOptions = .noOptions, by isLess: LessPredicate<T>) -> Bool
    where C : BidirectionalCollection, C.Element == T, C.Index : BinaryInteger
    {
        guard collection.count > 1 else { return true }

        var prevItem = collection.first!

        if options.contains(.strictIncreasing) {
            for item in collection[(collection.startIndex + 1) ..< collection.endIndex] {
                guard isLess(prevItem, item) else { return false }

                prevItem = item
            }

        } else {
            for item in collection[(collection.startIndex + 1) ..< collection.endIndex] {
                guard !isLess(item, prevItem) else { return false }

                prevItem = item
            }
        }

        return true
    }



    /// - Returns: A boolean value indicating whether order of items in *collection* are in increasing or  non-decreasing order depending on *options* argument.
    @inlinable
    public static func isSorted<C, T>(_ collection: C, options: SortCheckOptions = .noOptions) -> Bool
    where T : Comparable, C : BidirectionalCollection, C.Element == T, C.Index : BinaryInteger
    {
        isSorted(collection, by: <)
    }



    // MARK: .SortCheckOptions

    public struct SortCheckOptions : OptionSet {

        public static let noOptions = SortCheckOptions([])

        /// It's guarateed that collection doesn't contain equal elements.
        public static let strictIncreasing = SortCheckOptions(rawValue: 1 << 0)


        // MARK: : OptionSet

        public let rawValue: UInt


        public init(rawValue: UInt) { self.rawValue = rawValue }

    }

}



// MARK: Merging

extension KvSortedKit {

    /// Compares *left* and *right* sorted sequences and invokes *callback* for items from *left* but not from *right*, items from *right* but not from *left*, pairs of equal items from *left* and *right*.
    ///
    /// - Parameter isLess: A less relation predicate.
    public static func diff<SL, SR, T>(left: SL, right: SR, by isLess: LessPredicate<T>, callback: (DiffResponse<T>) -> Void)
    where SL : Sequence, SL.Element == T, SR : Sequence, SR.Element == T
    {
        var leftIterator = left.makeIterator()
        var leftItem = leftIterator.next()

        var rightIterator = right.makeIterator()
        var rightItem = rightIterator.next()


        while leftItem != nil, rightItem != nil {
            if isLess(leftItem!, rightItem!) {
                callback(.left(leftItem!))
                leftItem = leftIterator.next()

            } else if isLess(rightItem!, leftItem!) {
                callback(.right(rightItem!))
                rightItem = rightIterator.next()

            } else {
                callback(.equal(left: leftItem!, right: rightItem!))
                leftItem = leftIterator.next()
                rightItem = rightIterator.next()
            }
        }

        while rightItem != nil {
            callback(.right(rightItem!))
            rightItem = rightIterator.next()
        }

        while leftItem != nil {
            callback(.left(leftItem!))
            leftItem = leftIterator.next()
        }
    }



    /// Compares *left* and *right* sorted sequences and invokes *callback* for items from *left* but not from *right*, items from *right* but not from *left*, pairs of equal items from *left* and *right*.
    @inlinable
    public static func diff<SL, SR, T>(left: SL, right: SR, callback: (DiffResponse<T>) -> Void)
    where T : Comparable, SL: Sequence, SL.Element == T, SR: Sequence, SR.Element == T
    {
        diff(left: left, right: right, by: <, callback: callback)
    }



    /// Inserts elements from sorted *src* into sorted *dest* preserving order.
    ///
    /// - Parameter options: if *strictIncreasing* options is set then *src* and *dest* are threated as strictly increasing sequences and strictly increasing order is preserved.
    /// - Parameter isLess: A less relation predicate.
    public static func merge<S, D, T>(_ src: S, into dest: inout D, options: MergeOptions = .noOptions, sortedBy isLess: LessPredicate<T>)
    where D : BidirectionalCollection & RangeReplaceableCollection, D.Element == T, D.Index : BinaryInteger,
          S : BidirectionalCollection, S.Element == T, S.Index == D.Index
    {
        var srcIndex = src.startIndex
        var destIndex = dest.startIndex


        func ProcessEqualSubsequences(_ isLess: (T, T) -> Bool) {
            let value = dest[destIndex]

            while srcIndex < src.endIndex, !isLess(value, src[srcIndex]) {
                srcIndex += 1
            }
            while destIndex < dest.endIndex, !isLess(value, dest[destIndex]) {
                destIndex += 1
            }
        }


        if options.contains(.strictIncreasing) {
            func InsertSrcSubsequence(_ isLess: (T, T) -> Bool) {
                let maxValue = dest[destIndex]

                guard isLess(src[srcIndex], maxValue) else { return }

                let rangeToInsert = srcIndex ..< index(for: maxValue, inSorted: src[srcIndex...], by: isLess)
                let distance = rangeToInsert.upperBound - rangeToInsert.lowerBound

                dest.insert(contentsOf: src[rangeToInsert], at: destIndex)

                destIndex += distance
                srcIndex = distance
            }


            while srcIndex < src.endIndex {
                guard destIndex < dest.endIndex else {
                    dest.append(contentsOf: src[srcIndex...])
                    break
                }

                guard !isLess(dest.last!, src.first!) else {
                    dest.append(contentsOf: src[srcIndex...])
                    break
                }
                guard !isLess(src.last!, dest.first!) else {
                    dest.insert(contentsOf: src[srcIndex...], at: 0)
                    break
                }

                InsertSrcSubsequence(isLess)
                ProcessEqualSubsequences(isLess)
            }

        } else {

            func InsertSrcSubsequence(_ isLess: (T, T) -> Bool) {
                let maxValue = dest[destIndex]

                guard !isLess(maxValue, src[srcIndex]) else { return }

                var endIndex = index(for: maxValue, inSorted: src[srcIndex...], by: isLess)

                while endIndex < src.endIndex, !isLess(maxValue, src[endIndex]) {
                    endIndex += 1
                }

                let rangeToInsert = srcIndex ..< endIndex
                let distance = rangeToInsert.upperBound - rangeToInsert.lowerBound

                dest.insert(contentsOf: src[rangeToInsert], at: destIndex)

                destIndex += distance
                srcIndex = distance
            }


            while srcIndex < src.endIndex {
                guard destIndex < dest.endIndex else {
                    dest.append(contentsOf: src[srcIndex...])
                    break
                }

                guard isLess(src.first!, dest.last!) else {
                    dest.append(contentsOf: src[srcIndex...])
                    break
                }
                guard isLess(dest.first!, src.last!) else {
                    dest.insert(contentsOf: src[srcIndex...], at: 0)
                    break
                }

                InsertSrcSubsequence(isLess)
                ProcessEqualSubsequences(isLess)
            }
        }
    }



    /// Inserts elements from sorted *src* into sorted *dest* preserving order.
    ///
    /// - Parameter options: if *strictIncreasing* options is set then *src* and *dest* are threated as strictly increasing sequences and strictly increasing order is preserved.
    @inlinable
    public static func merge<S, D, T>(_ src: S, into dest: inout D, options: MergeOptions = .noOptions)
    where T : Comparable,
          D : BidirectionalCollection & RangeReplaceableCollection, D.Element == T, D.Index : BinaryInteger,
          S : BidirectionalCollection, S.Element == T, S.Index == D.Index
    {
        merge(src, into: &dest, options: options, sortedBy: <)
    }



    /// Invokes *body* for each element being in common for all of *sources*. Arguments of *body* invokations are sorted by *isLess*.
    ///
    /// - Parameter isLess: A less relation predicate.
    public static func forEachCommonElement<CS, T>(inSorted sources: CS, by isLess: LessPredicate<T>, body: (T) -> Void)
    where CS : Collection, CS.Element : Sequence, CS.Element.Element == T
    {
        switch sources.count {
        case 0:
            return /* Nothing to iterate */

        case 1:
            return sources.first!.forEach(body)

        default:
            break
        }


        var iterators = sources.map { $0.makeIterator() }

        guard var maximum = iterators[0].next() else { return /* First sequence is empty */ }

        var count = 1
        var iteratorIndex = 1

        repeat {
            guard let next = iterators[iteratorIndex].next() else { return /* One of sources has reached the end */ }

            guard !isLess(next, maximum) else { continue }

            if isLess(maximum, next) {
                maximum = next
                count = 1

            } else {
                count += 1

                if count == iterators.count {
                    body(maximum)

                    count = 0
                }
            }

            iteratorIndex += 1
            if iteratorIndex == iterators.count {
                iteratorIndex = 0
            }

        } while true
    }



    /// Invokes *body* for each element being in common for all of *sources*. Arguments of *body* invokations are sorted by *isLess*.
    ///
    /// - Parameter isLess: A less relation predicate.
    @inlinable
    public static func forEachCommonElement<S, T>(inSorted sources: S..., by isLess: LessPredicate<T>, body: (T) -> Void)
    where S : Sequence, S.Element == T
    {
        forEachCommonElement(inSorted: sources, by: isLess, body: body)
    }



    /// Invokes *body* for each element being in common for all of *sources*. Arguments of *body* invokations are sorted by *isLess*.
    @inlinable
    public static func forEachCommonElement<S, T>(inSorted sources: S..., body: (T) -> Void)
    where T : Comparable, S : Sequence, S.Element == T
    {
        forEachCommonElement(inSorted: sources, by: <, body: body)
    }


    /// Let *U*  is a distinct sorted union of all sequences from *sources*. This method compares each sequence in *sources* and *U* and invokes *callback* for each offset where corresponding element from U is missing at.
    ///
    /// - Parameter isLess: A less relation predicate.
    /// - Parameter callback: A functor having `(_ valueOffset: Int, _ sourceOffset: Int)` signature.
    public static func forEachMissingIndex<T, Sources>(inSorted sources: Sources, by isLess: LessPredicate<T>, callback: (_ valueOffset: Int, _ sourceOffset: Int) -> Void)
    where Sources : Sequence, Sources.Element : Sequence, Sources.Element.Element == T
    {
        var iterators: [Sources.Element.Iterator] = .init()
        var values: [T?] = .init()
        var valueOffsets: [Int] = .init()

        var nextValue: T?

        sources.forEach {
            var iterator = $0.makeIterator()
            let value = iterator.next()

            iterators.append(iterator)
            values.append(value)
            valueOffsets.append(0)

            if nextValue == nil || (value != nil && isLess(value!, nextValue!)) {
                nextValue = value
            }
        }


        let n = values.count

        while nextValue != nil {
            var minValue: T?

            (0 ..< n).forEach { i in
                var value = values[i]

                if value == nil || isLess(nextValue!, value!) {
                    callback(valueOffsets[i], i)

                } else {
                    value = iterators[i].next()
                    valueOffsets[i] += 1

                    values[i] = value
                }


                if minValue == nil || (value != nil && isLess(value!, minValue!)) {
                    minValue = value
                }
            }

            nextValue = minValue
        }
    }



    /// Let *U*  is a distinct sorted union of all sequences from *sources*. This method compares each sequence in *sources* and *U* and invokes *callback* for each offset where corresponding element from U is missing at.
    ///
    /// - Parameter callback: A functor having `(_ valueOffset: Int, _ sourceOffset: Int)` signature.
    @inlinable
    public static func forEachMissingIndex<T, Sources>(inSorted sources: Sources, callback: (_ valueOffset: Int, _ sourceOffset: Int) -> Void)
    where T : Comparable, Sources : Sequence, Sources.Element : Sequence, Sources.Element.Element == T
    {
        forEachMissingIndex(inSorted: sources, by: <, callback: callback)
    }



    // MARK: .DiffResponse

    public enum DiffResponse<T> {
        case left(T), right(T), equal(left: T, right: T)
    }



    // MARK: .MergeOptions

    public struct MergeOptions : OptionSet {

        public static let noOptions = MergeOptions([])

        /// if *strictIncreasing* is set then *src* and *dest* arguments of *merge()* method are threated as strictly increasing sequences and the result is in strictly increasing order.
        public static let strictIncreasing = MergeOptions(rawValue: 1 << 0)


        // MARK: : OptionSet

        public let rawValue: UInt


        public init(rawValue: UInt) { self.rawValue = rawValue }

    }



    // MARK: .UnionWithSourceFlagsIterator

    /// Iterator of union of multiple sorted sources providing array of flags the elements have taken at.
    ///
    /// Example. Let two sources: \[ 1, 3 \], \[ 2, 3, 4 \]. Then the result is an iterator of following sequence: \[ (1, \[ *true*, *false* \]), (2, \[ *false*, *true* \]), (3, \[ *true*, *true* \]), (4, \[ *false*, *true* \]) \]
    public struct UnionWithSourceFlagsIterator<T> : IteratorProtocol {

        /// - Parameter sources: A sequence of sorted sequences.
        ///
        /// - Parameter isLess: A less relation predicate.
        public init<Sources>(forSorted sources: Sources, by isLess: @escaping LessPredicate<T>) where Sources : Sequence, Sources.Element : Sequence, Sources.Element.Element == T {
            self.isLess = isLess

            var iterators: [AnyIterator<T>] = .init()
            var values: [T?] = .init()
            var valueOffsets: [Int] = .init()
            var nextValue: T?

            sources.forEach { source in
                var iterator = source.makeIterator()
                let value = iterator.next()

                iterators.append(.init(iterator))
                values.append(value)
                valueOffsets.append(0)

                if nextValue == nil || (value != nil && isLess(value!, nextValue!)) {
                    nextValue = value
                }
            }

            self.iterators = iterators
            self.values = values
            self.valueOffsets = valueOffsets
            self.nextValue = nextValue
            self.flags = .init(repeating: false, count: values.count)
        }



        private let isLess: LessPredicate<T>

        private var iterators: [AnyIterator<T>]
        private var values: [T?]
        private var valueOffsets: [Int]

        private var nextValue: T?
        private var flags: [Bool]



        // MARK: : IteratorProtocol

        public mutating func next() -> (T, [Bool])? {
            guard let nextValue = nextValue else { return nil }

            var minValue: T?

            defer { self.nextValue = minValue }

            (0 ..< values.count).forEach { i in
                var value = values[i]

                if value == nil || isLess(nextValue, value!) {
                    flags[i] = false

                } else {
                    flags[i] = true

                    value = iterators[i].next()
                    valueOffsets[i] += 1

                    values[i] = value
                }


                if minValue == nil || (value != nil && isLess(value!, minValue!)) {
                    minValue = value
                }
            }

            return (nextValue, flags)
        }

    }

}
