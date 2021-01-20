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
//  KvEventCenter.swift
//  kvKit
//
//  Created by Svyatoslav Popov on 08.11.2018.
//

import Foundation



public class KvEventCenter<Sender, Event> {

    public typealias Callback = (Sender, Event) -> Void

    public typealias Token = KvRAII.Token


    public typealias EmptyCallback = (KvEventCenter) -> Void



    public var isEmpty: Bool { tokenSet.isEmpty }


    public var emptyCallback: EmptyCallback? {
        didSet { tokenSet.emptyCallback = emptyCallback != nil ? { [weak self] _ in self?.emptyCallback?(self!) } : nil }
    }



    public init() { }



    private let tokenSet: KvRAII.TokenSet = .init()

}



// MARK: Emission of Events

extension KvEventCenter {

    public func post(_ event: Event, from sender: Sender) {
        tokenSet.forEach {
            ($0 as! ObservationToken).trigger(event, from: sender)
        }
    }



    /// - parameter eventProvider: It is passed with user data for each registered callback. Then returned value is passed to the callbacks.
    public func post(from sender: Sender, with eventProvider: (Any?) -> Event?) {
        tokenSet.forEach { (token) in
            guard let event = eventProvider(token.userData) else { return }

            (token as! ObservationToken).trigger(event, from: sender)
        }
    }

}



// MARK: Token Processing

extension KvEventCenter {

    public func newToken(with callback: @escaping Callback, userData: Any? = nil) -> Token {
        let token = ObservationToken(with: callback, userData)

        tokenSet.insert(token)

        return token
    }

}



// MARK: .ObservationToken

extension KvEventCenter {

    private class ObservationToken : Token {

        private let callback: Callback


        fileprivate init(with callback: @escaping Callback, _ userData: Any? = nil) {
            self.callback = callback

            super.init(releaseCallback: nil, userData: userData)
        }


        func trigger(_ event: Event, from sender: Sender) {
            callback(sender, event)
        }

    }

}
