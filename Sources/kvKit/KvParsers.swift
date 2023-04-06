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
//  KvParsers.swift
//  kvKit
//
//  Created by Svyatoslav Popov on 10.10.2018.
//

import Foundation



// MARK: - KvParserProcessing

public protocol KvParserProcessing {

    /// A string containing accumulated input if available.
    var input: String? { get }


    mutating func process<S>(_ string: S) where S: StringProtocol

}



// MARK: - KvParser

public protocol KvParser : KvParserProcessing {

    associatedtype Value


    var value: Value { get }


    init<S>(with initialInput: S?, options: KvParserOptions?) where S: StringProtocol

}



// MARK: - KvParserOptions

public struct KvParserOptions : OptionSet {

    public static let noInputAccumulation = KvParserOptions(rawValue: 1 << 0)


    // MARK: : OptionSet

    public var rawValue: UInt


    public init(rawValue: UInt) { self.rawValue = rawValue }

}



// MARK: - KvIntParser

/// Stream based converter from string to an integer.
///
/// FSM implementation of integer number parser with support of sign symbols and hexadimical format.
///
/// Mode transitions:
///
/// **`Mode.signDecZ`**
/// * ±    -> `Mode.decZ`
/// * 0    -> `Mode.decX`
/// * dec  -> `Mode.dec`
/// * else -> error
///
/// **`Mode.decZ`**
/// * 0    -> `Mode.decX`
/// * dec  -> `Mode.dec`
/// * else -> error
///
/// **`Mode.decX`**
/// * dec  -> `Mode.dec`
/// * x    -> `Mode.hexr`
/// * else -> error
///
/// **`Mode.dec`**
/// * dec  -> continue
/// * else -> error
///
/// **`Mode.hexr`**
/// * hex  -> `Mode.hex`
/// * else -> error
///
/// **`Mode.hex`**
/// * hex  -> continue
/// * else -> error
///
/// where
/// * dec — decimal character
/// * hex — hexadecimal character
///
public struct KvIntParser<T: BinaryInteger> : KvParser {

    public private(set) var value: Value = .none

    public private(set) var input: String?



    public init<S>(with initialInput: S? = nil, options: KvParserOptions? = nil) where S: StringProtocol {
        input = options?.contains(.noInputAccumulation) != true ? "" : nil

        if let initialInput = initialInput {
            process(initialInput)
        }
    }



    private var mode: Mode = .signDecZ

    private var number: T = 0
    private var isNegative = false



    // MARK: Processing

    public func get() -> Result<T, Error> {
        switch value {
        case .some(let number):
            return .success(number)
        case .error(let message):
            return .failure(KvError(message))
        case .incomplete:
            return .failure(KvError("KvIntParser state is .incomplete"))
        case .none:
            return .failure(KvError("KvIntParser state is .none"))
        }
    }



    public mutating func process<S>(_ string: S) where S: Sequence, S.Element == Character {
        defer { input?.append(contentsOf: string) }


        switch value {
        case .none, .some, .incomplete:
            break
        case .error:
            return
        }

        for c in string {
            switch mode {
            case .signDecZ:
                switch c {
                case "+":
                    mode = .decZ
                case "-", "–":
                    isNegative = true
                    mode = .decZ
                case "0":
                    mode = .decX
                default:
                    guard let digit: T = KvStringKit.digit(for: c) else {
                        value = .error("Unexpected character «\(c)» while converting string «\(string)» to \(T.self)")
                        return
                    }
                    number = digit
                    mode = .dec
                }

            case .decZ:
                guard let digit: T = KvStringKit.digit(for: c) else {
                    value = .error("Unexpected character «\(c)» while converting string «\(string)» to \(T.self)")
                    return
                }
                if digit != 0 {
                    appendDigit(digit, radix: 10)
                    mode = .dec
                } else {
                    mode = .decX
                }

            case .decX:
                switch c {
                case "x", "X":
                    mode = .hexr
                default:
                    guard let digit: T = KvStringKit.digit(for: c) else {
                        value = .error("Unexpected character «\(c)» while converting string «\(string)» to \(T.self)")
                        return
                    }
                    appendDigit(digit, radix: 10)
                    mode = .dec
                }

            case .dec:
                guard let digit: T = KvStringKit.digit(for: c) else {
                    value = .error("Unexpected character «\(c)» while converting string «\(string)» to \(T.self)")
                    return
                }
                appendDigit(digit, radix: 10)

            case .hexr:
                guard let hexDigit: T = KvStringKit.hexDigit(for: c) else {
                    value = .error("Unexpected character «\(c)» while converting string «\(string)» to \(T.self)")
                    return
                }
                appendDigit(hexDigit, radix: 16)
                mode = .hex

            case .hex:
                guard let hexDigit: T = KvStringKit.hexDigit(for: c) else {
                    value = .error("Unexpected character «\(c)» while converting string «\(string)» to \(T.self)")
                    return
                }
                appendDigit(hexDigit, radix: 16)
            }
        }

        switch mode {
        case .signDecZ:
            value = .none
        case .decZ, .hexr:
            value = .incomplete
        case .decX, .dec, .hex:
            value = .some(number)
        }
    }



    private mutating func appendDigit(_ digit: T, radix: T) {
        #if DEBUG
        if digit < 0 || digit >= radix {
            KvDebug.pause("Internal inconsistency: digit \(digit) is out of range 0..<\(radix)")
        }
        #endif // DEBUG

        isNegative ? (number = radix * number - digit) : (number = radix * number + digit)
    }



    // MARK: .Value

    public enum Value : Equatable {

        case none, some(T), incomplete, error(String)


        var number: T? {
            guard case .some(let n) = self else { return nil }

            return n
        }

    }



    // MARK: .Mode

    private enum Mode {
        case signDecZ, decZ, decX, dec, hexr, hex
    }

}



// MARK: - KvFloatParser

/// Stream based conterter from string to a floating point number.
///
/// FSM implementation of floating point number parser with support of sign symbols, exponential format and hexadimical format.
///
/// Mode transitions:
///
/// **`Mode.signDecDotI`**
/// * ±    -> `Mode.decDotI`
/// * 0    -> `Mode.decDotXE`
/// * dec  -> `Mode.decDotE`
/// * dot  -> `Mode.decf`
/// * I    -> `Mode.infN`
/// * i    -> `Mode.infN`
/// * else -> error
///
/// **`Mode.decDotI`**
/// * 0    -> `Mode.decDotXE`
/// * dec  -> `Mode.decDotE`
/// * dot  -> `Mode.decf`
/// * I    -> `Mode.infN`
/// * i    -> `Mode.infN`
/// * else -> error
///
/// **`Mode.decDotXE`**
/// * dec  -> `Mode.decDotE`
/// * dot  -> `Mode.decE`
/// * x    -> `Mode.hexr`
/// * e    -> `Mode.signDec`
/// * else -> error
///
/// **`Mode.decDotE`**
/// * dec  -> continue
/// * dot  -> `Mode.decE`
/// * e    -> `Mode.signDec`
/// * else -> error
///
/// **`Mode.decf`**
/// * dec  -> `Mode.decE`
/// * else -> error
///
/// **`Mode.decE`**
/// * dec  -> continue
/// * e    -> `Mode.signDec`
/// * else -> error
///
/// **`Mode.hexr`**
/// * hex  -> `Mode.hex`
/// * else -> error
///
/// **`Mode.hex`**
/// * hex  -> continue
/// * else -> error
///
/// **`Mode.signDec`**
/// * ±    -> `Mode.dece`
/// * dec  -> `Mode.dec`
/// * else -> error
///
/// **`Mode.dece`**
/// * dec  -> `Mode.dec`
/// * else -> error
///
/// **`Mode.dec`**
/// * dec  -> continue
/// * else -> error
///
/// **`Mode.infN`**
/// * N -> `Mode.infF`
/// * n -> `Mode.infF`
/// * else -> error
///
/// **`Mode.infF`**
/// * F -> `Mode.infComplete`
/// * f -> `Mode.infComplete`
/// * else -> error
///
/// **`Mode.infComplete`**
/// * else -> error
///
/// where
/// * dec — decimal character
/// * hex — hexadecimal character
/// * dot — dot character, integer-fractional delimiter
/// * e   — exponential delimiter - ‘e’
///
public struct KvFloatParser<T: BinaryFloatingPoint> : KvParser {

    public private(set) var value: Value = .none

    public private(set) var input: String?



    public init<S>(with initialInput: S? = nil, options: KvParserOptions? = nil) where S: StringProtocol {
        input = options?.contains(.noInputAccumulation) != true ? "" : nil

        if let initialInput = initialInput {
            process(initialInput)
        }
    }



    private var mode: Mode = .signDecDotI

    private var isNegative = false
    private var number: T = 0

    private var fractionDigitDivider: T = 10

    private var isExpValueNegative = false
    private var expValue: Int = 0



    // MARK: Processing

    public func get() -> Result<T, Error> {
        switch value {
        case .some(let number):
            return .success(number)
        case .error(let message):
            return .failure(KvError(message))
        case .incomplete:
            return .failure(KvError("KvIntParser state is .incomplete"))
        case .none:
            return .failure(KvError("KvIntParser state is .none"))
        }
    }



    public mutating func process<S>(_ string: S) where S: Sequence, S.Element == Character {
        defer { input?.append(contentsOf: string) }


        switch value {
        case .none, .some, .incomplete:
            break
        case .error:
            return
        }

        for c in string {
            switch mode {
            case .signDecDotI:
                switch c {
                case "+":
                    mode = .decDotI
                case "-", "–":
                    isNegative = true
                    mode = .decDotI
                case ".":
                    mode = .decf
                case "0":
                    mode = .decDotXE
                case "I", "i":
                    mode = .infN
                default:
                    guard let digit: Int = KvStringKit.digit(for: c) else {
                        value = .error("Unexpected character «\(c)» while converting string «\(string)» to \(T.self)")
                        return
                    }
                    number = T(digit)
                    mode = .decDotE
                }

            case .decDotI:
                switch c {
                case ".":
                    mode = .decf
                case "0":
                    mode = .decDotXE
                case "I", "i":
                    mode = .infN
                default:
                    guard let digit: Int = KvStringKit.digit(for: c) else {
                        value = .error("Unexpected character «\(c)» while converting string «\(string)» to \(T.self)")
                        return
                    }
                    appendIntegerDigit(digit, radix: 10)
                    mode = .decDotE
                }

            case .decDotXE:
                switch c {
                case ".":
                    mode = .decE
                case "x", "X":
                    mode = .hexr
                case "e", "E":
                    mode = .signDec
                default:
                    guard let digit: Int = KvStringKit.digit(for: c) else {
                        value = .error("Unexpected character «\(c)» while converting string «\(string)» to \(T.self)")
                        return
                    }
                    appendIntegerDigit(digit, radix: 10)
                    mode = .decDotE
                }

            case .decDotE:
                switch c {
                case ".":
                    mode = .decE
                case "e", "E":
                    mode = .signDec
                default:
                    guard let digit: Int = KvStringKit.digit(for: c) else {
                        value = .error("Unexpected character «\(c)» while converting string «\(string)» to \(T.self)")
                        return
                    }
                    appendIntegerDigit(digit, radix: 10)
                }

            case .decf:
                guard let digit: Int = KvStringKit.digit(for: c) else {
                    value = .error("Unexpected character «\(c)» while converting string «\(string)» to \(T.self)")
                    return
                }
                appendFractionDigit(digit)
                mode = .decE

            case .decE:
                switch c {
                case "e", "E":
                    mode = .signDec
                default:
                    guard let digit: Int = KvStringKit.digit(for: c) else {
                        value = .error("Unexpected character «\(c)» while converting string «\(string)» to \(T.self)")
                        return
                    }
                    appendFractionDigit(digit)
                }

            case .hexr:
                guard let hexDigit: Int = KvStringKit.hexDigit(for: c) else {
                    value = .error("Unexpected character «\(c)» while converting string «\(string)» to \(T.self)")
                    return
                }
                appendIntegerDigit(hexDigit, radix: 16)
                mode = .hex

            case .hex:
                guard let hexDigit: Int = KvStringKit.hexDigit(for: c) else {
                    value = .error("Unexpected character «\(c)» while converting string «\(string)» to \(T.self)")
                    return
                }
                appendIntegerDigit(hexDigit, radix: 16)

            case .signDec:
                switch c {
                case "+":
                    mode = .dece
                case "-", "–":
                    isExpValueNegative = true
                    mode = .dece
                default:
                    guard let digit: Int = KvStringKit.digit(for: c) else {
                        value = .error("Unexpected character «\(c)» while converting string «\(string)» to \(T.self)")
                        return
                    }
                    appendExpDigit(digit)
                    mode = .dec
                }

            case .dece:
                guard let digit: Int = KvStringKit.digit(for: c) else {
                    value = .error("Unexpected character «\(c)» while converting string «\(string)» to \(T.self)")
                    return
                }
                appendExpDigit(digit)
                mode = .dec

            case .dec:
                guard let digit: Int = KvStringKit.digit(for: c) else {
                    value = .error("Unexpected character «\(c)» while converting string «\(string)» to \(T.self)")
                    return
                }
                appendExpDigit(digit)

            case .infN:
                switch c {
                case "N", "n":
                    mode = .infF
                default:
                    value = .error("Unexpected character «\(c)» while converting string «\(string)» to \(T.self)")
                    return
                }

            case .infF:
                switch c {
                case "F", "f":
                    mode = .infComplete
                default:
                    value = .error("Unexpected character «\(c)» while converting string «\(string)» to \(T.self)")
                    return
                }

            case .infComplete:
                value = .error("Unexpected character «\(c)» while converting string «\(string)» to \(T.self)")
                return
            }
        }

        switch mode {
        case .signDecDotI:
            value = .none
        case .decDotI, .decf, .hexr, .signDec, .dece, .infN, .infF:
            value = .incomplete
        case .decDotXE, .decDotE, .decE, .hex, .dec:
            value = .some(expValue != 0 ? number * T(pow(10.0, Double(expValue))) : number)
        case .infComplete:
            value = .some(isNegative ? -.infinity : .infinity)
        }

        //dece — incomplete
    }



    private mutating func appendIntegerDigit(_ digit: Int, radix: T) {
        #if DEBUG
        if digit < 0 || digit >= Int(radix) {
            KvDebug.pause("Internal inconsistency: integer digit \(digit) is out of range 0...\(Int(radix) - 1)")
        }
        #endif // DEBUG

        isNegative ? (number = radix * number - T(digit)) : (number = radix * number + T(digit))
    }


    private mutating func appendFractionDigit(_ digit: Int) {
        if digit < 0 || digit >= 10 {
            KvDebug.pause("Internal inconsistency: integer digit \(digit) is out of range 0...9")
        }

        isNegative ? (number -= T(digit) / fractionDigitDivider) : (number += T(digit) / fractionDigitDivider)
        fractionDigitDivider *= 10
    }


    private mutating func appendExpDigit(_ digit: Int) {
        if digit < 0 || digit >= 10 {
            KvDebug.pause("Internal inconsistency: integer digit \(digit) is out of range 0...9")
        }

        isExpValueNegative ? (expValue = 10 * expValue - digit) : (expValue = 10 * expValue + digit)
    }



    // MARK: .Value

    public enum Value : Equatable {

        case none, some(T), incomplete, error(String)


        var number: T? {
            guard case .some(let n) = self else { return nil }

            return n
        }

    }



    // MARK: .Mode

    private enum Mode {
        case signDecDotI
        case decDotI
        case decDotXE
        case decDotE
        case decf           // Decimal in fraction part
        case decE           // Decimal or ‘e’ character
        case hexr           // Hexadimical digit required
        case hex            // Hexadimical digit (not required)
        case signDec
        case dece           // Decimal in exponential part
        case dec
        case infN           // ‘n’ character of ‘inf’ literal.
        case infF           // ‘f’ character of ‘inf’ literal.
        case infComplete    // Any character causes error.
    }

}



// MARK: - KvStringParser

/// String accumulator.
public struct KvStringParser : KvParser {

    public var value: Value { return input != nil ? .some(input!) : .none }

    public private(set) var input: String?



    public init<S>(with initialInput: S? = nil, options: KvParserOptions? = nil) where S: StringProtocol {
        input = options?.contains(.noInputAccumulation) != true ? "" : nil

        if let initialInput = initialInput {
            process(initialInput)
        }
    }



    // MARK: Processing

    public mutating func process<S>(_ string: S) where S: Sequence, S.Element == Character {
        input?.append(contentsOf: string) ?? (input = String(string))
    }



    // MARK: .Value

    public enum Value {

        case none, some(String)


        var string: String? {
            guard case .some(let s) = self else { return nil }

            return s
        }

    }

}



// MARK: - KvBoolParser

/// Stream based converter from string to boolean.
public struct KvBoolParser : KvParser {

    public var value: Value {
        guard input?.isEmpty == false else { return .none }

        let normalizedInput = input!.lowercased()

        if KvBoolParser.trueLiterals.contains(normalizedInput) {
            return .some(true)
        } else if KvBoolParser.falseLiterals.contains(normalizedInput) {
            return .some(false)
        } else {
            return .error("Unable to interpret «\(input!)» as a boolean value")
        }
    }

    public private(set) var input: String? = ""



    public static let trueLiterals: Set<String> = [ "true", "yes", "y", "1" ]
    public static let falseLiterals: Set<String> = [ "false", "no", "n", "0" ]



    public init<S>(with initialInput: S? = nil, options: KvParserOptions? = nil) where S: StringProtocol {
        if let initialInput = initialInput {
            process(initialInput)
        }
    }



    // MARK: Processing

    public mutating func process<S>(_ string: S) where S: Sequence, S.Element == Character {
        input?.append(contentsOf: string)
    }



    // MARK: .Value

    public enum Value {
        case none, some(Bool), error(String)
    }

}
