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
//  KvCircularBuffer.swift
//  kvKit
//
//  Created by Svyatoslav Popov on 17.07.2018.
//

import Foundation



/// A FIFO buffer having fixed maximum length: new elements are inserted to the end, first element is droped when completely filled buffer is appended with an element.
public struct KvCircularBuffer<T> {

    public private(set) var items: ContiguousArray<T>

    public let capacity: Int



    public init(capacity: Int) {
        self.init(capacity: capacity, initialItems: .init())
    }


    public init(capacity: Int, with item: T) {
        self.init(capacity: capacity, initialItems: [ item ])
    }


    public init<S>(capacity: Int, with items: S) where S: Sequence, S.Element == T {
        self.init(capacity: capacity, initialItems: .init())

        items.forEach { append($0) }
    }


    public init(capacity: Int, repeating item: T) {
        self.init(capacity: capacity, initialItems: .init(repeating: item, count: capacity))
    }



    private init(capacity: Int, initialItems: ContiguousArray<T>) {
        assert(capacity > 0, "Internal inconsistency: circular buffer with \(capacity) capacity")
        assert(initialItems.count <= capacity, "Internal inconsistency: circular buffer having \(capacity) capacity is initialized with \(initialItems.count) items")

        self.capacity = capacity
        maximumIndex = capacity - 1

        items = initialItems
        items.reserveCapacity(capacity)

        nextIndex = items.count < capacity ? items.count : 0
    }


    private let maximumIndex: Int
    private var nextIndex: Int

}



// MARK: Access

extension KvCircularBuffer {

    public subscript (_ index: Int) -> T {
        guard items.count == capacity else { return items[index] }

        let shiftedIndex = index + nextIndex

        return items[shiftedIndex <= maximumIndex ? shiftedIndex : (shiftedIndex - capacity)]
    }



    @inlinable
    public var isEmpty: Bool { return items.isEmpty }

    @inlinable
    public var isFull: Bool { return items.count == capacity }


    @inlinable
    public var count: Int { return items.count }



    public var first: T? { return items.count == capacity ? items[nextIndex] : items.first }

    public var last: T? { return items.count == capacity ? items[(nextIndex > 0 ? nextIndex : capacity) - 1] : items.last }

}



// MARK: Mutation

extension KvCircularBuffer {

    @discardableResult
    public mutating func append(_ item: T) -> T? {
        let excluded: T?

        if nextIndex < items.count {
            excluded = items[nextIndex]
            items[nextIndex] = item

        } else {
            excluded = nil
            items.append(item)
        }

        nextIndex = nextIndex < maximumIndex ? nextIndex + 1 : 0

        return excluded
    }



    public mutating func removeAll() {
        items.removeAll(keepingCapacity: true)
        nextIndex = 0
    }

}



// MARK: Transforming

extension KvCircularBuffer {

    @inlinable
    public func reduce<Result>(_ initialResult: Result, _ nextPartialResult: (Result, Element) throws -> Result) rethrows -> Result {
        try items.reduce(initialResult, nextPartialResult)
    }



    @inlinable
    public func reduce<Result>(into initialResult: Result, _ updateAccumulatingResult: (inout Result, Element) throws -> ()) rethrows -> Result {
        try items.reduce(into: initialResult, updateAccumulatingResult)
    }

}



// MARK: : Sequence

extension KvCircularBuffer : Sequence {

    public struct Iterator: IteratorProtocol {

        private let items: ContiguousArray<T>

        private let maximumIndex: Int

        private var index: Int
        private var iterationCount = 0



        init(_ circularBuffer: KvCircularBuffer<T>) {
            items = circularBuffer.items

            maximumIndex = circularBuffer.maximumIndex

            index = items.count == circularBuffer.capacity ? circularBuffer.nextIndex : 0
        }



        // MARK: : IteratorProtocol

        public mutating func next() -> T? {
            guard iterationCount < items.count else { return nil }

            defer {
                iterationCount += 1
                index = index < maximumIndex ? index + 1 : 0
            }

            return items[index]
        }

    }



    public func makeIterator() -> Iterator { .init(self) }

}



// MARK: : Collection

extension KvCircularBuffer : Collection {

    public var startIndex: Int { return 0 }

    public var endIndex: Int { return count }



    public func index(after i: Int) -> Int { i + 1 }

}
