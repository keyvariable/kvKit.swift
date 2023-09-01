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
//  KvStatistics.swift
//  kvKit
//
//  Created by Svyatoslav Popov on 08.06.2019.
//

import Foundation



// MARK: - KvStatisticsStream

public protocol KvStatisticsStream {

    associatedtype SourceValue


    mutating func process(_ value: SourceValue)
    mutating func process<S>(_ values: S) where S : Sequence, S.Element == SourceValue

    mutating func reset()

}



// MARK: - KvStatisticsProcessor

public protocol KvStatisticsProcessor : KvStatisticsStream {

    mutating func rollback(_ value: SourceValue)
    mutating func rollback<S>(_ values: S) where S : Sequence, S.Element == SourceValue

    mutating func replace(_ oldValue: SourceValue, with newValue: SourceValue)
    mutating func replace<S>(_ oldValues: S, with newValues: S) where S : Sequence, S.Element == SourceValue

}



// MARK: - KvStatistics

/// Various statistics auxiliaries.
public class KvStatistics { }



// MARK: - KvStatisticsAverageStream

public protocol KvStatisticsAverageStream : KvStatisticsStream {

    associatedtype Result


    var average: Result { get }


    func nextAverage(for value: SourceValue) -> Result

}



// MARK: - KvStatisticsAverageProcessor

public protocol KvStatisticsAverageProcessor : KvStatisticsAverageStream, KvStatisticsProcessor { }



// MARK: - .Average

extension KvStatistics {

    /// Simple average.
    public class Average<Value : BinaryFloatingPoint> {

        // MARK: .Processor

        /// Simple average online algorithm that is less prone to loss of precision due to catastrophic cancellation.
        public struct Processor : KvStatisticsAverageProcessor {

            @inlinable
            public var average: Value { _average }

            @inlinable
            public var count: Int { _count }

            @inlinable
            public var count⁻¹: Value { _count⁻¹ }


            @usableFromInline
            internal private(set) var _average: Value = 0.0 as Value

            @usableFromInline
            internal private(set) var _count: Int = 0 {
                didSet { _count⁻¹ = _count != 0 ? ((1.0 as Value) / Value(_count)) : (0.0 as Value) }
            }

            @usableFromInline
            internal private(set) var _count⁻¹: Value = 0.0 as Value



            /// Creates an instance in initial state.
            @inlinable
            public init() { }


            /// Creates an instance that has processed given *values*.
            @inlinable
            public init<S>(with values: S) where S : Sequence, S.Element == Value { process(values) }


            // TODO: Delete in 6.0.0.
            @available(*, deprecated, renamed: "init(with:)")
            public init<S>(_ values: S) where S : Sequence, S.Element == Value { self.init(with: values) }



            // MARK: : KvStatisticsAverageStream

            /// - Returns: The result as if given *value* had been processed.
            @inlinable
            public func nextAverage(for value: Value) -> Value { _average + ((value - _average) as Value) / Value(_count + 1) }



            // MARK: : KvStatisticsStream

            @inlinable
            public mutating func process(_ value: Value) {
                _count += 1
                _average.addProduct(value - _average, _count⁻¹)
            }


            @inlinable
            public mutating func process<S>(_ values: S) where S : Sequence, S.Element == Value {
                values.forEach { process($0) }
            }


            @inlinable
            public mutating func process<C>(_ values: C) where C : Collection, C.Element == Value {
                _count += values.count

                _average = values.reduce(_average, { $0.addingProduct($1 - _average, _count⁻¹) })
            }


            @inlinable
            public mutating func reset() {
                _average = 0.0 as Value
                _count = 0
            }



            // MARK: : KvStatisticsProcessor

            @inlinable
            public mutating func rollback(_ value: Value) {
                _count -= 1
                _average.addProduct(_average - value, _count⁻¹)
            }


            @inlinable
            public mutating func rollback<S>(_ values: S) where S : Sequence, S.Element == SourceValue {
                values.forEach { rollback($0) }
            }


            @inlinable
            public mutating func rollback<C>(_ values: C) where C : Collection, C.Element == SourceValue {
                _count -= values.count

                _average = values.reduce(_average, { $0.addingProduct(_average - $1, _count⁻¹) })
            }


            @inlinable
            public mutating func replace(_ oldValue: Value, with newValue: Value) {
                _average.addProduct(newValue - oldValue, _count⁻¹)
            }


            @inlinable
            public mutating func replace<S>(_ oldValues: S, with newValues: S) where S : Sequence, S.Element == SourceValue {
                var oldIterator = oldValues.makeIterator(), newIterator = newValues.makeIterator()

                while let oldValue = oldIterator.next(), let newValue = newIterator.next() {
                    replace(oldValue, with: newValue)
                }
            }

        }



        // MARK: .MovingStream

        /// Simple moving average online algorithm that is less prone to loss of precision due to catastrophic cancellation.
        ///
        /// A(n) = (a_(n-l+1) + ... + a_n) / l; A(n+1) = (a_(n-l+2) + ... + a_(n+1)) / l, where l is the limit, n >= l.
        public struct MovingStream : KvStatisticsAverageStream {

            @inlinable
            public var average: Value { _average }

            @inlinable
            public var buffer: KvCircularBuffer<Value> { _buffer }


            @inlinable
            public var count: Int { return _buffer.count }
            @inlinable
            public var capacity: Int { return _buffer.capacity }


            public let invCapacity: Value


            @usableFromInline
            internal private(set) var _average: Value = 0.0 as Value

            @usableFromInline
            internal private(set) var _buffer: KvCircularBuffer<Value>



            /// Creates an instance in initial state.
            @inlinable
            public init(capacity: Int) {
                _buffer = .init(capacity: capacity)

                invCapacity = (1.0 as Value) / Value(capacity)
            }


            /// Creates an instance that has processed given *values*.
            @inlinable
            public init<S>(capacity: Int, with values: S) where S : Sequence, S.Element == Value {
                self.init(capacity: capacity)
                process(values)
            }


            // TODO: Delete in 6.0.0.
            @available(*, deprecated, renamed: "init(capacity:with:)")
            public init<S>(capacity: Int, _ values: S) where S : Sequence, S.Element == Value {
                self.init(capacity: capacity, with: values)
            }



            // MARK: : KvStatisticsAverageStream

            /// - Returns: The result as if given *value* had been processed.
            @inlinable
            public func nextAverage(for value: Value) -> Value {
                count < capacity ? (_average + ((value - _average) as Value) / Value(count + 1)) : _average.addingProduct(value - _buffer.first!, invCapacity)
            }



            // MARK: KvStatisticsStream Protocol

            @inlinable
            public mutating func process(_ value: Value) {
                if let excludedValue = _buffer.append(value) {
                    _average.addProduct(value - excludedValue, invCapacity)
                } else {
                    _average += ((value - _average) as Value) / Value(_buffer.count)
                }
            }


            @inlinable
            public mutating func process<S>(_ values: S) where S : Sequence, S.Element == Value {
                values.forEach { process($0) }
            }


            @inlinable
            public mutating func process<C>(_ values: C) where C : Collection, C.Element == Value {
                guard values.count < _buffer.capacity else {
                    _average = values[values.index(values.endIndex, offsetBy: -_buffer.capacity)...].reduce(0, { $0.addingProduct($1, invCapacity) })
                    return
                }

                let k = _buffer.capacity - _buffer.count
                let m = values.count - k

                let index = m > 0 ? values.index(values.startIndex, offsetBy: k) : values.endIndex

                if k > 0 {
                    _average = values[..<index].reduce(_average, { $0.addingProduct($1 - _average, invCapacity) })
                }

                if m > 0 {
                    var iterator = _buffer.makeIterator()

                    _average = values[index...].reduce(_average, { $0.addingProduct($1 - iterator.next()!, invCapacity) })
                }
            }


            @inlinable
            public mutating func reset() {
                _average = 0.0 as Value
                _buffer.removeAll()
            }
        }

    }

}



// MARK: - .WeightedMean

extension KvStatistics {

    /// Weighted mean.
    public class WeightedMean<Value : BinaryFloatingPoint> {

        // MARK: .MovingStream

        /// Weighted moving average online algorithm that is less prone to loss of precision due to catastrophic cancellation.
        public struct MovingStream : KvStatisticsAverageStream {

            public let weights: [Value]

            @inlinable
            public var buffer: KvCircularBuffer<Value> { _buffer }

            @inlinable
            public var average: Value { zip(_buffer, weights).reduce(0.0 as Value, { $0.addingProduct($1.0, $1.1) }) }


            @inlinable
            public var count: Int { return _buffer.count }

            @inlinable
            public var capacity: Int { return weights.count }


            @usableFromInline
            internal private(set) var _buffer: KvCircularBuffer<Value>



            /// Creates an instance in initial state.
            @inlinable
            public init<Weights>(weights: Weights) where Weights : Sequence, Weights.Element == Value {
                let scale: Value = {
                    let totalWeight = weights.reduce(0.0 as Value, +)

                    return abs(totalWeight) >= Value.ulpOfOne ? ((1.0 as Value) / totalWeight) : 0.0 as Value
                }()

                self.weights = weights.map { $0 * scale }   // Normalization of weights.

                _buffer = .init(capacity: self.weights.count)
            }


            /// Creates an instance that has processed given *values*.
            @inlinable
            public init<Weights, S>(weights: Weights, with values: S)
            where Weights : Sequence, Weights.Element == Value,
                  S : Sequence, S.Element == Value
            {
                self.init(weights: weights)
                process(values)
            }



            // MARK: : KvStatisticsAverageStream

            /// - Returns: The result as if given *value* had been processed.
            @inlinable
            public func nextAverage(for value: Value) -> Value {
                var valueIterator = _buffer.makeIterator()
                var weightIterator = weights.makeIterator()

                _ = valueIterator.next()    // Skip first value

                let sum: Value = (0..<(capacity - 1)).reduce(0.0 as Value, { (result, _) in
                    result.addingProduct(weightIterator.next() ?? 0.0, valueIterator.next()!)
                })

                return sum + (weightIterator.next() ?? 0.0) * value
            }



            // MARK: : KvStatisticsStream

            @inlinable
            public mutating func process(_ value: Value) {
                _buffer.append(value)
            }


            @inlinable
            public mutating func process<S>(_ values: S) where S : Sequence, S.Element == Value {
                values.forEach { process($0) }
            }


            @inlinable
            public mutating func process<C>(_ values: C) where C : Collection, C.Element == Value {
                values.forEach { process($0) }
            }


            @inlinable
            public mutating func reset() {
                _buffer.removeAll()
            }

        }

    }

}



// MARK: - .ExponentialMean

extension KvStatistics {

    /// Exponential weightet mean. See [Wikipedia](https://wikipedia.org/wiki/Exponential_smoothing ). E.g. it's used in EMA indicator.
    public class ExponentialMean<Value : BinaryFloatingPoint> {

        // MARK: .Stream

        /// Exponential average online algorithm that is less prone to loss of precision due to catastrophic cancellation.
        public struct Stream : KvStatisticsAverageStream {

            public let period: Int
            public let alpha: Value


            @inlinable
            public var average: Value { _average }

            @inlinable
            public var count: Int { _count }


            @usableFromInline
            internal var _average: Value = 0.0 as Value

            @usableFromInline
            internal var _count: Int = 0


            @usableFromInline
            internal let oneMinusAlpha: Value



            /// Creates an instance in initial state.
            @inlinable
            public init(period: Int, alpha: Value) {
                assert(period > 0 && alpha >= (0.0 as Value) && alpha <= (1.0 as Value))

                self.period = period
                self.alpha = alpha

                oneMinusAlpha = (1.0 as Value) - alpha
            }


            /// Creates an instance that has processed given *values*.
            @inlinable
            public init<S>(period: Int, alpha: Value, with values: S)
            where S : Sequence, S.Element == Value
            {
                self.init(period: period, alpha: alpha)
                process(values)
            }



            // MARK: : KvStatisticsAverageStream

            /// - Returns: The result as if given *value* had been processed.
            @inlinable
            public func nextAverage(for value: Value) -> Value {
                alpha * value + oneMinusAlpha * _average
            }



            // MARK: : KvStatisticsStream

            @inlinable
            public mutating func process(_ value: Value) {
                _average = _count > 0 ? (alpha * value + oneMinusAlpha * _average) : value

                _count += 1
            }


            @inlinable
            public mutating func process<S>(_ values: S) where S : Sequence, S.Element == Value {
                var iterator = values.makeIterator()

                if _count == 0 {
                    guard let value = iterator.next() else { return }

                    _average = value
                    _count = 1
                }

                while let value = iterator.next() {
                    _average = alpha * value + oneMinusAlpha * _average
                    _count += 1
                }
            }


            @inlinable
            public mutating func process<C>(_ values: C) where C : Collection, C.Element == Value {
                var iterator = values.makeIterator()

                if _count == 0 {
                    guard let value = iterator.next() else { return }

                    _average = value
                }

                while let value = iterator.next() {
                    _average = alpha * value + oneMinusAlpha * _average
                }

                _count += values.count
            }


            @inlinable
            public mutating func reset() {
                _average = 0.0 as Value
                _count = 0
            }

        }

    }

}



// MARK: .RMS

extension KvStatistics {

    /// Root mean square
    public class RMS<Value : BinaryFloatingPoint> {

        // MARK: .Processor

        /// Root mean square online algorithm that is less prone to loss of precision due to catastrophic cancellation.
        public struct Processor : KvStatisticsAverageProcessor {

            @inlinable
            public var average: Value { avgProcessor._average.squareRoot() }

            @inlinable
            public var count: Int { avgProcessor._count }


            @usableFromInline
            internal private(set) var avgProcessor = Average<Value>.Processor()



            /// Creates an instance in initial state.
            @inlinable
            public init() { }


            /// Creates an instance that has processed given *values*.
            @inlinable
            public init<S>(with values: S) where S : Sequence, S.Element == Value {
                process(values)
            }


            // TODO: Delete in 6.0.0.
            @available(*, deprecated, renamed: "init(with:)")
            public init<S>(_ values: S) where S : Sequence, S.Element == Value { self.init(with: values) }



            // MARK: : KvStatisticsAverageStream

            /// - Returns: The result as if given *value* had been processed.
            @inlinable
            public func nextAverage(for value: Value) -> Value {
                avgProcessor.nextAverage(for: value * value).squareRoot()
            }



            // MARK: : KvStatisticsStream

            @inlinable
            public mutating func process(_ value: Value) {
                avgProcessor.process(value * value)
            }


            @inlinable
            public mutating func process<S>(_ values: S) where S : Sequence, S.Element == Value {
                avgProcessor.process(values.lazy.map { $0 * $0 })
            }


            @inlinable
            public mutating func reset() { avgProcessor.reset() }



            // MARK: : KvStatisticsProcessor

            @inlinable
            public mutating func rollback(_ value: Value) { avgProcessor.rollback(value * value) }


            @inlinable
            public mutating func rollback<S>(_ values: S) where S : Sequence, S.Element == Value {
                avgProcessor.rollback(values.lazy.map { $0 * $0 })
            }


            @inlinable
            public mutating func rollback<C>(_ values: C) where C : Collection, C.Element == Value {
                avgProcessor.rollback(values.lazy.map { $0 * $0 })
            }


            @inlinable
            public mutating func replace(_ oldValue: Value, with newValue: Value) {
                avgProcessor.replace(oldValue * oldValue, with: newValue * newValue)
            }


            @inlinable
            public mutating func replace<S>(_ oldValues: S, with newValues: S) where S : Sequence, S.Element == Value {
                avgProcessor.replace(oldValues.lazy.map { $0 * $0 }, with: newValues.lazy.map { $0 * $0 })
            }

        }



        // MARK: .MovingStream

        /// Moving root mean square online algorithm that is less prone to loss of precision due to catastrophic cancellation.
        public struct MovingStream : KvStatisticsAverageStream {

            @inlinable
            public var average: Value { avgStream._average.squareRoot() }

            @inlinable
            public var capacity: Int { avgStream.capacity }

            @inlinable
            public var count: Int { avgStream.count }


            @usableFromInline
            internal private(set) var avgStream: Average<Value>.MovingStream



            /// Creates an instance in initial state.
            @inlinable
            public init(capacity: Int) {
                avgStream = .init(capacity: capacity)
            }


            /// Creates an instance that has processed given *values*.
            @inlinable
            public init<S>(capacity: Int, with values: S) where S : Sequence, S.Element == Value {
                self.init(capacity: capacity)
                
                process(values)
            }


            // TODO: Delete in 6.0.0.
            @available(*, deprecated, renamed: "init(capacity:with:)")
            public init<S>(capacity: Int, _ values: S) where S : Sequence, S.Element == Value { self.init(capacity: capacity, with: values) }



            // MARK: : KvStatisticsAverageStream

            /// - Returns: The result as if given *value* had been processed.
            @inlinable
            public func nextAverage(for value: Value) -> Value {
                avgStream.nextAverage(for: value * value).squareRoot()
            }



            // MARK: : KvStatisticsStream

            @inlinable
            public mutating func process(_ value: Value) { avgStream.process(value * value) }


            @inlinable
            public mutating func process<S>(_ values: S) where S : Sequence, S.Element == Value {
                avgStream.process(values.lazy.map { $0 * $0 })
            }


            @inlinable
            public mutating func reset() { avgStream.reset() }

        }

    }

}



// MARK: - KvStatisticsVarianceStream

public protocol KvStatisticsVarianceStream : KvStatisticsStream {

    associatedtype Result


    var standardDeviation: Result { get }
    var variance: Result { get }

    var unbiasedStandardDeviation: Result { get }
    var unbiasedVariance: Result { get }

    /// Moment. Equal to both `variance * count` and `unbiassedVariance * (count - 1)`
    var moment: Result { get }

}



// MARK: - KvStatisticsVarianceProcessor

public protocol KvStatisticsVarianceProcessor : KvStatisticsVarianceStream, KvStatisticsProcessor { }



// MARK: - .Variance

extension KvStatistics {

    /// [Wikipedia](https://wikipedia.org/wiki/Variance): variance is the squared deviation from the mean of a random variable.
    public class Variance<Value : BinaryFloatingPoint> {

        // MARK: .Processor

        /// Welford's online variance algorithm. The algorithm is less prone to loss of precision due to catastrophic cancellation.
        public struct Processor : KvStatisticsVarianceProcessor {

            @inlinable
            public var standardDeviation: Value { variance.squareRoot() }

            @inlinable
            public var variance: Value { value(divider: avgProcessor._count) }


            @inlinable
            public var unbiasedStandardDeviation: Value { unbiasedVariance.squareRoot() }

            @inlinable
            public var unbiasedVariance: Value { value(divider: avgProcessor._count - 1) }


            @inlinable
            public var moment: Value { _moment }


            @inlinable
            public var average: Value { _average }


            @inlinable
            public var count: Int { avgProcessor._count }


            @usableFromInline
            internal private(set) var _moment: Value = 0.0 as Value


            @usableFromInline
            internal private(set) var _average: Value = 0.0 as Value


            @usableFromInline
            internal private(set) var avgProcessor = Average<Value>.Processor()



            /// Creates an instance in initial state.
            @inlinable
            public init() { }


            /// Creates an instance that has processed given *values*.
            @inlinable
            public init<S>(with values: S) where S : Sequence, S.Element == Value { process(values) }



            // MARK: Auxiliaries

            @usableFromInline
            internal func value(divider: Int) -> Value { divider > 0 ? _moment / Value(divider) : (0.0 as Value) }



            // MARK: : KvStatisticsStream

            @inlinable
            public mutating func process(_ value: Value) {
                avgProcessor.process(value)

                let newAverage = avgProcessor._average
                defer { _average = newAverage }

                _moment.addProduct(value - _average, value - newAverage)

                #if DEBUG
                if KvIsNegative(_moment) {
                    KvDebug.pause("The moment (\(_moment)) must be positive")
                }
                #endif // DEBUG
            }


            @inlinable
            public mutating func process<S>(_ values: S) where S : Sequence, S.Element == Value {
                values.forEach { process($0) }
            }


            @inlinable
            public mutating func reset() {
                _moment = 0.0 as Value
                _average = 0.0 as Value
                avgProcessor.reset()
            }



            // MARK: : KvStatisticsProcessor

            @inlinable
            public mutating func rollback(_ value: Value) {
                avgProcessor.rollback(value)

                let newAverage = avgProcessor._average
                defer { _average = newAverage }

                _moment.addProduct(value - _average, newAverage - value)

                #if DEBUG
                if KvIsNegative(_moment) {
                    KvDebug.pause("The moment (\(_moment)) must be positive")
                }
                #endif // DEBUG
            }


            @inlinable
            public mutating func rollback<S>(_ values: S) where S : Sequence, S.Element == SourceValue {
                values.forEach { rollback($0) }
            }


            @inlinable
            public mutating func replace(_ oldValue: Value, with newValue: Value) {
                avgProcessor.replace(oldValue, with: newValue)

                let newAverage = avgProcessor._average
                defer { _average = newAverage }

                _moment.addProduct(newValue - oldValue, (newValue - newAverage) as Value + (oldValue - _average) as Value)

                #if DEBUG
                if KvIsNegative(_moment) {
                    KvDebug.pause("The moment (\(_moment)) must be positive")
                }
                #endif // DEBUG
            }


            @inlinable
            public mutating func replace<S>(_ oldValues: S, with newValues: S) where S : Sequence, S.Element == SourceValue {
                var oldIterator = oldValues.makeIterator(), newIterator = newValues.makeIterator()

                while let oldValue = oldIterator.next(), let newValue = newIterator.next() {
                    replace(oldValue, with: newValue)
                }
            }

        }



        // MARK: .MovingStream

        /// Welford's online moving variance algorithm. The algorithm is less prone to loss of precision due to catastrophic cancellation.
        public struct MovingStream : KvStatisticsVarianceStream {

            @inlinable
            public var standardDeviation: Value { variance.squareRoot() }

            @inlinable
            public var variance: Value {
                let count = self.count

                return max(0, count < capacity ? value(divider: count) : (_moment * invCapacity))
            }


            @inlinable
            public var unbiasedStandardDeviation: Value { unbiasedVariance.squareRoot() }

            @inlinable
            public var unbiasedVariance: Value {
                let count = self.count

                return max(0, count < capacity ? value(divider: count - 1) : (_moment * invCapacityMinusOne))
            }


            @inlinable
            public var moment: Value { _moment }


            @inlinable
            public var average: Value { _average }


            @inlinable
            public var count: Int { avgStream.count }

            @inlinable
            public var capacity: Int { avgStream.capacity }


            public let invCapacity: Value
            public let invCapacityMinusOne: Value


            @usableFromInline
            internal private(set) var _moment: Value = 0.0 as Value


            @usableFromInline
            internal private(set) var _average: Value = 0.0 as Value


            @usableFromInline
            internal private(set) var avgStream: Average<Value>.MovingStream



            /// Creates an instance in initial state.
            @inlinable
            public init(capacity: Int) {
                assert(capacity >= 2)

                avgStream = .init(capacity: capacity)

                invCapacity = (1.0 as Value) / Value(capacity)
                invCapacityMinusOne = (1.0 as Value) / Value(capacity - 1)
            }


            /// Creates an instance that has processed given *values*.
            @inlinable
            public init<S>(capacity: Int, with values: S)
            where S : Sequence, S.Element == Value {
                self.init(capacity: capacity)
                process(values)
            }



            // MARK: Auxiliaries

            @usableFromInline
            internal func value(divider: Int) -> Value {
                divider > 0 ? _moment / Value(count) : (0.0 as Value)
            }



            // MARK: : KvStatisticsStream

            @inlinable
            public mutating func process(_ value: Value) {
                if count < capacity {
                    avgStream.process(value)

                    let newAverage = avgStream._average
                    defer { _average = newAverage }

                    _moment.addProduct(value - _average, value - newAverage)

                } else {
                    let excludedValue = avgStream._buffer.first!

                    avgStream.process(value)

                    let newAverage = avgStream._average
                    defer { _average = newAverage }

                    _moment.addProduct(value - excludedValue, (value - _average) as Value + (excludedValue - newAverage) as Value)
                }
            }


            @inlinable
            public mutating func process<S>(_ values: S) where S : Sequence, S.Element == Value {
                values.forEach { process($0) }
            }


            @inlinable
            public mutating func reset() {
                _moment = 0.0 as Value
                _average = 0.0 as Value
                avgStream.reset()
            }

        }



        // MARK: .Moment

        /// Offline variance algorithm.
        public struct Moment {

            public let value, average, count: Value


            public private(set) lazy var standardDeviation: Value = count > (0.0 as Value) ? (value / count).squareRoot() : (0.0 as Value)

            public private(set) lazy var variance: Value = count > (0.0 as Value) ? (value / count) : (0.0 as Value)

            public private(set) lazy var unbiasedStandardDeviation: Value = { $0 > (0.0 as Value) ? (value / $0).squareRoot() : (0.0 as Value) }((count - (1.0 as Value)) as Value)

            public private(set) lazy var unbiasedVariance: Value = { $0 > (0.0 as Value) ? (value / $0) : (0.0 as Value) }((count - (1.0 as Value)) as Value)



            @inlinable
            public init<S>(_ values: S) where S: Sequence, S.Element == Value {
                var average = (0.0 as Value), count = (0.0 as Value)

                value = values.reduce(0.0 as Value) { (moment, x) in
                    count += 1.0 as Value

                    let newAverage = average + ((x - average) as Value) / count
                    defer { average = newAverage }

                    return moment.addingProduct(x - average, x - newAverage)
                }

                self.average = average
                self.count = count
            }

        }



        // MARK: .Uniform

        /// Collection of fast implementations of variance and related values for arithmetic progressions.
        public struct Uniform {

            @usableFromInline
            internal static var oneTwelfth: Value { (1.0 as Value) / (12.0 as Value) }


            /// - Returns: The moment value for [ 1∙d, 2∙d, ..., n∙d ].
            @inlinable
            public static func moment(d: Value, n: Int) -> Value {
                d * d * Value(n * (n * n - 1)) * oneTwelfth
            }


            /// - Returns: The moment value for [ 1, 2, ..., n ].
            @inlinable
            public static func moment(n: Int) -> Value {
                Value(n * (n * n - 1)) * oneTwelfth
            }



            /// - Returns: Standard deviation value for [ 1∙d, 2∙d, ..., n∙d ].
            @inlinable
            public static func standardDeviation(d: Value, n: Int) -> Value {
                d * (Value(n * n - 1) * oneTwelfth).squareRoot()
            }


            /// - Returns: Standard deviation value for [ 1, 2, ..., n ].
            @inlinable
            public static func standardDeviation(n: Int) -> Value {
                (Value(n * n - 1) * oneTwelfth).squareRoot()
            }



            /// - Returns: Variance value for [ 1∙d, 2∙d, ..., n∙d ].
            @inlinable
            public static func variance(d: Value, n: Int) -> Value {
                d * d * Value(n * n - 1) * oneTwelfth
            }


            /// - Returns: Variance value for [ 1, 2, ..., n ].
            @inlinable
            public static func variance(n: Int) -> Value {
                Value(n * n - 1) * oneTwelfth
            }



            /// - Returns: Unbiased standard deviation value for [ 1∙d, 2∙d, ..., n∙d ].
            @inlinable
            public static func unbiasedStandardDeviation(d: Value, n: Int) -> Value {
                d * (Value(n * (n + 1)) * oneTwelfth).squareRoot()
            }


            /// - Returns: Unbiased standard deviation value for [ 1, 2, ..., n ].
            @inlinable
            public static func unbiasedStandardDeviation(n: Int) -> Value {
                (Value(n * (n + 1)) * oneTwelfth).squareRoot()
            }



            /// - Returns: Unbiased variance value for [ 1∙d, 2∙d, ..., n∙d ].
            @inlinable
            public static func unbiasedVariance(d: Value, n: Int) -> Value {
                d * d * Value(n * (n + 1)) * oneTwelfth
            }


            /// - Returns: Unbiased variance value for [ 1, 2, ..., n ].
            @inlinable
            public static func unbiasedVariance(n: Int) -> Value {
                Value(n * (n + 1)) * oneTwelfth
            }

        }

    }

}



// MARK: - KvStatisticsCovarianceStream

public protocol KvStatisticsCovarianceStream : KvStatisticsStream {

    associatedtype Result


    var covariance: Result { get }
    var unbiasedCovariance: Result { get }

    /// Co-moment. Equal to both `covariance * count` and `unbiassedCovariance * (count - 1)`
    var comoment: Result { get }

}



// MARK: - KvStatisticsCovarianceProcessor

public protocol KvStatisticsCovarianceProcessor : KvStatisticsCovarianceStream, KvStatisticsProcessor { }



// MARK: - .Covariance

extension KvStatistics {

    /// [Wikipedia](https://wikipedia.org/wiki/Covariance) : covariance is a measure of the joint variability of two random variables.
    public class Covariance<Value : BinaryFloatingPoint> {

        public typealias SourceValue = (Value, Value)



        // MARK: .Processor

        /// Analog of Welford's online algorithm for variance. The algorithm is less prone to loss of precision due to catastrophic cancellation.
        public struct Processor : KvStatisticsCovarianceProcessor {

            @inlinable
            public var covariance: Value { value(divider: count) }

            @inlinable
            public var unbiasedCovariance: Value { value(divider: count - 1) }


            @inlinable
            public var comoment: Value { _comoment }


            @inlinable
            public var average: SourceValue { _average }


            @inlinable
            public var count: Int { avgProcessor.0._count }


            @usableFromInline
            internal private(set) var _comoment: Value = 0.0 as Value


            @usableFromInline
            internal private(set) var _average: SourceValue = (0.0 as Value, 0.0 as Value)


            @usableFromInline
            internal private(set) var avgProcessor = (Average<Value>.Processor(), Average<Value>.Processor())



            /// Creates an instance in initial state.
            @inlinable
            public init() { }


            /// Creates an instance that has processed given *values*.
            @inlinable
            public init<S>(with values: S) where S : Sequence, S.Element == SourceValue { process(values) }



            // MARK: Auxiliaries

            @usableFromInline
            internal func value(divider: Int) -> Value {
                divider > 0 ? _comoment / Value(divider) : (0.0 as Value)
            }


            @inlinable
            public mutating func process(_ v0: Value, _ v1: Value) {
                avgProcessor.0.process(v0)
                _average.0 = avgProcessor.0._average

                _comoment.addProduct(v0 - _average.0, v1 - _average.1)

                avgProcessor.1.process(v1)
                _average.1 = avgProcessor.1._average
            }


            @inlinable
            public mutating func rollback(_ v0: Value, _ v1: Value) {
                avgProcessor.1.rollback(v1)
                _average.1 = avgProcessor.1._average

                _comoment.addProduct(v0 - _average.0, _average.1 - v1)

                avgProcessor.0.rollback(v0)
                _average.0 = avgProcessor.0._average
            }


            @inlinable
            public mutating func replace(_ old0: Value, _ old1: Value, with new0: Value, _ new1: Value) {
                avgProcessor.0.replace(old0, with: new0)
                _average.0 = avgProcessor.0._average

                _comoment.addProduct(new0 - _average.0, new1 - old1)
                _comoment.addProduct(new0 - old0, old1 - _average.1)

                avgProcessor.1.replace(old1, with: new1)
                _average.1 = avgProcessor.1._average
            }



            // MARK: : KvStatisticsStream

            @inlinable
            public mutating func process(_ value: SourceValue) { process(value.0, value.1) }


            @inlinable
            public mutating func process<S>(_ values: S) where S : Sequence, S.Element == SourceValue {
                values.forEach { process($0.0, $0.1) }
            }


            @inlinable
            public mutating func reset() {
                _comoment = 0.0 as Value
                _average = (0.0 as Value, 0.0 as Value)
                avgProcessor.0.reset()
                avgProcessor.1.reset()
            }



            // MARK: : KvStatisticsProcessor

            @inlinable
            public mutating func rollback(_ value: SourceValue) { rollback(value.0, value.1) }


            @inlinable
            public mutating func rollback<S>(_ values: S) where S : Sequence, S.Element == SourceValue {
                values.forEach { rollback($0.0, $0.1) }
            }


            @inlinable
            public mutating func replace(_ oldValue: SourceValue, with newValue: SourceValue) {
                replace(oldValue.0, oldValue.1, with: newValue.0, newValue.1)
            }


            @inlinable
            public mutating func replace<S>(_ oldValues: S, with newValues: S) where S : Sequence, S.Element == SourceValue {
                zip(oldValues, newValues).forEach {
                    replace($0.0.0, $0.0.1, with: $0.1.0, $0.1.1)
                }
            }

        }



        // MARK: .MovingStream

        /// Analog of Welford's online algorithm for moving variance. The algorithm is less prone to loss of precision due to catastrophic cancellation.
        public struct MovingStream : KvStatisticsCovarianceStream {

            @inlinable
            public var buffer: KvCircularBuffer<SourceValue> { _buffer }


            @inlinable
            public var count: Int { _buffer.count }

            @inlinable
            public var capacity: Int { _buffer.capacity }


            @usableFromInline
            internal private(set) var _buffer: KvCircularBuffer<SourceValue>


            @usableFromInline
            internal private(set) var covarianceProcessor: Processor = .init()



            /// Creates an instance in initial state.
            @inlinable
            public init(capacity: Int) {
                _buffer = .init(capacity: capacity)
            }


            /// Creates an instance that has processed given *values*.
            @inlinable
            public init<S>(capacity: Int, with values: S)
            where S : Sequence, S.Element == SourceValue
            {
                self.init(capacity: capacity)
                process(values)
            }



            // MARK: : KvStatisticsCovarianceStream

            @inlinable
            public var covariance: Value { covarianceProcessor.covariance }

            @inlinable
            public var unbiasedCovariance: Value { covarianceProcessor.unbiasedCovariance }

            @inlinable
            public var comoment: Value { covarianceProcessor._comoment }



            // MARK: : KvStatisticsStream

            @inlinable
            public mutating func process(_ value: SourceValue) {
                if let oldValue = _buffer.append(value) {
                    covarianceProcessor.replace(oldValue, with: value)
                } else {
                    covarianceProcessor.process(value)
                }
            }


            @inlinable
            public mutating func process<S>(_ values: S) where S : Sequence, S.Element == SourceValue {
                values.forEach { process($0) }
            }


            @inlinable
            public mutating func reset() {
                _buffer.removeAll()
                covarianceProcessor.reset()
            }

        }



        /// Offline covariance algorithm.
        public struct Comoment {

            public let value: Value
            public let average: (x: Value, y: Value)
            public let count: Value


            public private(set) lazy var covariance: Value = count > (0.0 as Value) ? value / count : (0.0 as Value)

            public private(set) lazy var unbiasedCovariance: Value = { $0 > (0.0 as Value) ? value / $0 : (0.0 as Value) }(count - (1.0 as Value))



            @inlinable
            public init<S₁, S₂>(x xs: S₁, y ys: S₂) where S₁: Sequence, S₁.Element == Value, S₂: Sequence, S₂.Element == Value {
                var average: (Value, Value) = (0.0, 0.0), count: Value = 0.0

                value = zip(xs, ys).reduce(0) { (comoment, values) in
                    count += 1.0 as Value
                    let oneByCount = (1.0 as Value) / count

                    let newAverage = (average.0 + ((values.0 - average.0) as Value) * oneByCount, average.1 + ((values.1 - average.1) as Value) * oneByCount)
                    defer { average = newAverage }

                    return comoment.addingProduct(values.0 - newAverage.0, values.1 - average.1)
                }

                self.average = average
                self.count = count
            }



            @inlinable
            public init<S>(dx: Value = 1, y values: S) where S: Sequence, S.Element == Value {
                var average: (x: Value, y: Value) = (-0.5 as Value, 0.0 as Value), count: Value = 0.0 as Value

                value = dx * values.reduce(0) { (comoment, value) in
                    count += 1.0 as Value

                    let newAverage = (x: average.x + (0.5 as Value), y: average.y + ((value - average.y) as Value) / count)
                    defer { average = newAverage }

                    return comoment.addingProduct(newAverage.x, value - average.y)
                }

                self.average = (dx * average.x, average.y)
                self.count = count
            }

        }

    }

}



// MARK: - .Correlation

extension KvStatistics {

    /// The correlation coefficient of two sequences.
    public class Correlation<Value : BinaryFloatingPoint> {

        public typealias Scalar = Value
        public typealias Point = (Scalar, Scalar)



        // MARK: .Processor

        public struct Processor : KvStatisticsProcessor {

            @inlinable
            public var correlation: Value { covarianceProcessor._comoment / sqrt(varianceProcessors.0._moment * varianceProcessors.1._moment) }


            @usableFromInline
            internal private(set) var varianceProcessors = (Variance<Value>.Processor(), Variance<Value>.Processor())

            @usableFromInline
            internal private(set) var covarianceProcessor = Covariance<Value>.Processor()



            /// Creates an instance in initial state.
            @inlinable
            public init() { }


            /// Creates an instance that has processed given *points*.
            @inlinable
            public init<S>(_ points: S) where S : Sequence, S.Element == Point {
                varianceProcessors.0.process(points.lazy.map { $0.0 })
                varianceProcessors.1.process(points.lazy.map { $0.1 })
                covarianceProcessor.process(points)
            }


            /// Creates an instance that has processed pairs of values from given sequences.
            @inlinable
            public init<S0, S1>(_ s0: S0, _ s1: S1) where S0 : Sequence, S0.Element == Value, S1 : Sequence, S1.Element == Value {
                varianceProcessors.0.process(s0)
                varianceProcessors.1.process(s1)
                covarianceProcessor.process(zip(s0, s1))
            }



            // MARK: : KvStatisticsStream

            @inlinable
            public mutating func process(_ value: Point) {
                varianceProcessors.0.process(value.0)
                varianceProcessors.1.process(value.1)
                covarianceProcessor.process(value)
            }


            @inlinable
            public mutating func process<S>(_ values: S) where S : Sequence, S.Element == Point {
                values.forEach { process($0) }
            }


            @inlinable
            public mutating func reset() {
                varianceProcessors.0.reset()
                varianceProcessors.1.reset()
                covarianceProcessor.reset()
            }



            // MARK: : KvStatisticsProcessor

            @inlinable
            public mutating func rollback(_ value: Point) {
                varianceProcessors.0.rollback(value.0)
                varianceProcessors.1.rollback(value.1)
                covarianceProcessor.rollback(value)
            }


            @inlinable
            public mutating func replace(_ old: Point, with new: Point) {
                varianceProcessors.0.replace(old.0, with: new.0)
                varianceProcessors.1.replace(old.1, with: new.1)
                covarianceProcessor.replace(old, with: new)
            }


            @inlinable
            public mutating func rollback<S>(_ values: S) where S : Sequence, S.Element == Point {
                values.forEach { rollback($0) }
            }


            @inlinable
            public mutating func replace<S>(_ oldValues: S, with newValues: S) where S : Sequence, S.Element == Point {
                zip(oldValues, newValues).forEach {
                    replace($0.0, with: $0.1)
                }
            }

        }

    }

}



// MARK: - .MinMax

extension KvStatistics {

    /// Online evaluator of minimum and maximum values on a sequence.
    public class MinMax<Value : FloatingPoint> {

        // MARK: .Stream

        /// Online evaluator of minimum and maximum values on a sequence.
        public struct Stream : KvStatisticsStream {

            @inlinable
            public var minimum: Value { _minimum }

            @inlinable
            public var maximum: Value { _maximum }

            @inlinable
            public var count: Int { _count }


            @usableFromInline
            internal private(set) var _minimum: Value = 0

            @usableFromInline
            internal private(set) var _maximum: Value = 0

            @usableFromInline
            internal private(set) var _count: Int = 0



            /// Creates an instance in initial state.
            @inlinable
            public init() { }


            /// Creates an instance that has processed given *values*.
            @inlinable
            public init<S>(with values: S) where S : Sequence, S.Element == Value { process(values) }



            // MARK: Auxiliaries

            @usableFromInline
            mutating internal func updateBounds(with value: Value) {
                if _count > 0 {
                    if value > _maximum {
                        _maximum = value
                    } else if value < _minimum {
                        _minimum = value
                    }

                } else {
                    _minimum = value
                    _maximum = value
                }
            }



            // MARK: : KvStatisticsStream

            @inlinable
            public mutating func process(_ value: Value) {
                updateBounds(with: value)

                _count += 1
            }


            @inlinable
            public mutating func process<S>(_ values: S) where S : Sequence, S.Element == Value {
                values.forEach { process($0) }
            }


            @inlinable
            public mutating func process<C>(_ values: C) where C : Collection, C.Element == Value {
                values.forEach { updateBounds(with: $0) }

                _count += values.count
            }


            @inlinable
            public mutating func reset() {
                _minimum = 0
                _maximum = 0
                _count = 0
            }

        }

    }

}



// MARK: - .MinMaxAvg

extension KvStatistics {

    /// Online evaluator of minimum, maximum and average values on a sequence.
    public class MinMaxAvg<Value: BinaryFloatingPoint> {

        // MARK: .Stream

        /// Online evaluator of minimum, maximum and average values on a sequence.
        public struct Stream : KvStatisticsStream, CustomStringConvertible {

            @inlinable
            public var minimum: Value { minMaxStream._minimum }

            @inlinable
            public var maximum: Value { minMaxStream._maximum }

            @inlinable
            public var average: Value { avgProcessor._average }


            @inlinable
            public var count: Int { avgProcessor._count }


            @usableFromInline
            internal private(set) var minMaxStream = KvStatistics.MinMax<Value>.Stream()

            @usableFromInline
            internal private(set) var avgProcessor = KvStatistics.Average<Value>.Processor()



            /// Creates an instance in initial state.
            @inlinable
            public init() { }


            /// Creates an instance that has processed given *values*.
            @inlinable
            public init<S>(_ values: S) where S : Sequence, S.Element == Value { process(values) }



            // MARK: Auxiliaries

            /// - Returns: The average value as if given *value* had been processed.
            @inlinable
            public func nextAverage(for value: Value) -> Value {
                avgProcessor.nextAverage(for: value)
            }



            // MARK: : KvStatisticsStream

            @inlinable
            public mutating func process(_ value: Value) {
                minMaxStream.process(value)
                avgProcessor.process(value)
            }


            @inlinable
            public mutating func process<S>(_ values: S) where S : Sequence, S.Element == Value {
                minMaxStream.process(values)
                avgProcessor.process(values)
            }


            @inlinable
            public mutating func process<C>(_ values: C) where C : Collection, C.Element == Value {
                minMaxStream.process(values)
                avgProcessor.process(values)
            }


            @inlinable
            public mutating func reset() {
                minMaxStream.reset()
                avgProcessor.reset()
            }



            // MARK: : CustomStringConvertible

            @inlinable
            public var description: String { "(min: \(minimum), max: \(maximum), avg: \(average), count: \(count))" }

        }

    }

}



// MARK: - KvStatisticsLinearRegressionStream

public protocol KvStatisticsLinearRegressionStream : KvStatisticsStream {

    associatedtype Result : KvLinearMappingProtocol


    var k: Result.Value { get }
    var b: Result.Value { get }

    var line: Result { get }

}



// MARK: - KvStatisticsLinearRegressionProcessor

public protocol KvStatisticsLinearRegressionProcessor : KvStatisticsLinearRegressionStream, KvStatisticsProcessor { }



// MARK: - .LinearRegression

extension KvStatistics {

    /// Linear regression (2-dimensional). See: [Wikipedia](https://en.wikipedia.org/wiki/Linear_regression ).
    public class LinearRegression<Value : BinaryFloatingPoint> {

        public typealias Scalar = Value
        public typealias Point = (x: Scalar, y: Scalar)

        public typealias Line = KvShiftedLinearMapping<Scalar>



        // MARK: .Processor

        /// Linear regression online algorithm.
        public struct Processor : KvStatisticsLinearRegressionProcessor {

            @inlinable
            public var k: Value {
                let moment = varianceProcessor._moment
                return moment >= Value.ulpOfOne ? (covarianceProcessor._comoment / moment) : (0.0 as Value)
            }

            @inlinable
            public var b: Value { covarianceProcessor._average.1 - k * covarianceProcessor._average.0 }

            @inlinable
            public var line: Line { .init(k: k, x₀: covarianceProcessor._average.0, y₀: covarianceProcessor._average.1) }


            @usableFromInline
            internal private(set) var varianceProcessor = Variance<Value>.Processor()

            @usableFromInline
            internal private(set) var covarianceProcessor = Covariance<Value>.Processor()



            /// Creates an instance in initial state.
            @inlinable
            public init() { }


            /// Creates an instance that has processed given *values*.
            @inlinable
            public init<S>(with values: S) where S : Sequence, S.Element == Point { process(values) }



            // MARK: Auxiliaries

            @inlinable
            public mutating func process(x: Value, y: Value) {
                varianceProcessor.process(x)
                covarianceProcessor.process(x, y)
            }


            @inlinable
            public mutating func rollback(x: Value, y: Value) {
                varianceProcessor.rollback(x)
                covarianceProcessor.rollback(x, y)
            }


            @inlinable
            public mutating func replace(x oldX: Value, y oldY: Value, withX newX: Value, y newY: Value) {
                varianceProcessor.replace(oldX, with: newX)
                covarianceProcessor.replace(oldX, oldY, with: newX, newY)
            }



            // MARK: : KvStatisticsStream

            @inlinable
            public mutating func process(_ value: Point) { process(x: value.x, y: value.y) }


            @inlinable
            public mutating func process<S>(_ values: S) where S : Sequence, S.Element == Point {
                values.forEach { process(x: $0.x, y: $0.y) }
            }


            @inlinable
            public mutating func reset() {
                varianceProcessor.reset()
                covarianceProcessor.reset()
            }



            // MARK: : KvStatisticsProcessor

            @inlinable
            public mutating func rollback(_ value: Point) {
                rollback(x: value.x, y: value.y)
            }


            @inlinable
            public mutating func rollback<S>(_ values: S) where S : Sequence, S.Element == Point {
                values.forEach { rollback(x: $0.x, y: $0.y) }
            }


            @inlinable
            public mutating func replace(_ oldValue: Point, with newValue: Point) {
                replace(x: oldValue.x, y: oldValue.y, withX: newValue.x, y: newValue.y)
            }


            @inlinable
            public mutating func replace<S>(_ oldValues: S, with newValues: S) where S : Sequence, S.Element == Point {
                zip(oldValues, newValues).forEach {
                    replace(x: $0.0.x, y: $0.0.y, withX: $0.1.x, y: $0.1.y)
                }
            }

        }



        // MARK: .MovingStream

        /// Moving linear regression online algorithm.
        public struct MovingStream : KvStatisticsLinearRegressionStream {

            @inlinable
            public var k: Value { linearRegressionProcessor.k }

            @inlinable
            public var b: Value { linearRegressionProcessor.b }

            @inlinable
            public var line: Line { linearRegressionProcessor.line }


            @inlinable
            public var buffer: KvCircularBuffer<Point> { _buffer }


            @inlinable
            public var count: Int { _buffer.count }

            @inlinable
            public var capacity: Int { _buffer.capacity }


            @usableFromInline
            internal private(set) var _buffer: KvCircularBuffer<Point>


            @usableFromInline
            internal private(set) var linearRegressionProcessor: Processor = .init()



            /// Creates an instance in initial state.
            @inlinable
            public init(capacity: Int) {
                _buffer = .init(capacity: capacity)
            }


            /// Creates an instance that has processed given *values*.
            @inlinable
            public init<S>(capacity: Int, with values: S)
            where S : Sequence, S.Element == Point
            {
                self.init(capacity: capacity)
                process(values)
            }



            // MARK: Auxiliaries

            @inlinable
            public mutating func process(x: Value, y: Value) { process((x, y)) }



            // MARK: : KvStatisticsStream

            @inlinable
            public mutating func process(_ value: Point) {
                if let oldValue = _buffer.append(value) {
                    linearRegressionProcessor.replace(x: oldValue.x, y: oldValue.y, withX: value.x, y: value.y)
                } else {
                    linearRegressionProcessor.process(x: value.x, y: value.y)
                }
            }


            @inlinable
            public mutating func process<S>(_ values: S) where S : Sequence, S.Element == Point {
                values.forEach { process($0) }
            }


            @inlinable
            public mutating func reset() {
                _buffer.removeAll()
                linearRegressionProcessor.reset()
            }

        }



        /// An offline implementation for arbitrary sequences of x and y values.
        @inlinable
        public static func line<S₁, S₂>(x xs: S₁, y ys: S₂) -> Line
        where S₁: Sequence, S₁.Element == Value, S₂: Sequence, S₂.Element == Value
        {
            .init(.init(x: xs, y: ys), Variance<Value>.Moment(xs).value)
        }


        /// An offline implementation for arbitrary sequence of y values where x values are index offsets in y value sequence.
        @inlinable
        public static func line<S>(_ values: S) -> Line
        where S: Sequence, S.Element == Value
        {
            let comoment = Covariance<Value>.Comoment(y: values)
            let moment = Variance<Value>.Uniform.moment(n: Int(comoment.count))

            return .init(comoment, moment)
        }

    }

}



// MARK: .LocalMaximum

extension KvStatistics {

    /// Local maximums.
    public class LocalMaximum<Value : Comparable> {

        public typealias Value = Value



        /// Note generic argument is desinated to help process deferred invocations of *callback*. Use *Void* if note is unused.
        public struct Stream<Note> : KvStatisticsStream {

            public typealias Value = LocalMaximum.Value
            public typealias Note = Note

            public typealias Callback = (SourceValue) -> Void


            public let threshold: Threshold


            @usableFromInline
            internal let callback: Callback

            @usableFromInline
            internal private(set) var state: State = .initial



            /// Creates an instance in initial state.
            ///
            /// - Parameter threshold: A value after a `local_maximum` value have to be less then `threshold`×`local_maximum`.
            @inlinable
            public init(threshold: Threshold, callback: @escaping Callback) {
                self.threshold = threshold
                self.callback = callback
            }


            /// Creates an instance that has processed given *values*.
            ///
            /// - Parameter threshold: A value after a `local_maximum` value have to be less then `threshold`×`local_maximum`.
            @inlinable
            public init<S>(threshold: Threshold, with values: S, callback: @escaping Callback)
            where S : Sequence, S.Element == SourceValue
            {
                self.init(threshold: threshold, callback: callback)
                process(values)
            }



            // MARK: .Threshold

            public struct Threshold {

                /// First argument (lhs) is a maximum candidate, second is an other element.
                /// Returns a boolean value indicating whether lhs is greater then rhs enough to be considered as a local maximum.
                public typealias Predicate = (Value, Value) -> Bool


                /// First argument (lhs) is a maximum candidate, second is an other element.
                /// Returns a boolean value indicating whether lhs is greater then rhs enough to be considered as a local maximum.
                public let predicate: Predicate


                @inlinable
                public init(predicate: @escaping Predicate) {
                    self.predicate = predicate
                }

            }



            // MARK: .SourceValue

            public struct SourceValue {

                public typealias Value = Stream.Value
                public typealias Note = Stream.Note


                public var value: Value
                public var note: Note


                @inlinable
                public init(_ value: Value, note: Note) {
                    self.value = value
                    self.note = note
                }

            }



            // MARK: .State

            /// It's internal to be used in @usableFromInline code.
            @usableFromInline
            internal enum State {
                case initial
                case minimum(Value)
                case candidate(SourceValue)
            }



            // MARK: Operations

            @inlinable
            public mutating func processAndReset(_ value: SourceValue) {
                process(value)
                reset()
            }


            @inlinable
            public mutating func processAndReset<S>(_ values: S) where S : Sequence, S.Element == SourceValue {
                process(values)
                reset()
            }

            /// - Note: Call *reset()* to commit deferred results.
            @inlinable
            public mutating func process(_ next: SourceValue) {
                switch state {
                case .candidate(let candidate):
                    if threshold.predicate(candidate.value, next.value) {
                        callback(candidate)
                        state = .minimum(next.value)
                    }
                    else if next.value > candidate.value {
                        state = .candidate(next)
                    }

                case .minimum(let minimum):
                    state = threshold.predicate(next.value, minimum) ? .candidate(next) : .minimum(min(minimum, next.value))

                case .initial:
                    state = .candidate(next)
                }
            }


            /// - Note: Call *reset()* to commit deferred results.
            @inlinable
            public mutating func process<S>(_ values: S) where S : Sequence, S.Element == SourceValue {
                values.forEach { process($0) }
            }


            /// - Note: Call *reset()* to commit deferred results.
            @inlinable
            public mutating func process(_ value: Value, note: Note) { process(SourceValue(value, note: note)) }


            @inlinable
            public mutating func processAndReset(_ value: Value, note: Note) { processAndReset(SourceValue(value, note: note)) }


            @inlinable
            public mutating func reset() {
                switch state {
                case .candidate(let candidate):
                    callback(candidate)
                case .initial, .minimum:
                    break
                }

                state = .initial
            }

        }

    }

}


extension KvStatistics.LocalMaximum.Stream.SourceValue where Note == Void {

    @inlinable
    public init(_ value: Value) { self.init(value, note: ()) }

}


extension KvStatistics.LocalMaximum.Stream where Note == Void {

    /// - Parameter threshold: A value after a local maximum have to be less then *threshold*×the_maximum.
    @inlinable
    public init(threshold: Threshold, callback: @escaping (Value) -> Void) {
        self.init(threshold: threshold, callback: { callback($0.value) } as Callback)
    }


    @inlinable
    public mutating func processAndReset(_ value: Value) {
        processAndReset(SourceValue(value))
    }


    @inlinable
    public mutating func processAndReset<S>(_ values: S) where S : Sequence, S.Element == Value {
        processAndReset(values.lazy.map { SourceValue($0) }) }

    /// - Note: Call *flush()* to commit deferred results.
    @inlinable
    public mutating func process(_ value: Value) {
        process(SourceValue(value))
    }


    /// - Note: Call *flush()* to commit deferred results.
    @inlinable
    public mutating func process<S>(_ values: S) where S : Sequence, S.Element == Value {
        process(values.lazy.map { SourceValue($0) })
    }

}


extension KvStatistics.LocalMaximum.Stream.Threshold where Value : AdditiveArithmetic {

    // MARK: .absolute

    @inlinable
    public static func absolute(_ delta: Value) -> Self {
        .init { maximum, other in
            other < maximum - delta
        }
    }

}


extension KvStatistics.LocalMaximum.Stream.Threshold where Value : Numeric {

    // MARK: .relative

    @inlinable
    public static func relative(_ ratio: Value) -> Self {
        .init { maximum, other in
            other < maximum * ratio
        }
    }

}


extension KvStatistics.LocalMaximum.Stream.SourceValue : Equatable where Value : Equatable, Note : Equatable { }


extension KvStatistics.LocalMaximum where Value : Numeric {

    /// Invokes callback for each local maximum in *values* sequence.
    ///
    /// - Parameter threshold: A value after a local maximum have to be less then *threshold*×the_maximum.
    @inlinable
    public static func run<Values>(with values: Values, threshold: Value, callback: (Value, inout Bool) -> Void)
    where Values : Sequence, Values.Element == Value
    {
        let minimumRatio = 1 - threshold

        var iterator = values.makeIterator()

        guard var prev = iterator.next() else { return }

        var candidate = Optional(prev)
        var stopFlag = false


        while let value = iterator.next() {
            if candidate != nil {
                if value > candidate! {
                    candidate = value

                } else if value < candidate! * minimumRatio {
                    callback(candidate!, &stopFlag)

                    guard !stopFlag else { return }

                    candidate = nil
                }

            } else if value > prev {
                candidate = value
            }

            prev = value
        }

        if candidate != nil {
            callback(candidate!, &stopFlag)
        }
    }



    /// Invokes callback for each local maximum in *values* sequence transformed with *map* block.
    ///
    /// - Parameter threshold: A value after a local maximum have to be less then *threshold*×the_maximum.
    @inlinable
    public static func run<Values>(with values: Values, threshold: Value, map: (Values.Element) -> Value, callback: (Values.Element, Value, inout Bool) -> Void)
    where Values : Sequence
    {
        typealias Element = (value: Values.Element, map: Value)


        let minimumRatio = 1 - threshold

        var iterator = values.makeIterator()

        guard let firstValue = iterator.next() else { return }

        var prev: Element = (firstValue, map(firstValue))
        var candidate = Optional(prev)
        var stopFlag = false


        while let value = iterator.next() {
            let element: Element = (value, map(value))

            if candidate != nil {
                if element.map > candidate!.map {
                    candidate = element

                } else if element.map < candidate!.map * minimumRatio {
                    callback(candidate!.value, candidate!.map, &stopFlag)

                    guard !stopFlag else { return }

                    candidate = nil
                }

            } else if element.map > prev.map {
                candidate = element
            }

            prev = element
        }

        if candidate != nil {
            callback(candidate!.value, candidate!.map, &stopFlag)
        }
    }

}
