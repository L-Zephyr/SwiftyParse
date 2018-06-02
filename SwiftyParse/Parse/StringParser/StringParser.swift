//
//  StringParser2.swift
//  SwiftyParse
//
//  Created by LZephyr on 2018/4/7.
//  Copyright © 2018年 LZephyr. All rights reserved.
//

import Foundation

typealias S = Parser<String, [Character]>

extension Parser where Stream == [Character] {
    func parse(_ string: String) -> ParseResult<(Token, Stream)> {
        return self.parse(Array(string))
    }
}

extension Parser where Token == String, Stream == [Character] {
    
    /// 创建一个单个字符Parser的快捷方法
    static func satisfy(_ condition: @escaping (Token) -> Bool) -> S {
        return S(parse: { (input) -> ParseResult<(String, [Character])> in
            if let first = input.first, condition(String(first)) {
                let value = String(first)
                let remain = Array(input.dropFirst())
                return .success((value, remain))
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
        return S(parse: { (input) -> ParseResult<(String, [Character])> in
            guard String(input).hasPrefix(s) else {
                return .failure(.notMatch(""))
            }
            return .success((s, Array(input.suffix(from: s.count))))
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
