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
//  KvStatistics.swift
//  kvKit
//
//  Created by Svyatoslav Popov on 08.06.2019.
//

import Foundation
import Accessibility



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
    public class Average<Value : FloatingPoint> {

        // MARK: .Processor

        /// Simple average online algorithm that is less prone to loss of precision due to catastrophic cancellation.
        public struct Processor : KvStatisticsAverageProcessor {

            public private(set) var average: Value = 0

            public private(set) var count: Int = 0 {
                didSet { invCount = count != 0 ? 1 / Value(count) : 0 }
            }

            public private(set) var invCount: Value = 0



            public init() { }



            public init<S>(_ values: S) where S : Sequence, S.Element == Value {
                process(values)
            }



            // MARK: : KvStatisticsAverageStream

            @inlinable
            public func nextAverage(for value: Value) -> Value { average + (value - average) / Value(count + 1) }



            // MARK: : KvStatisticsStream

            public mutating func process(_ value: Value) {
                count += 1
                average.addProduct(value - average, invCount)
            }



            @inlinable
            public mutating func process<S>(_ values: S) where S : Sequence, S.Element == Value {
                values.forEach { process($0) }
            }



            public mutating func process<C>(_ values: C) where C : Collection, C.Element == Value {
                count += values.count

                average = values.reduce(average, { $0.addingProduct($1 - average, invCount) })
            }



            public mutating func reset() {
                average = 0
                count = 0
            }



            // MARK: : KvStatisticsProcessor

            public mutating func rollback(_ value: Value) {
                count -= 1
                average.addProduct(average - value, invCount)
            }



            @inlinable
            public mutating func rollback<S>(_ values: S) where S : Sequence, S.Element == SourceValue {
                values.forEach { rollback($0) }
            }



            public mutating func rollback<C>(_ values: C) where C : Collection, C.Element == SourceValue {
                count -= values.count

                average = values.reduce(average, { $0.addingProduct(average - $1, invCount) })
            }



            public mutating func replace(_ oldValue: Value, with newValue: Value) {
                average.addProduct(newValue - oldValue, invCount)
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

            public private(set) var average: Value = 0

            public private(set) var buffer: KvCircularBuffer<Value>


            @inlinable
            public var count: Int { return buffer.count }
            @inlinable
            public var capacity: Int { return buffer.capacity }


            public let invCapacity: Value



            public init(capacity: Int) {
                buffer = .init(capacity: capacity)

                invCapacity = 1 / Value(capacity)
            }



            public init<S>(capacity: Int, _ values: S) where S : Sequence, S.Element == Value {
                self.init(capacity: capacity)

                process(values)
            }



            // MARK: : KvStatisticsAverageStream

            @inlinable
            public func nextAverage(for value: Value) -> Value {
                count < capacity ? average + (value - average) / Value(count + 1) : average.addingProduct(value - buffer.first!, invCapacity)
            }



            // MARK: KvStatisticsStream Protocol

            public mutating func process(_ value: Value) {
                if let excludedValue = buffer.append(value) {
                    average.addProduct(value - excludedValue, invCapacity)

                } else {
                    average += (value - average) / Value(buffer.count)
                }
            }



            public mutating func process<S>(_ values: S) where S : Sequence, S.Element == Value {
                values.forEach { process($0) }
            }



            public mutating func process<C>(_ values: C) where C : Collection, C.Element == Value {
                guard values.count < buffer.capacity else {
                    average = values[values.index(values.endIndex, offsetBy: -buffer.capacity)...].reduce(0, { $0.addingProduct($1, invCapacity) })
                    return
                }

                let k = buffer.capacity - buffer.count
                let m = values.count - k

                let index = m > 0 ? values.index(values.startIndex, offsetBy: k) : values.endIndex

                if k > 0 {
                    average = values[..<index].reduce(average, { $0.addingProduct($1 - average, invCapacity) })
                }

                if m > 0 {
                    var iterator = buffer.makeIterator()

                    average = values[index...].reduce(average, { $0.addingProduct($1 - iterator.next()!, invCapacity) })
                }
            }



            public mutating func reset() {
                average = 0
                buffer.removeAll()
            }
        }

    }

}



// MARK: - .WeightedMean

extension KvStatistics {

    /// Weighted mean.
    public class WeightedMean<Value : FloatingPoint> {

        // MARK: .MovingStream

        /// Weighted moving average online algorithm that is less prone to loss of precision due to catastrophic cancellation.
        public struct MovingStream : KvStatisticsAverageStream {

            public var average: Value { zip(buffer, weights).reduce(0, { $0.addingProduct($1.0, $1.1) }) }

            public private(set) var buffer: KvCircularBuffer<Value>


            @inlinable
            public var count: Int { return buffer.count }

            public var capacity: Int { return weights.count }



            public init<Weights>(initialValue: Value = 0, weights: Weights) where Weights : Sequence, Weights.Element == Value {
                let scale: Value = {
                    let totalWeight = weights.reduce(0, +)

                    return abs(totalWeight) >= .ulpOfOne ? 1 / totalWeight : 0
                }()

                self.weights = weights.map { $0 * scale }   // Normalization of weights.

                buffer = .init(capacity: self.weights.count, repeating: initialValue)
            }



            private let weights: [Value]



            // MARK: : KvStatisticsAverageStream

            public func nextAverage(for value: Value) -> Value {
                var valueIterator = buffer.makeIterator()
                var weightIterator = weights.makeIterator()

                _ = valueIterator.next()    // Skip first value

                let sum: Value = (0..<(capacity - 1)).reduce(0, { (result, _) in result.addingProduct(weightIterator.next()!, valueIterator.next()!) })

                return sum + weightIterator.next()! * value
            }



            // MARK: : KvStatisticsStream

            public mutating func process(_ value: Value) {
                buffer.append(value)
            }



            @inlinable
            public mutating func process<S>(_ values: S) where S : Sequence, S.Element == Value {
                values.forEach { process($0) }
            }



            @inlinable
            public mutating func process<C>(_ values: C) where C : Collection, C.Element == Value {
                values.forEach { process($0) }
            }



            public mutating func reset() {
                buffer.removeAll()
            }

        }

    }

}



// MARK: - .ExponentialMean

extension KvStatistics {

    /// Exponential mean.
    public class ExponentialMean<Value : FloatingPoint> {

        // MARK: .Stream

        /// Exponential average online algorithm that is less prone to loss of precision due to catastrophic cancellation.
        public struct Stream : KvStatisticsAverageStream {

            public let period: Int
            public let alpha: Value

            public private(set) var average: Value = 0

            public private(set) var count: Int = 0



            public init(period: Int, alpha: Value) {
                assert(period > 0 && alpha >= 0 && alpha <= 1)

                self.period = period
                self.alpha = alpha

                oneMinusAlpha = 1 - alpha
            }



            private let oneMinusAlpha: Value



            // MARK: : KvStatisticsAverageStream

            public func nextAverage(for value: Value) -> Value {
                alpha * value + oneMinusAlpha * average
            }



            // MARK: : KvStatisticsStream

            public mutating func process(_ value: Value) {
                average = count > 0 ? alpha * value + oneMinusAlpha * average : value

                count += 1
            }



            public mutating func process<S>(_ values: S) where S : Sequence, S.Element == Value {
                var iterator = values.makeIterator()

                if count == 0 {
                    guard let value = iterator.next() else { return }

                    average = value
                    count = 1
                }

                while let value = iterator.next() {
                    average = alpha * value + oneMinusAlpha * average
                    count += 1
                }
            }



            public mutating func process<C>(_ values: C) where C : Collection, C.Element == Value {
                var iterator = values.makeIterator()

                if count == 0 {
                    guard let value = iterator.next() else { return }

                    average = value
                }

                while let value = iterator.next() {
                    average = alpha * value + oneMinusAlpha * average
                }

                count += values.count
            }



            public mutating func reset() {
                average = 0
                count = 0
            }

        }

    }

}



// MARK: .RMS

extension KvStatistics {

    /// Root mean square
    public class RMS<Value : FloatingPoint> {

        // MARK: .Processor

        /// Root mean square online algorithm that is less prone to loss of precision due to catastrophic cancellation.
        public struct Processor : KvStatisticsAverageProcessor {

            public var average: Value { return avgProcessor.average.squareRoot() }

            public var count: Int { return avgProcessor.count }



            public init() { }



            public init<S>(_ values: S) where S : Sequence, S.Element == Value {
                process(values)
            }



            private var avgProcessor = Average<Value>.Processor()



            // MARK: : KvStatisticsAverageStream

            public func nextAverage(for value: Value) -> Value {
                avgProcessor.nextAverage(for: value * value).squareRoot()
            }



            // MARK: : KvStatisticsStream

            public mutating func process(_ value: Value) {
                avgProcessor.process(value * value)
            }



            public mutating func process<S>(_ values: S) where S : Sequence, S.Element == Value {
                avgProcessor.process(values.lazy.map { $0 * $0 })
            }



            public mutating func reset() { avgProcessor.reset() }



            // MARK: : KvStatisticsProcessor

            public mutating func rollback(_ value: Value) { avgProcessor.rollback(value * value) }



            public mutating func rollback<S>(_ values: S) where S : Sequence, S.Element == Value {
                avgProcessor.rollback(values.lazy.map { $0 * $0 })
            }



            public mutating func rollback<C>(_ values: C) where C : Collection, C.Element == Value {
                avgProcessor.rollback(values.lazy.map { $0 * $0 })
            }



            public mutating func replace(_ oldValue: Value, with newValue: Value) {
                avgProcessor.replace(oldValue * oldValue, with: newValue * newValue)
            }



            public mutating func replace<S>(_ oldValues: S, with newValues: S) where S : Sequence, S.Element == Value {
                avgProcessor.replace(oldValues.lazy.map { $0 * $0 }, with: newValues.lazy.map { $0 * $0 })
            }

        }



        // MARK: .MovingStream

        /// Moving root mean square online algorithm that is less prone to loss of precision due to catastrophic cancellation.
        public struct MovingStream : KvStatisticsAverageStream {

            public var average: Value { return avgStream.average.squareRoot() }

            public var capacity: Int { return avgStream.capacity }
            public var count: Int { return avgStream.count }



            public init(capacity: Int) {
                avgStream = .init(capacity: capacity)
            }



            public init<S>(capacity: Int, _ values: S) where S : Sequence, S.Element == Value {
                self.init(capacity: capacity)
                
                process(values)
            }



            private var avgStream: Average<Value>.MovingStream



            // MARK: : KvStatisticsAverageStream

            public func nextAverage(for value: Value) -> Value {
                avgStream.nextAverage(for: value * value).squareRoot()
            }



            // MARK: : KvStatisticsStream

            public mutating func process(_ value: Value) { avgStream.process(value * value) }



            public mutating func process<S>(_ values: S) where S : Sequence, S.Element == Value {
                avgStream.process(values.lazy.map { $0 * $0 })
            }



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

    public class Variance<Value : FloatingPoint> {

        // MARK: .Processor

        /// Welford's online variance algorithm. The algorithm is less prone to loss of precision due to catastrophic cancellation.
        public struct Processor : KvStatisticsVarianceProcessor {

            @inlinable
            public var standardDeviation: Value { variance.squareRoot() }

            public var variance: Value { value(divider: avgProcessor.count) }


            @inlinable
            public var unbiasedStandardDeviation: Value { unbiasedVariance.squareRoot() }

            public var unbiasedVariance: Value { value(divider: avgProcessor.count - 1) }


            public private(set) var moment: Value = 0


            public private(set) var average: Value = 0


            public var count: Int { return avgProcessor.count }



            public init() { }



            private var avgProcessor = Average<Value>.Processor()



            // MARK: Auxiliaries

            private func value(divider: Int) -> Value { divider > 0 ? moment / Value(divider) : 0 }



            // MARK: : KvStatisticsStream

            public mutating func process(_ value: Value) {
                avgProcessor.process(value)

                let newAverage = avgProcessor.average
                defer { average = newAverage }

                moment.addProduct(value - average, value - newAverage)

                #if DEBUG
                if KvIsNegative(moment) {
                    KvDebug.pause("The moment (\(moment)) must be positive")
                }
                #endif // DEBUG
            }



            @inlinable
            public mutating func process<S>(_ values: S) where S : Sequence, S.Element == Value {
                values.forEach { process($0) }
            }



            public mutating func reset() {
                moment = 0
                average = 0
                avgProcessor.reset()
            }



            // MARK: : KvStatisticsProcessor

            public mutating func rollback(_ value: Value) {
                avgProcessor.rollback(value)

                let newAverage = avgProcessor.average
                defer { average = newAverage }

                moment.addProduct(value - average, newAverage - value)

                #if DEBUG
                if KvIsNegative(moment) {
                    KvDebug.pause("The moment (\(moment)) must be positive")
                }
                #endif // DEBUG
            }



            @inlinable
            public mutating func rollback<S>(_ values: S) where S : Sequence, S.Element == SourceValue {
                values.forEach { rollback($0) }
            }



            public mutating func replace(_ oldValue: Value, with newValue: Value) {
                avgProcessor.replace(oldValue, with: newValue)

                let newAverage = avgProcessor.average
                defer { average = newAverage }

                moment.addProduct(newValue - oldValue, newValue - newAverage + oldValue - average)

                #if DEBUG
                if KvIsNegative(moment) {
                    KvDebug.pause("The moment (\(moment)) must be positive")
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

            public var variance: Value {
                let count = self.count

                return max(0, count < capacity ? value(divider: count) : (moment * invCapacity))
            }


            @inlinable
            public var unbiasedStandardDeviation: Value { unbiasedVariance.squareRoot() }

            public var unbiasedVariance: Value {
                let count = self.count

                return max(0, count < capacity ? value(divider: count - 1) : (moment * invCapacityMinusOne))
            }


            public private(set) var moment: Value = 0


            public private(set) var average: Value = 0


            public var count: Int { return avgStream.count }
            public var capacity: Int { return avgStream.capacity }


            public let invCapacity: Value
            public let invCapacityMinusOne: Value



            public init(capacity: Int) {
                assert(capacity >= 2)

                avgStream = .init(capacity: capacity)

                invCapacity = 1 / Value(capacity)
                invCapacityMinusOne = 1 / Value(capacity - 1)
            }



            private var avgStream: Average<Value>.MovingStream



            // MARK: Auxiliaries

            private func value(divider: Int) -> Value {
                divider > 0 ? moment / Value(count) : 0
            }



            // MARK: : KvStatisticsStream

            public mutating func process(_ value: Value) {
                if count < capacity {
                    avgStream.process(value)

                    let newAverage = avgStream.average
                    defer { average = newAverage }

                    moment.addProduct(value - average, value - newAverage)

                } else {
                    let excludedValue = avgStream.buffer.first!

                    avgStream.process(value)

                    let newAverage = avgStream.average
                    defer { average = newAverage }

                    moment.addProduct(value - excludedValue, value - average + excludedValue - newAverage)
                }
            }



            @inlinable
            public mutating func process<S>(_ values: S) where S : Sequence, S.Element == Value {
                values.forEach { process($0) }
            }



            public mutating func reset() {
                moment = 0
                average = 0
                avgStream.reset()
            }

        }



        // MARK: .Moment

        /// Offline variance algorithm.
        public struct Moment {

            public let value, average, count: Value


            public private(set) lazy var standardDeviation: Value = count > 0 ? (value / count).squareRoot() : 0

            public private(set) lazy var variance: Value = count > 0 ? value / count : 0

            public private(set) lazy var unbiasedStandardDeviation: Value = { $0 > 0 ? (value / $0).squareRoot() : 0 }(count - 1 as Value)

            public private(set) lazy var unbiasedVariance: Value = { $0 > 0 ? value / $0 : 0 }(count - 1 as Value)



            public init<S>(_ values: S) where S: Sequence, S.Element == Value {
                var average: Value = 0, count: Value = 0

                value = values.reduce(0) { (moment, x) in
                    count += 1

                    let newAverage = average + (x - average) / count
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

            /// - Returns: The moment value for [ 1∙d, 2∙d, ..., n∙d ].
            public static func moment(d: Value, n: Int) -> Value {
                d * d * Value(n * (n * n - 1)) * (1 / 12)
            }


            /// - Returns: The moment value for [ 1, 2, ..., n ].
            public static func moment(n: Int) -> Value {
                Value(n * (n * n - 1)) * (1 / 12)
            }



            /// - Returns: Standard deviation value for [ 1∙d, 2∙d, ..., n∙d ].
            public static func standardDeviation(d: Value, n: Int) -> Value {
                d * (Value(n * n - 1) * (1 / 12)).squareRoot()
            }


            /// - Returns: Standard deviation value for [ 1, 2, ..., n ].
            public static func standardDeviation(n: Int) -> Value {
                (Value(n * n - 1) * (1 / 12)).squareRoot()
            }



            /// - Returns: Variance value for [ 1∙d, 2∙d, ..., n∙d ].
            public static func variance(d: Value, n: Int) -> Value {
                d * d * Value(n * n - 1) * (1 / 12)
            }


            /// - Returns: Variance value for [ 1, 2, ..., n ].
            public static func variance(n: Int) -> Value {
                Value(n * n - 1) * (1 / 12)
            }



            /// - Returns: Unbiased standard deviation value for [ 1∙d, 2∙d, ..., n∙d ].
            public static func unbiasedStandardDeviation(d: Value, n: Int) -> Value {
                d * (Value(n * (n + 1)) * (1 / 12)).squareRoot()
            }


            /// - Returns: Unbiased standard deviation value for [ 1, 2, ..., n ].
            public static func unbiasedStandardDeviation(n: Int) -> Value {
                (Value(n * (n + 1)) * (1 / 12)).squareRoot()
            }



            /// - Returns: Unbiased variance value for [ 1∙d, 2∙d, ..., n∙d ].
            public static func unbiasedVariance(d: Value, n: Int) -> Value {
                d * d * (Value(n * (n + 1)) * (1 / 12))
            }


            /// - Returns: Unbiased variance value for [ 1, 2, ..., n ].
            public static func unbiasedVariance(n: Int) -> Value {
                (Value(n * (n + 1)) * (1 / 12))
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

    public class Covariance<Value : BinaryFloatingPoint> {

        public typealias SourceValue = (Value, Value)



        // MARK: .Processor

        /// Analog of Welford's online algorithm for variance. The algorithm is less prone to loss of precision due to catastrophic cancellation.
        public struct Processor : KvStatisticsCovarianceProcessor {

            public var covariance: Value { value(divider: count) }

            public var unbiasedCovariance: Value { value(divider: count - 1) }


            public private(set) var comoment: Value = 0


            public private(set) var average: SourceValue = (0, 0)


            public var count: Int { return avgProcessor.0.count }



            public init() { }



            private var avgProcessor = (Average<Value>.Processor(), Average<Value>.Processor())



            // MARK: Auxiliaries

            private func value(divider: Int) -> Value {
                divider > 0 ? comoment / Value(divider) : 0
            }



            public mutating func process(_ v0: Value, _ v1: Value) {
                avgProcessor.0.process(v0)
                average.0 = avgProcessor.0.average

                comoment.addProduct(v0 - average.0, v1 - average.1)

                avgProcessor.1.process(v1)
                average.1 = avgProcessor.1.average
            }



            public mutating func rollback(_ v0: Value, _ v1: Value) {
                avgProcessor.1.rollback(v1)
                average.1 = avgProcessor.1.average

                comoment.addProduct(v0 - average.0, average.1 - v1)

                avgProcessor.0.rollback(v0)
                average.0 = avgProcessor.0.average
            }



            public mutating func replace(_ old0: Value, _ old1: Value, with new0: Value, _ new1: Value) {
                avgProcessor.0.replace(old0, with: new0)
                average.0 = avgProcessor.0.average

                comoment.addProduct(new0 - average.0, new1 - old1)
                comoment.addProduct(new0 - old0, old1 - average.1)

                avgProcessor.1.replace(old1, with: new1)
                average.1 = avgProcessor.1.average
            }



            // MARK: : KvStatisticsStream

            @inlinable
            public mutating func process(_ value: SourceValue) { process(value.0, value.1) }



            @inlinable
            public mutating func process<S>(_ values: S) where S : Sequence, S.Element == SourceValue {
                values.forEach { process($0.0, $0.1) }
            }



            public mutating func reset() {
                comoment = 0
                average = (0, 0)
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

            public private(set) var buffer: KvCircularBuffer<SourceValue>


            @inlinable
            public var count: Int { return buffer.count }

            @inlinable
            public var capacity: Int { return buffer.capacity }



            public init(capacity: Int) {
                buffer = .init(capacity: capacity)
            }



            private var covarianceProcessor: Processor = .init()



            // MARK: : KvStatisticsCovarianceStream

            public var covariance: Value { covarianceProcessor.covariance }

            public var unbiasedCovariance: Value { covarianceProcessor.unbiasedCovariance }

            public var comoment: Value { covarianceProcessor.comoment }



            // MARK: : KvStatisticsStream

            public mutating func process(_ value: SourceValue) {
                if let oldValue = buffer.append(value) {
                    covarianceProcessor.replace(oldValue, with: value)
                } else {
                    covarianceProcessor.process(value)
                }
            }



            @inlinable
            public mutating func process<S>(_ values: S) where S : Sequence, S.Element == SourceValue {
                values.forEach { process($0) }
            }



            public mutating func reset() {
                buffer.removeAll()
                covarianceProcessor.reset()
            }

        }



        /// Offline covariance algorithm.
        public struct Comoment {

            public let value: Value
            public let average: (x: Value, y: Value)
            public let count: Value


            public private(set) lazy var covariance: Value = count > 0 ? value / count : 0

            public private(set) lazy var unbiasedCovariance: Value = { $0 > 0 ? value / $0 : 0 }(count - 1 as Value)



            public init<S₁, S₂>(x xs: S₁, y ys: S₂) where S₁: Sequence, S₁.Element == Value, S₂: Sequence, S₂.Element == Value {
                var average: (Value, Value) = (0, 0), count: Value = 0

                value = zip(xs, ys).reduce(0) { (comoment, values) in
                    count += 1
                    let oneByCount = 1 / count

                    let newAverage = (average.0 + (values.0 - average.0) * oneByCount, average.1 + (values.1 - average.1) * oneByCount)
                    defer { average = newAverage }

                    return comoment.addingProduct(values.0 - newAverage.0, values.1 - average.1)
                }

                self.average = average
                self.count = count
            }



            public init<S>(dx: Value = 1, y values: S) where S: Sequence, S.Element == Value {
                var average: (x: Value, y: Value) = (-0.5, 0), count: Value = 0

                value = dx * values.reduce(0) { (comoment, value) in
                    count += 1

                    let newAverage = (x: average.x + 0.5, y: average.y + (value - average.y) / count)
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

            public var correlation: Value { covarianceProcessor.comoment / sqrt(varianceProcessors.0.moment * varianceProcessors.1.moment) }



            public init() { }



            public init<S>(_ points: S) where S : Sequence, S.Element == Point {
                varianceProcessors.0.process(points.lazy.map { $0.0 })
                varianceProcessors.1.process(points.lazy.map { $0.1 })
                covarianceProcessor.process(points)
            }



            public init<S0, S1>(_ s0: S0, _ s1: S1) where S0 : Sequence, S0.Element == Value, S1 : Sequence, S1.Element == Value {
                varianceProcessors.0.process(s0)
                varianceProcessors.1.process(s1)
                covarianceProcessor.process(zip(s0, s1))
            }



            private var varianceProcessors = (Variance<Value>.Processor(), Variance<Value>.Processor())
            private var covarianceProcessor = Covariance<Value>.Processor()



            // MARK: : KvStatisticsStream

            public mutating func process(_ value: Point) {
                varianceProcessors.0.process(value.0)
                varianceProcessors.1.process(value.1)
                covarianceProcessor.process(value)
            }



            @inlinable
            public mutating func process<S>(_ values: S) where S : Sequence, S.Element == Point {
                values.forEach { process($0) }
            }



            public mutating func reset() {
                varianceProcessors.0.reset()
                varianceProcessors.1.reset()
                covarianceProcessor.reset()
            }



            // MARK: : KvStatisticsProcessor

            public mutating func rollback(_ value: Point) {
                varianceProcessors.0.rollback(value.0)
                varianceProcessors.1.rollback(value.1)
                covarianceProcessor.rollback(value)
            }



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

            public private(set) var minimum: Value = 0
            public private(set) var maximum: Value = 0

            public private(set) var count: Int = 0



            public init() { }



            // MARK: Auxiliaries

            mutating private func updateBounds(with value: Value) {
                if count > 0 {
                    if value > maximum {
                        maximum = value
                    } else if value < minimum {
                        minimum = value
                    }

                } else {
                    minimum = value
                    maximum = value
                }
            }



            // MARK: : KvStatisticsStream

            public mutating func process(_ value: Value) {
                updateBounds(with: value)

                count += 1
            }



            @inlinable
            public mutating func process<S>(_ values: S) where S : Sequence, S.Element == Value {
                values.forEach { process($0) }
            }



            public mutating func process<C>(_ values: C) where C : Collection, C.Element == Value {
                values.forEach { updateBounds(with: $0) }

                count += values.count
            }



            public mutating func reset() {
                minimum = 0
                maximum = 0
                count = 0
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

            public var minimum: Value { return minMaxStream.minimum }
            public var maximum: Value { return minMaxStream.maximum }
            public var average: Value { return avgProcessor.average }

            public var count: Int { return avgProcessor.count }



            public init() { }



            private var minMaxStream = KvStatistics.MinMax<Value>.Stream()
            private var avgProcessor = KvStatistics.Average<Value>.Processor()



            // MARK: Auxiliaries

            public func nextAverage(for value: Value) -> Value {
                avgProcessor.nextAverage(for: value)
            }



            // MARK: : KvStatisticsStream

            public mutating func process(_ value: Value) {
                minMaxStream.process(value)
                avgProcessor.process(value)
            }



            public mutating func process<S>(_ values: S) where S : Sequence, S.Element == Value {
                minMaxStream.process(values)
                avgProcessor.process(values)
            }



            public mutating func process<C>(_ values: C) where C : Collection, C.Element == Value {
                minMaxStream.process(values)
                avgProcessor.process(values)
            }



            public mutating func reset() {
                minMaxStream.reset()
                avgProcessor.reset()
            }



            // MARK: : CustomStringConvertible

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

    public class LinearRegression<Value : BinaryFloatingPoint> {

        public typealias Scalar = Value
        public typealias Point = (x: Scalar, y: Scalar)

        public typealias Line = KvShiftedLinearMapping<Scalar>



        // MARK: .Processor

        /// Linear regression online algorithm.
        public struct Processor : KvStatisticsLinearRegressionProcessor {

            public var k: Value {
                let moment = varianceProcessor.moment
                return moment >= .ulpOfOne ? covarianceProcessor.comoment / moment : 0
            }
            public var b: Value { return covarianceProcessor.average.1 - k * covarianceProcessor.average.0 }

            public var line: Line { .init(k: k, x₀: covarianceProcessor.average.0, y₀: covarianceProcessor.average.1) }



            public init() { }



            private var varianceProcessor = Variance<Value>.Processor()
            private var covarianceProcessor = Covariance<Value>.Processor()



            // MARK: Auxiliaries

            public mutating func process(x: Value, y: Value) {
                varianceProcessor.process(x)
                covarianceProcessor.process(x, y)
            }



            public mutating func rollback(x: Value, y: Value) {
                varianceProcessor.rollback(x)
                covarianceProcessor.rollback(x, y)
            }



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

            public var k: Value { linearRegressionProcessor.k }
            public var b: Value { linearRegressionProcessor.b }

            public var line: Line { linearRegressionProcessor.line }


            public private(set) var buffer: KvCircularBuffer<Point>


            @inlinable
            public var count: Int { buffer.count }

            @inlinable
            public var capacity: Int { buffer.capacity }



            public init(capacity: Int) {
                buffer = .init(capacity: capacity)
            }



            private var linearRegressionProcessor: Processor = .init()



            // MARK: Auxiliaries

            @inlinable
            public mutating func process(x: Value, y: Value) { process((x, y)) }



            // MARK: : KvStatisticsStream

            public mutating func process(_ value: Point) {
                if let oldValue = buffer.append(value) {
                    linearRegressionProcessor.replace(x: oldValue.x, y: oldValue.y, withX: value.x, y: value.y)
                } else {
                    linearRegressionProcessor.process(x: value.x, y: value.y)
                }
            }



            @inlinable
            public mutating func process<S>(_ values: S) where S : Sequence, S.Element == Point {
                values.forEach { process($0) }
            }



            public mutating func reset() {
                buffer.removeAll()
                linearRegressionProcessor.reset()
            }

        }



        /// An offline implementation for arbitrary sequences of x and y values.
        public static func line<S₁, S₂>(x xs: S₁, y ys: S₂) -> Line where S₁: Sequence, S₁.Element == Value, S₂: Sequence, S₂.Element == Value {
            .init(.init(x: xs, y: ys), Variance<Value>.Moment(xs).value)
        }



        /// An offline implementation for arbitrary sequence of y values where x values are index offsets in y value sequence.
        public static func line<S>(_ values: S) -> Line where S: Sequence, S.Element == Value {
            let comoment = Covariance<Value>.Comoment(y: values)
            let moment = Variance<Value>.Uniform.moment(n: Int(comoment.count))

            return .init(comoment, moment)
        }

    }

}



// MARK: .LocalMaximum

extension KvStatistics {

    /// Local Maximums
    public class LocalMaximum<Value : Comparable> {

        public typealias Value = Value


        /// Note generic argument is desinated to help process deferred invocations of *callback*. Use *Void* if note is unused.
        public struct Stream<Note> : KvStatisticsStream {

            public typealias Value = LocalMaximum.Value
            public typealias Note = Note

            public typealias Callback = (SourceValue) -> Void


            public let threshold: Threshold


            /// - Parameter threshold: A value after a local maximum have to be less then *threshold*×the_maximum.
            public init(threshold: Threshold, callback: @escaping Callback) {
                self.threshold = threshold
                self.callback = callback
            }


            private let callback: Callback

            private var state: State = .initial


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

            private enum State {
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
