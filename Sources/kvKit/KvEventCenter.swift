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
//  KvEventCenter.swift
//  kvKit
//
//  Created by Svyatoslav Popov on 08.11.2018.
//

import Foundation



public class KvEventCenter<Sender, Event> {

    public typealias Callback = (Sender, Event) -> Void

    public typealias Token = KvRAII.Token<Void>


    public typealias EmptyCallback = (KvEventCenter) -> Void



    public var isEmpty: Bool { entries.isEmpty }


    public var emptyCallback: EmptyCallback?



    public init() { }



    private var entries: [Entry] = .init() {
        didSet {
            if isEmpty, !oldValue.isEmpty {
                emptyCallback?(self)
            }
        }
    }

}



// MARK: Emission of Events

extension KvEventCenter {

    public func post(_ event: Event, from sender: Sender) {
        entries.forEach { entry in
            entry.callback(sender, event)
        }
    }



    /// - parameter eventProvider: It is passed with user data for each registered callback. Then returned value is passed to the callbacks.
    public func post(from sender: Sender, with eventProvider: (Any?) -> Event?) {
        entries.forEach { entry in
            guard let event = eventProvider(entry.userData) else { return }

            entry.callback(sender, event)
        }
    }

}



// MARK: Token Processing

extension KvEventCenter {

    public func newToken(with callback: @escaping Callback, userData: Any? = nil) -> Token {
        let entry = Entry(callback, userData: userData)

        entries.append(entry)

        return Token { [weak self] _ in
            guard let _self = self,
                  let index = _self.entries.firstIndex(of: entry)
            else { return }

            _self.entries.remove(at: index)
        }
    }

}



// MARK: .Entry

extension KvEventCenter {

    private class Entry : Equatable {

        let callback: Callback
        let userData: Any?


        init(_ callback: @escaping Callback, userData: Any?) {
            self.callback = callback
            self.userData = userData
        }


        // MARK: : Equatable

        static func ==(lhs: Entry, rhs: Entry) -> Bool { lhs === rhs }

    }

}
