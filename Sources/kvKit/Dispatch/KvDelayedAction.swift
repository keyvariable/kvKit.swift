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
//  KvDelayedAction.swift
//  kvKit
//
//  Created by Svyatoslav Popov on 26.02.2020.
//

#if canImport(Darwin)

#if canImport(Combine)
import Combine
#endif //canImport(Combine)
import Foundation



/// Executes an action in future using specified scheduler. Instead of *Swift.Timer*, it can use any scheduler: *DispatchQueue*, *OperationQueue*, *RunLoop*.
@available(iOS 13.0, macOS 10.15, *)
public final class KvDelayedAction {

    public typealias Action = (KvDelayedAction) -> Void



    public let dispatchQueue: DispatchQueue


    public private(set) var fireDate: Date!

    /// Positive values couse the action to be repeaded.
    public private(set) var interval: TimeInterval = 0

    public private(set) var tolerance: TimeInterval = Defaults.tolerance


    public var isScheduled: Bool { mutationLock.withLock { _isScheduled } }

    public var isRepeated: Bool { mutationLock.withLock { _isRepeated } }



    public init(on dispatchQueue: DispatchQueue, action: @escaping Action) {
        self.action = action
        self.dispatchQueue = dispatchQueue
    }



    deinit {
        cancel()
    }



    private let action: Action


    private var token: AnyCancellable? {
        didSet { oldValue?.cancel() }
    }


    private let mutationLock = NSRecursiveLock()


    private var _isScheduled: Bool { token != nil }
    private var _isRepeated: Bool { interval > .ulpOfOne }

}



// MARK: Fabrics

@available(iOS 13.0, macOS 10.15, *)
extension KvDelayedAction {

    public static func scheduled(on fireDate: Date? = nil,
                                 interval: TimeInterval,
                                 tolerance: TimeInterval = Defaults.tolerance,
                                 dispatchQueue: DispatchQueue,
                                 action: @escaping Action) -> KvDelayedAction
    {
        let delayedAction = KvDelayedAction(on: dispatchQueue, action: action)

        delayedAction.schedule(on: fireDate, interval: interval, tolerance: tolerance)

        return delayedAction
    }



    @inlinable
    public static func scheduled(on fireDate: Date,
                                 tolerance: TimeInterval = Defaults.tolerance,
                                 dispatchQueue: DispatchQueue,
                                 action: @escaping Action) -> KvDelayedAction
    {
        scheduled(on: fireDate, interval: 0, tolerance: tolerance, dispatchQueue: dispatchQueue, action: action)
    }



    @inlinable
    public static func scheduled(after startInterval: TimeInterval,
                                 interval: TimeInterval = 0,
                                 tolerance: TimeInterval = Defaults.tolerance,
                                 dispatchQueue: DispatchQueue,
                                 action: @escaping Action) -> KvDelayedAction
    {
        scheduled(on: .init(timeIntervalSinceNow: startInterval), interval: interval, tolerance: tolerance, dispatchQueue: dispatchQueue, action: action)
    }

}



// MARK: Constants

@available(iOS 13.0, macOS 10.15, *)
extension KvDelayedAction {

    public struct Defaults {

        public static let tolerance: TimeInterval = 1e-2

    }

}



// MARK: Scheduling Actions

@available(iOS 13.0, macOS 10.15, *)
extension KvDelayedAction {

    public func cancel() {
        mutationLock.withLock(_cancel)
    }



    /// - Warning: mutationLock must be locked while this method is running.
    private func _cancel() {
        token = nil
    }



    /// Trigger the receiver immediately even if it has not been scheduled.
    ///
    /// - Note: Receivers being repeated are not cancelled.
    ///
    /// - Note: Receivers being repeated are rescheduled to trigger net time after *interval*.
    public func trigger() {
        mutationLock.withLock(rescheduleOnTrigger)

        dispatchQueue.schedule {
            self.action(self)
        }
    }



    /// Trigger the receiver immediately if it has been scheduled.
    ///
    /// - Note: Receivers being repeated are not cancelled.
    ///
    /// - Note: Receivers being repeated are rescheduled to trigger net time after *interval*.
    public func flush() {
        do {
            mutationLock.lock()
            defer { mutationLock.unlock() }

            guard _isScheduled else { return }

            rescheduleOnTrigger()
        }

        dispatchQueue.schedule {
            self.action(self)
        }
    }



    /// - Warning: mutationLock must be locked while this method is running.
    private func rescheduleOnTrigger() {
        guard _isRepeated else {
            return _cancel()
        }

        fireDate = Date(timeIntervalSinceNow: interval)

        reset()
    }



    public func schedule(on fireDate: Date? = nil, interval: TimeInterval, tolerance: TimeInterval = Defaults.tolerance,
                         options: ScheduleOptions = [ ])
    {
        mutationLock.withLock {
            do {
                var newFireDate = fireDate != nil
                    ? (fireDate!.timeIntervalSinceNow > tolerance ? fireDate! : .init(timeIntervalSinceNow: tolerance))
                    : .init(timeIntervalSinceNow: max(interval, tolerance))

                if let oldFireDate = self.fireDate, options.contains(.weak) {
                    newFireDate = min(newFireDate, oldFireDate)
                }

                self.fireDate = newFireDate
            }
            self.interval = interval
            self.tolerance = tolerance

            reset()
        }
    }



    @inlinable
    public func schedule(on fireDate: Date, tolerance: TimeInterval = Defaults.tolerance, options: ScheduleOptions = [ ]) {
        schedule(on: fireDate, interval: 0, tolerance: tolerance, options: options)
    }



    @inlinable
    public func schedule(after startInterval: TimeInterval, interval: TimeInterval = 0,
                         tolerance: TimeInterval = Defaults.tolerance, options: ScheduleOptions = [ ])
    {
        schedule(on: .init(timeIntervalSinceNow: startInterval), interval: interval, tolerance: tolerance, options: options)
    }



    /// - Warning: mutationLock must be locked while this method is running.
    private func reset() {
        let canceller = dispatchQueue.schedule(after: dispatchQueue.now.advanced(by: .seconds(fireDate.timeIntervalSinceNow)),
                                               interval: .seconds(isRepeated ? interval : 1e6),
                                               tolerance: .seconds(tolerance),
                                               options: nil,
                                               { self.fire() })

        token = .init { canceller.cancel() }
    }



    private func fire() {
        action(self)

        mutationLock.withLock {
            if _isScheduled, fireDate.timeIntervalSinceNow < tolerance {
                _isRepeated ? fireDate += interval : _cancel()
            }
        }
    }



    // MARK: .ScheduleOptions

    public struct ScheduleOptions : OptionSet {

        /// When this option is set and the action has fire date then the fire date becomes minimum of old and new fire dates. Otherwise this option takes no effect.
        /// The interval is replaced with new one.
        public static let weak = Self(rawValue: 1 << 0)


        // MARK: : OptionSet

        public let rawValue: UInt


        public init(rawValue: UInt) { self.rawValue = rawValue }

    }

}



// MARK: Concurrency

@available(iOS 13.0, macOS 10.15, *)
extension KvDelayedAction {

    /// Invokes *body* while the receiver is locked. *body* is passed with the receiver.
    ///
    /// - Returns: The value returned by *body*.
    public func locking<T>(_ body: (KvDelayedAction) throws -> T) rethrows -> T {
        try mutationLock.withLock {
            try body(self)
        }
    }

}

#endif // canImport(Darwin)
