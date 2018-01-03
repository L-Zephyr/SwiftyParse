//
//  Parse.swift
//  SwiftyParse
//
//  Created by LZephyr on 2017/12/30.
//  Copyright © 2017年 LZephyr. All rights reserved.
//

import Foundation

// MARK: - Parser

struct Parser<Token, Stream> {
    var parse: (Stream) -> ParseResult<(Token, Stream)>
}

extension Parser {
    /// 始终返回success，结果为t，不消耗输入
    func pure(_ t: Token) -> Parser<Token, Stream> {
        return Parser(parse: { (stream) -> ParseResult<(Token, Stream)> in
            return .success((t, stream))
        })
    }
}

// MARK: - ParseResult

public enum ParseResult<T> {
    case success(T)
    case failure(ParseError)
}

extension ParseResult {
    /// 可选值，如果解析成功返回结果，解析失败返回nil
    var value: T? {
        switch self {
        case .success(let t):
            return t
        case .failure(_):
            return nil
        }
    }
    
    /// 可选值，如果解析失败返回错误原因，解析成功返回nil
    var error: ParseError? {
        switch self {
        case .success(_):
            return nil
        case .failure(let error):
            return error
        }
    }
}

// MARK: - ParseError

public enum ParseError: Error {
    case Unkown
    case EndOfStream // stream为空
}
