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
//  KvArrayKit.swift
//  kvKit
//
//  Created by Svyatoslav Popov on 09.10.2022.
//

/// Collection of auxiliaries for arrays.
///
/// See: ``KvCollectionKit``, ``KvSequenceKit``
public struct KvArrayKit { private init() { } }



// MARK: - Mutation

extension KvArrayKit {

    /// Invokes *body* with mutable references to each element of given array.
    @inlinable
    public static func mutate<T>(_ array: inout [T], _ body: (inout T) throws -> Void) rethrows {
        try array.indices.forEach { index in
            try body(&array[index])
        }
    }


    /// Invokes *body* with mutable references to each element of given array. If *body* returns *false* then the element is removed from the array.
    @inlinable
    public static func mutateAndFilter<T>(_ array: inout [T], _ predicate: (inout T) throws -> Bool) rethrows {
        var iterator = array.indices.makeIterator()

        while let index = iterator.next() {
            guard try predicate(&array[index]) else {
                var end = index

                while let index = iterator.next() {
                    var element = array[index]

                    if try predicate(&element) {
                        array[end] = element
                        end += 1
                    }
                }

                array.removeLast(array.endIndex - end)

                break
            }
        }
    }

}
