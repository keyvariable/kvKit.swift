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
//  KvBinaryTreeNode.swift
//  kvKit
//
//  Created by Svyatoslav Popov on 11.04.2019.
//

import Foundation



/// A binary tree.
///
/// - Note: A tree is equivalent to it's root node. So the type is named *KvBinaryTreeNode*.
open class KvBinaryTreeNode<T> : CustomStringConvertible {

    public var payload: T

    public private(set) weak var parent: KvBinaryTreeNode? = nil
    public private(set) var left: KvBinaryTreeNode? = nil
    public private(set) var right: KvBinaryTreeNode? = nil



    public init(with payload: T) {
        self.payload = payload
    }



    // MARK: Mutation

    @discardableResult
    open func updateLeft(_ node: KvBinaryTreeNode?) -> KvBinaryTreeNode? {
        let oldLeft = left

        oldLeft?.parent = nil

        left = node

        if let node = node {
            node.removeFromSupernode()
            node.parent = self
        }

        return oldLeft
    }



    @discardableResult
    open func updateRight(_ node: KvBinaryTreeNode?) -> KvBinaryTreeNode? {
        let oldRight = right

        oldRight?.parent = nil

        right = node

        if let node = node {
            node.removeFromSupernode()
            node.parent = self
        }

        return oldRight
    }



    open func removeFromSupernode() {
        guard let parent = parent else { return }

        if parent.left === self {
            parent.left = nil
        } else if parent.right === self {
            parent.right = nil
        } else {
            fatalError("Internal inconsistency: \(self) having a parent reference to \(parent) is not it's child")
        }

        self.parent = nil
    }



    // MARK: : CustomStringConvertible

    open var description: String { return "KvBinaryTreeNode(payload: \(payload))" }

}
