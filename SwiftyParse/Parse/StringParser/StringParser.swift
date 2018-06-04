//
//  StringParser2.swift
//  SwiftyParse
//
//  Created by LZephyr on 2018/4/7.
//  Copyright © 2018年 LZephyr. All rights reserved.
//

import Foundation

// MARK: - InputString

/// 作为数据源输入的字符串
struct InputString {
    let characters: [Character] // 剩余的字符
    let row: Int // 当前位置在原始输入中的行号
    let column: Int // 当前位置在原始输入中的列号
}

extension InputString: Sequence {
    typealias Element = Character
    typealias Iterator = Array<Character>.Iterator
    
    func makeIterator() -> Iterator {
        return self.characters.makeIterator()
    }
}

extension InputString: Equatable {
    static func == (_ lhs: InputString, _ rhs: InputString) -> Bool {
        return lhs.characters == rhs.characters && lhs.row == rhs.row && lhs.column == rhs.column
    }
}

extension InputString {
    /// 去掉第一个字符，向前进一位，重新计算当前的位置
    func dropFirst() -> InputString {
        let (first, remain) = self.characters.decompose()
        if let first = first {
            switch first {
            case "\n":
                return InputString(characters: remain, row: 0, column: column + 1)
            case "\t":
                return InputString(characters: remain, row: row + 8, column: column)
            default:
                return InputString(characters: remain, row: row + 1, column: column)
            }
        }
        return InputString(characters: remain, row: row, column: column)
    }
    
    /// 去掉前n个字符
    func drop(_ n: Int) -> InputString {
        var result: InputString = self
        for _ in 0..<n {
            result = result.dropFirst()
        }
        return result
    }
    
    /// 获取第一个字符
    func first() -> Character? {
        return self.characters.first
    }
    
    /// 是否包含指定前缀
    func hasPrefix(_ s: String) -> Bool {
        return String(characters).hasPrefix(s) // ?
    }
}

// MARK: - Parser

typealias S = Parser<String, InputString>

extension Parser where Stream == InputString {
    /// 快捷方法，接收一个字符串作为输入
    func parse(_ string: String) -> ParseResult<(Token, Stream)> {
        let input = InputString(characters: Array(string), row: 0, column: 0)
        return self.parse(input)
    }
    
    /// 快捷方法，接收一个字符数组作为输入
    func parse(_ chars: [Character]) -> ParseResult<(Token, Stream)> {
        let input = InputString(characters: chars, row: 0, column: 0)
        return self.parse(input)
    }
}

extension Parser where Token == String, Stream == InputString {
    
    /// 创建一个单个字符Parser的快捷方法
    static func satisfy(_ condition: @escaping (Token) -> Bool) -> S {
        return S(parse: { (input) -> ParseResult<(String, InputString)> in
            if let first = input.first(), condition(String(first)) {
                let value = String(first)
                return .success((value, input.dropFirst()))
            }
            return .failure(.unexpectedToken)
        })
    }
    
    /// 匹配单个字符
    static func char(_ c: Character) -> S {
        return S.satisfy({ $0 == String(c) })
    }
    
    /// 匹配一个字符串
    static func string(_ s: String) -> S {
        return S(parse: { (input) -> ParseResult<(String, InputString)> in
            guard input.hasPrefix(s) else {
                return .failure(.notMatch(""))
            }
            return .success((s, input.drop(s.count)))
            
        })
    }
    
    /// 匹配单个数字
    static var digit: S {
        return S.satisfy({ $0 >= "0" && $0 <= "9" })
    }
    
    /// 连续匹配任意多个空白符，包括空格、换行、\t，始终返回成功
    static var spaces: S {
        return
            S.satisfy({ (s) -> Bool in
                return s == " " || s == "\n" || s == "\t"
            })
            .many
            .map { $0.joined() }
    }
    
    /// 匹配一个指定范围内的字符
    static func range(_ chars: Range<String>) -> S {
        return S.satisfy({ (s) -> Bool in
            return chars.contains(s)
        })
    }
    
    /// 匹配一个指定范围内的字符
    static func range(_ chars: ClosedRange<String>) -> S {
        return S.satisfy { (s) -> Bool in
            return chars.contains(s)
        }
    }
}

// MARK: - Sequence Extension

fileprivate extension Sequence {
    func first() -> Element? {
        for element in self {
            return element
        }
        return nil
    }
}

fileprivate extension Array where Element == Character {
    /// 将Array的第一个元素取出来，与剩下的元素组合成一个二元组返回
    func decompose() -> (Element?, [Element]) {
        if let first = self.first {
            return (first, Array(self.dropFirst()))
        }
        return (nil, self)
    }
}
