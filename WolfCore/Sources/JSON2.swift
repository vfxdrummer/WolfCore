//
//  JSON2.swift
//  WolfCore
//
//  Created by Robert McNally on 6/18/16.
//  Copyright © 2016 Arciem. All rights reserved.
//

import Foundation

public final class JSON2 {
    public typealias Value = Any?
    public typealias Array = [Value]
    public typealias Dictionary = [String: Value]

    private static let space: Character = " "
    private static let tab: Character = "\t"
    private static let newline: Character = "\n"
    private static let carriageReturn: Character = "\r"

    private static let openBracket: Character = "["
    private static let closeBracket: Character = "]"
    private static let openBrace: Character = "{"
    private static let closeBrace: Character = "}"
    private static let comma: Character = ","
    private static let colon: Character = ":"

    private static let quoteMark: Character = "\""
    private static let reverseSolidus: Character = "\\"

    private static let literalFalse = "false"
    private static let literalTrue = "true"
    private static let literalNull = "null"

    static public let null: Any? = nil

    public final class Reader {
        private let string: String
        private var index: String.Index

        public enum Error: ErrorProtocol {
            case noTopLevelObjectOrArray
            case unexpectedEndOfData
            case unknownValue
            case unterminatedArray
            case keyExpected
            case nameSeparatorExpected
            case unterminatedDictionary
            case unterminatedString
            case unterminatedEscapeSequence
            case unknownEscapeSequence
            case malformedNumber
        }

        private init(string: String) {
            self.string = string
            index = string.startIndex
        }

        private var hasMore: Bool {
            return index != string.endIndex
        }

        private var nextCharacter: Character {
            return string[index]
        }

        private func advance() {
            index = string.index(after: index)
        }

        private func advance(by offset: Int) {
            index = string.index(index, offsetBy: offset)
        }

        private func advance(ifNextCharacterIs character: Character) -> Bool {
            guard hasMore else { return false }
            if character == nextCharacter {
                advance()
                return true
            }
            return false
        }

        private func advance(ifNextCharacterIsNot character: Character) -> Bool {
            guard hasMore else { return false }
            if character != nextCharacter {
                advance()
                return true
            }
            return false
        }

        private func advance(ifNextCharacterIsIn characters: [Character]) -> Bool {
            guard hasMore else { return false }
            if characters.contains(nextCharacter) {
                advance()
                return true
            }
            return false
        }

        private static let whitespace = [JSON2.space, JSON2.tab, JSON2.newline, JSON2.carriageReturn]

        private func skipWhitespace() throws {
            repeat { } while advance(ifNextCharacterIsIn: Reader.whitespace)
            guard hasMore else { throw Error.unexpectedEndOfData }
        }

        private func parseValue(allowsFragment: Bool = true) throws -> JSON2.Value {
            try skipWhitespace()
            if let array = try parseArray() {
                return array
            }

            if let dictionary = try parseDictionary() {
                return dictionary
            }

            guard allowsFragment else { throw Error.noTopLevelObjectOrArray }

            if let string = try parseString() {
                return string
            }

            if let number = try parseNumber() {
                return number
            }

            if let bool = try parseBool() {
                return bool
            }

            if try parseNull() {
                return nil
            }

            throw Error.unknownValue
        }

        private func parseArray() throws -> JSON2.Array? {
            guard advance(ifNextCharacterIs: JSON2.openBracket) else { return nil }
            var array = JSON2.Array()
            repeat {
                try skipWhitespace()
                guard !advance(ifNextCharacterIs: JSON2.closeBracket) else { return array }
                try skipWhitespace()
                let value = try parseValue()
                array.append(value)
                try skipWhitespace()
            } while advance(ifNextCharacterIs: JSON2.comma)
            return array
        }

        private func parseDictionary() throws -> JSON2.Dictionary? {
            guard advance(ifNextCharacterIs: JSON2.openBrace) else { return nil }
            var dictionary = JSON2.Dictionary()
            repeat {
                try skipWhitespace()
                guard !advance(ifNextCharacterIs: JSON2.closeBrace) else { return dictionary }
                guard let key = try parseString() else { throw Error.keyExpected }
                try skipWhitespace()
                guard advance(ifNextCharacterIs: JSON2.colon) else { throw Error.nameSeparatorExpected }
                try skipWhitespace()
                let value = try parseValue()
                dictionary[key] = value
                try skipWhitespace()
            } while advance(ifNextCharacterIs: JSON2.comma)
            try skipWhitespace()
            return dictionary
        }

        private func parseString() throws -> String? {
            guard advance(ifNextCharacterIs: JSON2.quoteMark) else { return nil }
            var string = ""
            repeat {
                guard hasMore else { throw Error.unterminatedString }
                let character = nextCharacter
                advance()
                switch character {
                case JSON2.quoteMark:
                    return string
                case JSON2.reverseSolidus:
                    string.append(try parseEscapeSequence())
                default:
                    string.append(character)
                }
            } while true
        }

        private func parseEscapeSequence() throws -> Character {
            guard hasMore else { throw Error.unterminatedEscapeSequence }
            let character = nextCharacter
            advance()
            switch character {
            case JSON2.quoteMark:
                return JSON2.quoteMark
            case JSON2.reverseSolidus:
                return JSON2.reverseSolidus
            case "t":
                return JSON2.tab
            case "n":
                return JSON2.newline
            case "r":
                return JSON2.carriageReturn
            default:
                throw Error.unknownEscapeSequence
            }
        }

        private static let numberPrefixRegex = try! ~/"^[0-9-]"
        private static let numberRegex = try! ~/"^-?(0|([1-9][0-9]*))(\\.[0-9]+)?(e[+-][0-9]+)?"

        private func parseNumber() throws -> Double? {
            let substring = string.substring(from: index)
            guard Reader.numberPrefixRegex ~? substring else { return nil }
            let matches = Reader.numberRegex ~?? substring
            guard let firstMatch = matches.first else { throw Error.malformedNumber }
            let (_, numberStr) = firstMatch.get(atIndex: 0, inString: substring)
            advance(by: numberStr.characters.count)
            guard let value = Double(numberStr) else { throw Error.malformedNumber }
            return value
        }

        private func parseBool() throws -> Bool? {
            let s = string.substring(from: index)
            if s.hasPrefix(JSON2.literalTrue) {
                advance(by: JSON2.literalTrue.characters.count)
                return true
            } else if s.hasPrefix(JSON2.literalFalse) {
                advance(by: JSON2.literalFalse.characters.count)
                return false
            }
            return nil
        }

        private func parseNull() throws -> Bool {
            let s = string.substring(from: index)
            if s.hasPrefix(JSON2.literalNull) {
                advance(by: JSON2.literalNull.characters.count)
                return true
            }
            return false
        }
    }

    public class Writer {
        private var string = ""

        public enum Error: ErrorProtocol {
            case noTopLevelObjectOrArray
            case unknownValue
        }

        private func emit(_ character: Character) {
            string.append(character)
        }

        private func emit(_ string: String) {
            self.string.append(string)
        }

        private func emit(string: String) {
            emit("\"\(string)\"")
        }

        private func emit(number: Double) {
            emit("\(number)")
        }

        private func emit(bool: Bool) {
            emit(bool ? JSON2.literalTrue : JSON2.literalFalse)
        }

        private func emit(dictionary: Dictionary) throws {
            emit(JSON2.openBrace)
            var first = true
            for (key, value) in dictionary {
                if first {
                    first = false
                } else {
                    emit(JSON2.comma)
                }
                emit(string: key)
                emit(JSON2.colon)
                try emit(value: value, allowsFragment: true)
            }
            emit(JSON2.closeBrace)
        }

        private func emit(array: Array) throws {
            emit(JSON2.openBracket)
            var first = true
            for value in array {
                if first {
                    first = false
                } else {
                    emit(JSON2.comma)
                }
                try emit(value: value, allowsFragment: true)
            }
            emit(JSON2.closeBracket)
        }

        private func emit(value: Value, allowsFragment: Bool) throws {
            guard let value = value else {
                if allowsFragment {
                    emit(JSON2.literalNull)
                    return
                } else {
                    throw Error.unknownValue
                }
            }

            switch value {
            case let dictionary as Dictionary:
                try emit(dictionary: dictionary)
            case let array as Array:
                try emit(array: array)
            default:
                break
            }

            guard allowsFragment else {
                throw Error.noTopLevelObjectOrArray
            }

            switch value {
            case let string as String:
                emit(string: string)
            case let number as Double:
                emit(number: number)
            case let bool as Bool:
                emit(bool: bool)
            default:
                throw Error.unknownValue
            }
        }
    }

    public static func object(from string: String, allowsFragment: Bool) throws -> Value {
        let reader = Reader(string: string)
        return try reader.parseValue(allowsFragment: allowsFragment)
    }

    public static func object(from string: String) throws -> Value {
        return try object(from: string, allowsFragment: false)
    }

    public static func string(from value: Value, allowsFragment: Bool) throws -> String {
        let writer = Writer()
        try writer.emit(value: value, allowsFragment: allowsFragment)
        return writer.string
    }

    public static func string(from object: Value) throws -> String {
        return try string(from: object, allowsFragment: false)
    }
}

public func JSON2Test() {
    do {
        let raw = "{\"color\": \"red\", \"age\": 51, \"awesome\": true, \"array\": [1, 2, false, null]}"
        print(raw)
        let json = try raw |> JSON2.object
        print(json)
        let value = try json |> JSON2.string
        print(value)
    } catch let error {
        print(error)
    }
}