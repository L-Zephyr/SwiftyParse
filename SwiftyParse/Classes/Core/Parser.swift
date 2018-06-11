//
//  Parse.swift
//  SwiftyParse
//
//  Created by LZephyr on 2017/12/30.
//  Copyright © 2017年 LZephyr. All rights reserved.
//

import Foundation

// MARK: - Parser

public struct Parser<Result, Stream: Sequence> {
    public var parse: (Stream) -> ParseResult<(Result, Stream)>
    
    public init(parse: @escaping (Stream) -> ParseResult<(Result, Stream)>) {
        self.parse = parse
    }
}

public extension Parser {
    /// 始终返回success，结果为t，不消耗输入
    static func result(_ t: Result) -> Parser<Result, Stream> {
        return Parser(parse: { (stream) -> ParseResult<(Result, Stream)> in
            return .success((t, stream))
        })
    }
    
    /// 始终返回failure
    static func error(_ err: ParseError) -> Parser<Result, Stream> {
        return Parser(parse: { (_) -> ParseResult<(Result, Stream)> in
            return .failure(err)
        })
    }
}

// MARK: - ParseResult

public enum ParseResult<T> {
    case success(T)
    case failure(ParseError)
}

public extension ParseResult {
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
    case unkown
//    case unexpectedToken(String) // TODO:
    case endOfInput // 输入为空
    case notMatch(String) // 匹配失败
    case custom(String) // 自定义错误信息
}
