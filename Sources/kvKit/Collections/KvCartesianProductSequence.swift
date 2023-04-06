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
//  KvCartesianProductSequence.swift
//  kvKit
//
//  Created by Svyatoslav Popov on 03.10.2019.
//

import Foundation



/// A lazy implementation of cartesian product of two sequences.
///
/// - Note: Let Ls = \[ "a", "b" \] and Rs = \[ 1, 2, 3 \] then the result is \[ ("a", 1), ("a", 2), ("a", 3), ("b", 1), ("b", 2), ("b", 3) \].
public struct KvCartesianProductSequence<Ls, Rs>
    where Ls : Sequence, Rs : Sequence
{
    public typealias L = Ls.Element
    public typealias R = Rs.Element

    public typealias Element = (L, R)



    public init(_ left: Ls, _ right: Rs) {
        self.left = left
        self.right = right
    }



    private let left: Ls
    private let right: Rs

}



// MARK: : Sequence

extension KvCartesianProductSequence : Sequence {

    public struct Iterator : IteratorProtocol {

        init(_ left: Ls, _ right: Rs) {
            self.right = right

            lIterator = left.makeIterator()
            rIterator = right.makeIterator()

            l = lIterator.next()
            r = rIterator.next()
        }



        private let right: Rs

        private var lIterator: Ls.Iterator
        private var rIterator: Rs.Iterator

        private var l: L?
        private var r: R?



        // MARK: : IteratorProtocol

        public mutating func next() -> Element? {
            guard l != nil, r != nil else { return nil }

            defer {
                r = rIterator.next()

                if r == nil {
                    rIterator = right.makeIterator()

                    l = lIterator.next()
                    r = rIterator.next()
                }
            }

            return (l!, r!)
        }

    }



    public func makeIterator() -> Iterator { .init(left, right) }

}
