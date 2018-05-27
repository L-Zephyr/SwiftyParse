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
    
    /// 匹配单个数字
    static var digit: S {
        return S.satisfy({ $0 >= "0" && $0 <= "9" })
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
