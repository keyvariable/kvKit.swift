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
//  KvUserDefaultsKit.swift
//  kvKit
//
//  Created by Svyatoslav Popov on 21.09.2020.
//

import Foundation



// MARK: - KvUserDefaultWrapper

public protocol KvUserDefaultWrapper {

    typealias ObservationCallback = () -> Void


    var key: String { get }


    func observe(with callback: @escaping ObservationCallback) -> Any

}



// MARK: - @KvUserDefault

/// This property wrapper provides ability to interact with a value in stanard *UserDefaults* as a propetry and to observe for changes of the value.
/// When initial value is provided the value is registered in the *UserDefaults* as default.
///
/// ### Examples
///
/// * `@KvUserDefault(key: "count") var count: Int = 0`
/// * `@KvUserDefault(key: "timeInterval") var timeInterval: TimeInterval`
///
@propertyWrapper
public struct KvUserDefault<Value> : KvUserDefaultWrapper {

    public let key: String



    public init(key: String) {
        self.key = key
    }



    public init(wrappedValue: Value, key: String) {
        self.init(key: key)

        UserDefaults.standard.register(defaults: [ key : wrappedValue ])
    }



    // MARK: .wrappedValue

    @inlinable
    public var wrappedValue: Value {
        get { UserDefaults.standard.object(forKey: key) as! Value }
        set { UserDefaults.standard.set(newValue, forKey: key) }
    }



    // MARK: : KvUserDefaultWrapper

    /// - Returns: A RAII token for the observation.
    public func observe(with callback: @escaping ObservationCallback) -> Any {
        KvUserDefaultObservationToken(keyPath: key, callback: callback)
    }

}



// MARK: - KvUserDefaultObservationToken

fileprivate class KvUserDefaultObservationToken : NSObject {

    typealias Callback = KvUserDefaultWrapper.ObservationCallback


    init(keyPath: String, callback: @escaping Callback) {
        self.keyPath = keyPath
        self.callback = callback

        super.init()

        UserDefaults.standard.addObserver(self, forKeyPath: keyPath, options: [ ], context: nil)
    }


    deinit {
        UserDefaults.standard.removeObserver(self, forKeyPath: keyPath)
    }


    private let keyPath: String

    private let callback: Callback



    // MARK: KVO

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard keyPath == self.keyPath else { return }

        callback()
    }

}
