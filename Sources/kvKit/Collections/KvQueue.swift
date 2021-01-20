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
//  KvQueue.swift
//  kvKit
//
//  Created by Svyatoslav Popov on 23.02.2020.
//

import Foundation



/// A simple array based implementation of a queue.
public struct KvQueue<T> {

    public init() {
        values = .init()
    }



    public init<S>(_ elements: S) where S : Sequence, S.Element == Element {
        values = .init(elements)
    }



    public init(repeating value: Element, count: Int) {
        values = .init(repeating: value, count: count)
    }



    private var values: [T] = .init()

}



// MARK: : ExpressibleByArrayLiteral

extension KvQueue : ExpressibleByArrayLiteral {

    public init(arrayLiteral: Element...) {
        values = .init(arrayLiteral)
    }

}



// MARK: Mutation

extension KvQueue {

    public mutating func push(_ value: T) {
        values.append(value)
    }



    public mutating func push<Values>(_ values: Values) where Values : Sequence, Values.Element == T {
        self.values.append(contentsOf: values)
    }



    public mutating func pop() -> T? {
        !values.isEmpty ? values.removeFirst() : nil
    }



    public mutating func pop(_ count: Int, callback: (ArraySlice<T>) -> Void = { _ in }) {
        let n = Swift.min(count, values.count)

        callback(values[0 ..< n])

        values.removeFirst(n)
    }

}



// MARK: : Sequence

extension KvQueue : Sequence {

    public typealias Index = Int
    public typealias Element = T



    public func makeIterator() -> IndexingIterator<[T]> {
        values.makeIterator()
    }



    public func contains(where predicate: (T) throws -> Bool) rethrows -> Bool {
        try values.contains(where: predicate)
    }



    public func first(where predicate: (T) throws -> Bool) rethrows -> T? {
        try values.first(where: predicate)
    }



    public func min(by areInIncreasingOrder: (T, T) throws -> Bool) rethrows -> T? {
        try values.min(by: areInIncreasingOrder)
    }



    public func max(by areInIncreasingOrder: (T, T) throws -> Bool) rethrows -> T? {
        try values.max(by: areInIncreasingOrder)
    }



    public func compactMap<ElementOfResult>(_ transform: (T) throws -> ElementOfResult?) rethrows -> [ElementOfResult] {
        try values.compactMap(transform)
    }



    public func flatMap<SegmentOfResult>(_ transform: (T) throws -> SegmentOfResult) rethrows -> [SegmentOfResult.Element] where SegmentOfResult : Sequence {
        try values.flatMap(transform)
    }



    public func map<Result>(_ transform: (T) throws -> Result) rethrows -> [Result] {
        try values.map(transform)
    }



    public func reduce<Result>(_ initialResult: Result, _ nextPartialResult: (Result, T) throws -> Result) rethrows -> Result {
        try values.reduce(initialResult, nextPartialResult)
    }



    public func reduce<Result>(into initialResult: __owned Result, _ updateAccumulatingResult: (inout Result, T) throws -> ()) rethrows -> Result {
        try values.reduce(into: initialResult, updateAccumulatingResult)
    }

}



// MARK: Sequence where T : Comparable

extension KvQueue where T : Comparable {

    public func min() -> T? { values.min() }



    public func max() -> T? { values.max() }

}



// MARK: : Collection

extension KvQueue : Collection {

    public subscript(position: Index) -> T { values[position] }



    public var count: Int { values.count }

    public var startIndex: Index { values.startIndex }
    public var endIndex: Index { values.endIndex }


    public var first: T? { values.first }
    public var last: T? { values.last }


    public var isEmpty: Bool { values.isEmpty }



    public func index(after i: Index) -> Int { values.index(after: i) }



    public func formIndex(_ i: inout Index, offsetBy distance: Int) { values.formIndex(&i, offsetBy: distance) }

}



// MARK: : RandomAccessCollection

extension KvQueue : RandomAccessCollection { }



// MARK: : Equatable

extension KvQueue : Equatable where T : Equatable {

    public static func ==(lhs: KvQueue, rhs: KvQueue) -> Bool { lhs.values == rhs.values }



    public func contains(_ element: T) -> Bool { values.contains(element) }

}



// MARK: : Hashable

extension KvQueue : Hashable where T : Hashable {

    public func hash(into hasher: inout Hasher) { values.hash(into: &hasher) }

}
