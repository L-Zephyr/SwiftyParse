//
//  StringParser.swift
//  SwiftyParse
//
//  Created by LZephyr on 2017/12/30.
//  Copyright © 2017年 LZephyr. All rights reserved.
//

import Foundation

typealias StringParser = Parser<String, String>

extension Parser where Token == String, Stream == String {
    
    /// 创建一个解析指定字符的Parser
    static func satisfy(_ c: Character) -> StringParser {
        return StringParser(parse: { (string) -> ParseResult<(String, String)> in
            guard let first = string.first else {
                return .failure(ParseError.Unkown) // TODO: 错误处理
            }
            guard first == c else {
                return .failure(ParseError.Unkown)
            }
            let left = String(string.dropFirst())
            return .success((String(first), left))
        })
    }
    
    /// 创建一个解析指定字符串的Parser
    static func string(_ s: String) -> Parser<String, String> {
        return StringParser(parse: { (string) -> ParseResult<(String, String)> in
            guard string.hasPrefix(s) else {
                return .failure(ParseError.Unkown) // TODO: 错误处理
            }
            let remain = String(string.dropFirst(s.count))
            return .success((s, remain))
        })
    }
}
