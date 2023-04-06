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


    public var defaults: UserDefaults { _defaults ?? .standard }



    public init(key: String, in defaults: UserDefaults? = nil) {
        self.key = key
        self._defaults = defaults
    }



    public init(wrappedValue: Value, key: String, in defaults: UserDefaults? = nil) {
        self.init(key: key, in: defaults)

        self.defaults.register(defaults: [ key : wrappedValue ])
    }



    private let _defaults: UserDefaults?



    // MARK: .wrappedValue

    @inlinable
    public var wrappedValue: Value {
        get { defaults.object(forKey: key) as! Value }
        set {
            switch newValue as Any {
            case Optional<Any>.none:
                defaults.removeObject(forKey: key)
            default:
                defaults.set(newValue, forKey: key)
            }
        }
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


    init(_ defaults: UserDefaults? = nil, keyPath: String, callback: @escaping Callback) {
        self._defaults = defaults
        self.keyPath = keyPath
        self.callback = callback

        super.init()

        self.defaults.addObserver(self, forKeyPath: keyPath, options: [ ], context: nil)
    }


    deinit {
        defaults.removeObserver(self, forKeyPath: keyPath)
    }


    private var defaults: UserDefaults { _defaults ?? .standard }

    private let _defaults: UserDefaults?
    private let keyPath: String

    private let callback: Callback



    // MARK: KVO

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard keyPath == self.keyPath else { return }

        callback()
    }

}
