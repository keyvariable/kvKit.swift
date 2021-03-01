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
//  KvStringKit.swift
//  kvKit
//
//  Created by Svyatoslav Popov on 19.02.2018.
//

import Foundation



/// Collection of string auxliliaries.
public class KvStringKit { }



// MARK: Normalizarion

extension KvStringKit {

    /// - Parameter string: A string where the whitespace is to be normalized.
    ///
    /// - Returns: Result of removing leading, trailing and consecutive space from given *string*.
    ///
    /// - Note: The result for "␣␣Dianne's␣\n␣horse.\n␣␣\n␣MBPro␣␣16\n\n" is ""Dianne's␣horse.\nMBPro␣16".
    @inlinable
    public static func normalizingWhitespace(for string: String) -> String {
        string
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "(?<=\\s)\\s+", with: "", options: .regularExpression, range: nil)
    }



    /// - Returns: A copy string of source string where leading sharaters of each sentence are capitalized.
    public static func capitalizingSentences(in string: String) -> String {
        var result = string

        #if !os(Linux)
        string.enumerateSubstrings(in: string.startIndex ..< string.endIndex, options: [ .bySentences, .reverse, .substringNotRequired ]) { (_, range, _, _) in
            result.replaceSubrange(range.lowerBound ..< result.index(after: range.lowerBound),
                                   with: string[range.lowerBound ..< string.index(after: range.lowerBound)].uppercased())
        }

        #else // os(Linux)

        enum State { case waitingForLetter, waitingForSeparator }

        var state: State = .waitingForLetter
        var range = result.startIndex ..< result.endIndex

        while !range.isEmpty {
            switch state {
            case .waitingForLetter:
                guard let characterRange = result.rangeOfCharacter(from: CharacterSet.letters, options: [ ], range: range) else {
                    range = range.upperBound ..< range.upperBound
                    break
                }

                result.replaceSubrange(characterRange, with: result[characterRange].uppercased())

                state = .waitingForSeparator
                range = result.index(after: characterRange.lowerBound) ..< range.upperBound

            case .waitingForSeparator:
                guard let characterRange = result.rangeOfCharacter(from: sentenceSeparators, options: [ ], range: range) else {
                    range = range.upperBound ..< range.upperBound
                    break
                }

                state = .waitingForLetter
                range = characterRange.upperBound ..< range.upperBound
            }
        }
        #endif // os(Linux)

        return result
    }

}



// MARK: Constants

extension KvStringKit {

    /// Non-breaking space.
    public static let nbsp = "\u{00a0}"


    /// Punctuation characters separating sentences.
    public static let sentenceSeparators = CharacterSet([ ".", "!", "?", "…" ])

}



// MARK: Digits

extension KvStringKit {

    @inlinable
    public static func digit<T: BinaryInteger>(for c: Character) -> T? {
        switch c {
        case "0":
            return 0
        case "1":
            return 1
        case "2":
            return 2
        case "3":
            return 3
        case "4":
            return 4
        case "5":
            return 5
        case "6":
            return 6
        case "7":
            return 7
        case "8":
            return 8
        case "9":
            return 9
        default:
            return nil
        }
    }



    @inlinable
    public static func charater<T: BinaryInteger>(forDigit digit: T) -> Character? {
        switch digit {
        case 0:
            return "0"
        case 1:
            return "1"
        case 2:
            return "2"
        case 3:
            return "3"
        case 4:
            return "4"
        case 5:
            return "5"
        case 6:
            return "6"
        case 7:
            return "7"
        case 8:
            return "8"
        case 9:
            return "9"
        default:
            return nil
        }
    }



    @inlinable
    public static func hexDigit<T: BinaryInteger>(for c: Character) -> T? {
        switch c {
        case "0":
            return 0
        case "1":
            return 1
        case "2":
            return 2
        case "3":
            return 3
        case "4":
            return 4
        case "5":
            return 5
        case "6":
            return 6
        case "7":
            return 7
        case "8":
            return 8
        case "9":
            return 9
        case "a", "A":
            return 10
        case "b", "B":
            return 11
        case "c", "C":
            return 12
        case "d", "D":
            return 13
        case "e", "E":
            return 14
        case "f", "F":
            return 15
        default:
            return nil
        }
    }



    @inlinable
    public static func charater<T: BinaryInteger>(forHexDigit hexDigit: T, uppercase: Bool = false) -> Character? {
        switch hexDigit {
        case 0:
            return "0"
        case 1:
            return "1"
        case 2:
            return "2"
        case 3:
            return "3"
        case 4:
            return "4"
        case 5:
            return "5"
        case 6:
            return "6"
        case 7:
            return "7"
        case 8:
            return "8"
        case 9:
            return "9"
        case 10:
            return uppercase ? "A" : "a"
        case 11:
            return uppercase ? "B" : "b"
        case 12:
            return uppercase ? "C" : "c"
        case 13:
            return uppercase ? "D" : "d"
        case 14:
            return uppercase ? "E" : "e"
        case 15:
            return uppercase ? "F" : "f"
        default:
            return nil
        }
    }



    /// - Returns: A string with hexadecimal representation of given data.
    @inlinable
    public static func base16<Bytes>(with bytes: Bytes, separator: String = " ", limit: Int = .max) -> String
    where Bytes : Sequence, Bytes.Element == UInt8
    {
        bytes.lazy
            .prefix(limit)
            .map({ String(format: "%02X", $0) })
            .joined(separator: separator)
    }

}



// MARK: Values and Types

extension KvStringKit {

    public static let optionalNone = "`nil`"



    /// - Returns: *x* if it isn't `nil` or  quotted nil string.
    @inlinable
    public static func with(_ x: String?) -> String {
        switch x {
        case .some(let x):
            return x != optionalNone ? x : ".some(\"\(x)\")"
        case .none:
            return optionalNone
        }
    }



    /// - Returns: Compact string representatin of *x* if it isn't `nil` or  value of *KvStringKit.optionalNone*.
    @inlinable
    public static func with<T>(_ x: T?) -> String {
        x != nil ? "\(x!)" : optionalNone
    }



    /// - Returns: Compact string representatin of *x* if it isn't `nil` or  value of *KvStringKit.optionalNone*.
    @inlinable
    public static func with<T>(_ x: T?) -> String where T : Sequence {
        switch x {
        case .some(let x):
            return "[ \(x.lazy.map(with(_:)).joined(separator: ", ")) ]"
        case .none:
            return optionalNone
        }
    }



    /// - Returns: Compact string representatin of *x* if it isn't `nil` or  value of *KvStringKit.optionalNone*.
    @inlinable
    public static func with<T, E>(_ x: T?) -> String where T : Sequence, T.Element == E? {
        switch x {
        case .some(let x):
            return "[ \(x.lazy.map(with(_:)).joined(separator: ", ")) ]"
        case .none:
            return optionalNone
        }
    }



    /// - Returns: Compact string representatin of *x* if it isn't `nil` or  value of *KvStringKit.optionalNone*.
    @inlinable
    public static func with<T>(_ x: T?) -> String where T : Sequence, T.Element : Sequence {
        switch x {
        case .some(let x):
            return "[ \(x.lazy.map(with(_:)).joined(separator: ", ")) ]"
        case .none:
            return optionalNone
        }
    }



    /// - Returns: Hexadecimal representation of given sequence.
    @inlinable
    public static func with<Bytes>(hex bytes: Bytes, separator: String = " ", limit: Int = 256) -> String
    where Bytes : Sequence, Bytes.Element == UInt8
    {
        base16(with: bytes, separator: separator, limit: limit)
    }



    /// - Returns: String containig `type(of: x)` if it isn't `nil` or  "T?".
    @inlinable
    public static func withType<T>(of x: T?) -> String {
        switch x {
        case .some(let wrapped):
            return "\(type(of: wrapped))"
        case .none:
            return "\(T.self)?"
        }
    }



    /// - Returns: String representation of `ObjectIdentifier(x)` if it isn't `nil` or value of *KvStringKit.optionalNone*.
    @inlinable
    public static func withObjectID<T>(of x: T?) -> String where T : AnyObject {
        switch x {
        case .some(let x):
            return withObjectID(of: x)
        case .none:
            return optionalNone
        }
    }



    /// - Returns: String representation of `ObjectIdentifier(x)`.
    @inlinable
    public static func withObjectID<T>(of x: T) -> String where T : AnyObject { "\(ObjectIdentifier(x))" }

}



// MARK: Bundle Info Dictionary

extension KvStringKit {

    /// - Returns: Result of *KvStringKit.with(_:)* with value for *CFBundleName* key from the info dictionary of given *bundle*.
    public static func withApplicationName(_ bundle: Bundle = .main) -> String {
        with(KvBundleKit.applicationName(bundle))
    }



    /// - Returns: Result of *KvStringKit.with(_:)* with value for *CFBundleShortVersionString* key from the info dictionary of given *bundle*.
    public static func withShortVersion(_ bundle: Bundle = .main) -> String? {
        with(KvBundleKit.shortVersion(bundle))
    }



    /// - Returns: Result of *KvStringKit.with(_:)* with value for *CFBundleVersion* key from the info dictionary of given *bundle*.
    public static func withBundleVection(_ bundle: Bundle = .main) -> String? {
        with(KvBundleKit.bundleVection(bundle))
    }

}



// MARK: NSRange Auxiliaries

extension KvStringKit {

    @inlinable
    public static func nsRange(for string: String) -> NSRange {
        NSRange(string.startIndex ..< string.endIndex, in: string)
    }



    @inlinable
    public static func nsRange(for range: Range<Int>, in string: String) -> NSRange {
        let startIndex = range.lowerBound > 0 ? string.index(string.startIndex, offsetBy: range.lowerBound) : string.startIndex
        let endIndex = range.upperBound < string.count ? string.index(startIndex, offsetBy: range.upperBound - range.lowerBound) : string.endIndex

        return NSRange(startIndex ..< endIndex, in: string)
    }

}



// MARK: Swift Range Auxiliaries

extension KvStringKit {

    @inlinable
    public static func indexBounds(from: Int, to: Int, in string: String, relativeTo originIndex: String.Index? = nil) -> (lower: String.Index, upper: String.Index) {
        let startIndex = string.index(originIndex ?? string.startIndex, offsetBy: from)
        let endIndex = string.index(startIndex, offsetBy: to - from)

        return (startIndex, endIndex)
    }



    @inlinable
    public static func indexRange(for range: Range<Int>, in string: String, relativeTo originIndex: String.Index? = nil) -> Range<String.Index> {
        let (startIndex, endIndex) = self.indexBounds(from: range.lowerBound, to: range.upperBound, in: string, relativeTo: originIndex)

        return startIndex ..< endIndex
    }



    @inlinable
    public static func indexRange(for range: ClosedRange<Int>, in string: String, relativeTo originIndex: String.Index? = nil) -> ClosedRange<String.Index> {
        let (startIndex, endIndex) = self.indexBounds(from: range.lowerBound, to: range.upperBound, in: string, relativeTo: originIndex)

        return startIndex ... endIndex
    }

}



// MARK: Punycode

extension KvStringKit {

    /// Decodes *source* string from Punycode encoding using algorithm described in RFC-3492 paper (https://tools.ietf.org/html/rfc3492).
    public static func from<S>(punycode source: S) -> String where S : StringProtocol {
        guard !source.isEmpty else { return "" }

        var result: String
        let codes: S.SubSequence

        (result, codes) = {
            guard let delimiterIndex = source.lastIndex(of: "-") else { return ("", source[source.startIndex...]) }

            return (String(source[..<delimiterIndex]), source[source.index(after: delimiterIndex)...])
        }()


        func Digit(for character: Character) -> Int {
            let ascii = Int(character.asciiValue!)

            switch ascii {
            case 48...57:   // '0' ... '9'
                return 26 + ascii - 48
            case 65...90:   // 'A' ... 'Z'
                return ascii - 65
            case 97...122:  // 'a' ... 'z'
                return ascii - 97
            default:
                fatalError("Unexpected Punycode digit character «\(character)»")
            }
        }


        let base         = 36
        let tmin         = 1
        let tmax         = 26
        let skew         = 38
        let damp         = 700
        let initial_bias = 72
        let initial_n    = 128

        var n = initial_n
        var i = 0
        var bias = initial_bias

        var codeIterator = codes.makeIterator()
        var character = codeIterator.next()

        while character != nil {
            let oldi = i
            var w = 1
            var k = base

            while true {
                let digit = Digit(for: character!)
                character = codeIterator.next()

                i = i + digit * w
                let t = max(tmin, min(tmax, k - bias))

                guard digit >= t else { break }

                w *= (base - t)
                k += base
            }

            bias = {
                var delta = (i - oldi) / (oldi == 0 ? damp : 2)
                delta += delta / (result.count + 1)

                var k = 0

                while delta > ((base - tmin) * tmax) / 2 {
                    delta /= (base - tmin)
                    k += base
                }

                return k + (((base - tmin + 1) * delta) / (delta + skew))
            }()

            let d: Int
            (d, i) = i.quotientAndRemainder(dividingBy: result.count + 1)
            n += d

            result.insert(.init(Unicode.Scalar(n)!), at: result.index(result.startIndex, offsetBy: i))

            i += 1
        }

        return result
    }

}



// MARK: Composing

extension KvStringKit {

    public static func append<S1, S2>(_ string: inout String, with component: S1, separator: S2) where S1 : StringProtocol, S2 : StringProtocol {
        if !string.isEmpty {
            string.append(contentsOf: separator)
        }

        string.append(contentsOf: component)
    }



    public static func append<S1, S2>(_ string: inout String, with firstComponent: S1, _ secondComponent: S1, _ otherComponents: S1..., separator: S2)
        where S1 : StringProtocol, S2 : StringProtocol
    {
        append(&string, with: firstComponent, separator: separator)

        string.append(contentsOf: separator)
        string.append(contentsOf: secondComponent)

        otherComponents.forEach { (component) in
            string.append(contentsOf: separator)
            string.append(contentsOf: component)
        }
    }

}
