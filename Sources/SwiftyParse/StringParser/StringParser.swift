//
//  StringParser2.swift
//  SwiftyParse
//
//  Created by LZephyr on 2018/4/7.
//  Copyright © 2018年 LZephyr. All rights reserved.
//

import Foundation

// MARK: - Parser

public typealias S = Parser<String, InputString>

public extension Parser where Stream == InputString {
    /// 快捷方法，接收一个字符串作为输入
    func parse(_ string: String) -> ParseResult<(Result, Stream)> {
        let input = InputString(characters: Array(string), row: 0, column: 0)
        return self.parse(input)
    }
    
    /// 快捷方法，接收一个字符数组作为输入
    func parse(_ chars: [Character]) -> ParseResult<(Result, Stream)> {
        let input = InputString(characters: chars, row: 0, column: 0)
        return self.parse(input)
    }
}

public extension Parser where Result == String, Stream == InputString {
    
    /// 创建一个单个字符Parser的快捷方法
    static func satisfy(_ condition: @escaping (Result) -> Bool) -> S {
        return S(parse: { (input) -> ParseResult<(String, InputString)> in
            if let first = input.first(), condition(String(first)) {
                let value = String(first)
                return .success((value, input.dropFirst()))
            } else if input.isEmpty() {
                return .failure(.endOfInput)
            } else {
                return .failure(.notMatch("Unexpected token found: \(input.first()!) (row: \(input.row), column: \(input.column))"))
            }
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
