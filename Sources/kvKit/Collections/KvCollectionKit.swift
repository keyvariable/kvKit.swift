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
//  KvCollectionKit.swift
//  kvKit
//
//  Created by Svyatoslav Popov on 26.10.2022.
//

/// Collection of auxiliaries for collections.
///
/// See: ``KvArrayKit``, ``KvSequenceKit``
public struct KvCollectionKit { private init() { } }



// MARK: - Cyclic Shift

extension KvCollectionKit {

    /// E.g. [ 1, 2 , 3, ...] -> [  3, ..., 1, 2 ].
    @inlinable
    public static func cyclicShiftedLeft<C : Collection>(_ collection: C, by shift: Int = 1) -> IteratorSequence<CyclicShiftIterator<C>> {
        IteratorSequence(CyclicShiftIterator(collection, leftBy: shift))
    }


    /// E.g. [ 1, 2 , 3, ..., n–1, n] -> [ n–1, n, 1, 2, 3, ... ].
    @inlinable
    public static func cyclicShiftedRight<C : Collection>(_ collection: C, by shift: Int = 1) -> IteratorSequence<CyclicShiftIterator<C>> {
        IteratorSequence(CyclicShiftIterator(collection, rightBy: shift))
    }



    // MARK: .CyclicShiftIterator

    /// E.g. [ 1, 2 , 3, ...] -> [  3, ..., 1, 2 ] or [ 1, 2 , 3, ..., n–1, n] -> [ n–1, n, 1, 2, 3, ... ].
    public struct CyclicShiftIterator<C : Collection> : IteratorProtocol {

        /// Unsafe left shift initializer.
        @usableFromInline
        internal init(_ collection: C, by shift: Int) {
            var underlying1 = collection.dropFirst(shift).makeIterator()
            var underlying2 = collection.prefix(shift).makeIterator()

            nextBlock = CyclicShiftIterator.firstState(&underlying1, &underlying2)
        }


        /// No shift initializer.
        @usableFromInline
        internal init(_ collection: C) {
            var iterator = collection.makeIterator()

            nextBlock = CyclicShiftIterator.secondState(&iterator)
        }


        /// E.g. [ 1, 2 , 3, ...] -> [  3, ..., 1, 2 ]
        @inlinable
        public init(_ collection: C, leftBy shift: Int = 1) {
            guard shift > 0, shift < collection.count else {
#if DEBUG
                if collection.count > 1 {
                    print("Unexpected cyclic left shift \(shift) for collection of \(collection.count) elements. No shift has been applied")
                }
#endif // DEBUG

                self.init(collection)
                return
            }

            self.init(collection, by: shift)
        }


        /// E.g. [ 1, 2 , 3, ..., n–1, n] -> [ n–1, n, 1, 2, 3, ... ].
        @inlinable
        public init(_ collection: C, rightBy shift: Int) {
            guard shift > 0, shift < collection.count else {
#if DEBUG
                if collection.count > 1 {
                    print("Unexpected cyclic right shift \(shift) for collection of \(collection.count) elements. No shift has been applied")
                }
#endif // DEBUG

                self.init(collection)
                return
            }

            self.init(collection, by: collection.count - shift)
        }


        @usableFromInline internal typealias NextBlock = (inout Self) -> Element?


        @usableFromInline internal var nextBlock: NextBlock


        // MARK: : IteratorProtocol

        @inlinable public mutating func next() -> C.Element? { nextBlock(&self) }


        // MARK: FSM

        @usableFromInline
        internal static func firstState<I1, I2>(_ underlying: inout I1, _ underlying2: inout I2) -> NextBlock
        where I1 : IteratorProtocol, I1.Element == C.Element, I2 : IteratorProtocol, I2.Element == C.Element {
            var u1 = underlying, u2 = underlying2

            return { _self in
                guard let next = u1.next() else {
                    _self.nextBlock = secondState(&u2)
                    return _self.nextBlock(&_self)
                }

                return next
            }
        }


        @usableFromInline
        internal static func secondState<I>(_ underlying: inout I) -> NextBlock
        where I : IteratorProtocol, I.Element == C.Element
        {
            var underlying = underlying

            return { _ in underlying.next() }
        }

    }

}
