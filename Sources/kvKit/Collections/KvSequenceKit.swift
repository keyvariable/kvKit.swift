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
//  KvSequenceKit.swift
//  kvKit
//
//  Created by Svyatoslav Popov on 26.10.2022.
//

/// Collection of auxiliaries for sequences.
///
/// See: ``KvArrayKit``, ``KvCollectionKit``
public struct KvSequenceKit { private init() { } }



// MARK: - Pairs of Elements

extension KvSequenceKit {

    /// E.g: [ 1, 2, 3 ] -> [ (1, 2), (2, 3) ]
    @inlinable
    public static func pairs<S : Sequence>(_ sequence: S) -> IteratorSequence<PairIterator<S>> {
        IteratorSequence(PairIterator(sequence))
    }


    /// E.g: [ 1, 2, 3 ] -> [ (1, 2), (2, 3), (3, 1) ]
    @inlinable
    public static func cyclicPairs<S : Sequence>(_ sequence: S) -> IteratorSequence<CyclicPairIterator<S>> {
        IteratorSequence(CyclicPairIterator(sequence))
    }


    /// Invokes *body* with each pair of subsequent elements from given sequence.
    ///
    /// E.g: [ 1, 2, 3 ] -> [ (1, 2), (2, 3) ]
    @inlinable
    public static func forEachPair<S : Sequence>(in sequence: S, _ body: (S.Element, S.Element) throws -> Void) rethrows {
        var iterator = sequence.makeIterator()

        guard var prev = iterator.next() else { return }

        while let next = iterator.next() {
            defer { prev = next }

            try body(prev, next)
        }
    }


    /// Invokes *body* with each pair of subsequent elements from given sequence threated as a cyclic sequence.
    ///
    /// E.g: [ 1, 2, 3 ] -> [ (1, 2), (2, 3), (3, 1) ]
    @inlinable
    public static func forEachCyclicPair<S : Sequence>(in sequence: S, _ body: (S.Element, S.Element) throws -> Void) rethrows {
        var iterator = sequence.makeIterator()

        guard let first = iterator.next(),
              var prev = iterator.next()
        else { return }

        try body(first, prev)

        while let next = iterator.next() {
            defer { prev = next }

            try body(prev, next)
        }

        try body(prev, first)
    }



    // MARK: .PairIterator

    /// Iterator of subsequent element pairs from given sequence.
    ///
    /// E.g: [ 1, 2, 3 ] -> [ (1, 2), (2, 3) ]
    public struct PairIterator<S : Sequence> : IteratorProtocol {

        @inlinable
        public init(_ sequence: S) {
            var underlying = sequence.makeIterator()

            switch underlying.next() {
            case .some(let first):
                nextBlock = PairIterator.regularState(first, &underlying)
            case .none:
                nextBlock = PairIterator.endState()
            }
        }


        @usableFromInline internal typealias NextBlock = (inout Self) -> Element?


        @usableFromInline internal var nextBlock: NextBlock


        // MARK: : IteratorProtocol

        public typealias Element = (S.Element, S.Element)


        @inlinable public mutating func next() -> Element? { nextBlock(&self) }


        // MARK: FSM

        @usableFromInline
        internal static func regularState(_ first: S.Element, _ underlying: inout S.Iterator) -> NextBlock {
            var last = first
            var underlying = underlying

            return { _self in
                guard let next = underlying.next() else {
                    _self.nextBlock = endState()
                    return nil
                }

                defer { last = next }

                return (last, next)
            }
        }


        @usableFromInline
        internal static func endState() -> NextBlock {
            { _ in nil }
        }

    }



    // MARK: .CyclicPairIterator

    /// Iterator of subsequent element pairs from given sequence threated as a cyclic sequence.
    ///
    /// E.g: [ 1, 2, 3 ] -> [ (1, 2), (2, 3), (3, 1) ]
    public struct CyclicPairIterator<S : Sequence> : IteratorProtocol {

        @inlinable
        public init(_ sequence: S) {
            var underlying = sequence.makeIterator()

            guard let first = underlying.next(),
                  let second = underlying.next()
            else {
                nextBlock = CyclicPairIterator.endState()
                return
            }

            nextBlock = CyclicPairIterator.firstPairState((first, second), &underlying)
        }


        @usableFromInline internal typealias NextBlock = (inout Self) -> Element?


        @usableFromInline internal var nextBlock: NextBlock


        // MARK: : IteratorProtocol

        public typealias Element = (S.Element, S.Element)


        @inlinable public mutating func next() -> Element? { nextBlock(&self) }


        // MARK: FSM

        @usableFromInline
        internal static func firstPairState(_ first: Element, _ underlying: inout S.Iterator) -> NextBlock {
            var underlying = underlying

            return { _self in
                _self.nextBlock = nextPairState(first, &underlying)

                return first
            }
        }


        @usableFromInline
        internal static func nextPairState(_ first: Element, _ underlying: inout S.Iterator) -> NextBlock {
            var last = first.1
            var underlying = underlying

            return { _self in
                guard let next = underlying.next() else {
                    _self.nextBlock = endState()
                    return (last, first.0)
                }

                defer { last = next }

                return (last, next)
            }
        }


        @usableFromInline
        internal static func endState() -> NextBlock {
            { _ in nil }
        }

    }

}



// MARK: - Repeated Patterns

extension KvSequenceKit {

    /// - Returns: Sequence containing given *pattern* sequence repeated infinite times.
    @inlinable
    public static func repeating<S : Sequence>(_ pattern: S) -> IteratorSequence<PatternIterator<S>> {
        IteratorSequence(PatternIterator(pattern))
    }

    /// - Returns: Sequence containing given *pattern* sequence repeated *count* times.
    @inlinable
    public static func repeating<S : Sequence>(_ pattern: S, count: Int) -> IteratorSequence<PatternIterator<S>> {
        IteratorSequence(PatternIterator(pattern, count: count))
    }

    /// - Returns: Sequence of first *maxLength* elements if given repeated *pattern* sequence.
    @inlinable
    public static func repeating<S : Sequence>(_ pattern: S, maxLength: Int) -> PrefixSequence<IteratorSequence<PatternIterator<S>>> {
        PrefixSequence(IteratorSequence(PatternIterator(pattern)), maxLength: maxLength)
    }

    /// - Returns: Sequence of up to *maxLength* elements if given sequence containing *pattern* repeated *count* times..
    @inlinable
    public static func repeating<S : Sequence>(_ pattern: S, count: Int, maxLength: Int) -> PrefixSequence<IteratorSequence<PatternIterator<S>>> {
        PrefixSequence(IteratorSequence(PatternIterator(pattern, count: count)), maxLength: maxLength)
    }



    // MARK: .PatternIterator

    /// Repeates given pattern sequence.
    ///
    /// E.g.: [ 1, 2 ] -> [ 1, 2, 1, 2, 1, 2, ... ]
    public struct PatternIterator<S : Sequence> : IteratorProtocol {

        /// Given pattern is repeated infinite times.
        @inlinable
        public init(_ pattern: S) {
            nextBlock = PatternIterator.infiniteState(pattern)
        }


        /// Given pattern is repeated given number of times.
        @inlinable
        public init(_ pattern: S, count: Int) {
            nextBlock = PatternIterator.limitedState(pattern, count: count)
        }


        @usableFromInline internal typealias NextBlock = (inout Self) -> Element?


        @usableFromInline internal var nextBlock: NextBlock


        // MARK: : IteratorProtocol

        @inlinable public mutating func next() -> S.Element? { nextBlock(&self) }


        // MARK: FSM

        @usableFromInline
        internal static func infiniteState(_ pattern: S) -> NextBlock {
            var underlying = pattern.makeIterator()

            return { _self in
                switch underlying.next() {
                case .some(let element):
                    return element

                case .none:
                    underlying = pattern.makeIterator()

                    switch underlying.next() {
                    case .some(let element):
                        return element

                    case .none:
                        _self.nextBlock = endState()
                        return nil
                    }
                }
            }
        }


        @usableFromInline
        internal static func limitedState(_ pattern: S, count: Int) -> NextBlock {
            guard count > 0
            else { return endState() }

            var repeatLimit = count
            var underlying = pattern.makeIterator()

            return { _self in
                switch underlying.next() {
                case .some(let element):
                    return element

                case .none:
                    repeatLimit -= 1
                    guard repeatLimit > 0 else {
                        _self.nextBlock = endState()
                        return nil
                    }

                    underlying = pattern.makeIterator()

                    switch underlying.next() {
                    case .some(let element):
                        return element

                    case .none:
                        _self.nextBlock = endState()
                        return nil
                    }
                }
            }
        }


        @usableFromInline
        internal static func endState() -> NextBlock {
            { _ in nil }
        }

    }

}



// MARK: - Uniform Filtering

extension KvSequenceKit {

    /// - Returns: Sequence with elements of input sequence having offsets equal to *offset* + *n* · *step* where *n* ≥ 0.
    @inlinable
    public static func filtered<S : Sequence>(_ sequence: S, each step: Int, startingAt offset: Int = 0) -> IteratorSequence<UniformFilterIterator<S>> {
        IteratorSequence(UniformFilterIterator(sequence, each: step, startingAt: offset))
    }



    // MARK: .UniformFilterIterator

    /// Drops given number of leading elemtns and emits elements having offset equal to a multiple of given step.
    public struct UniformFilterIterator<S : Sequence> : IteratorProtocol {

        @inlinable
        public init(_ sequence: S, each step: Int, startingAt offset: Int = 0) {
            assert(step > 1)
            assert(offset >= 0)

            self.skipCount = step - 1
            self.iterator = sequence.makeIterator()

            var offset = offset
            while offset > 0, iterator.next() != nil {
                offset -= 1
            }
        }


        @usableFromInline internal var iterator: S.Iterator

        @usableFromInline internal let skipCount: Int


        // MARK: : IteratorProtocol

        @inlinable
        public mutating func next() -> S.Element? {
            defer {
                var count = skipCount
                while count > 0, iterator.next() != nil {
                    count -= 1
                }
            }

            return iterator.next()
        }

    }

}
