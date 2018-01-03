//
//  StringParser.swift
//  SwiftyParse
//
//  Created by LZephyr on 2017/12/30.
//  Copyright © 2017年 LZephyr. All rights reserved.
//

import Foundation

public typealias StringParser = Parser<Character, String>

// MARK: - 快捷方法

public func char(_ c: Character) -> StringParser {
    return StringParser.char(c)
}

public func string(_ s: String) -> Parser<String, String> {
    return StringParser.string(s)
}

// MARK: -

public extension Parser where Token == Character, Stream == String {
    
    /// 创建一个解析指定字符的Parser
    static func char(_ c: Character) -> StringParser {
        return StringParser(parse: { (string) -> ParseResult<(Character, String)> in
            guard let first = string.first else {
                return .failure(ParseError.Unkown) // TODO: 错误处理
            }
            guard first == c else {
                return .failure(ParseError.Unkown)
            }
            let left = String(string.dropFirst())
            return .success((first, left))
        })
    }
    
    /// 创建一个解析指定字符串的Parser
    static func string(_ s: String) -> Parser<String, String> {
        return Parser<String, String>(parse: { (string) -> ParseResult<(String, String)> in
            guard string.hasPrefix(s) else {
                return .failure(ParseError.Unkown) // TODO: 错误处理
            }
            let remain = String(string.dropFirst(s.count))
            return .success((s, remain))
        })
    }
    
    
}
