//
//  StringParser+SepBy.swift
//  SwiftyParse
//
//  Created by LZephyr on 2018/6/6.
//  Copyright © 2018年 LZephyr. All rights reserved.
//

import Foundation

// NOTE: 重写sepBy、sepBy1、notFollowedBy组合子，防止丢失错误信息

extension Parser where Stream == InputString {
    
    /// 匹配0个或多个由separator分隔的self，在解析完最后一个项目之后不能跟着分隔符
    ///
    /// - Parameter separator: 分隔符
    /// - Returns: parser的结果包含所有成功解析Token的数组，在解析完最后一个Token后如果还跟着分隔符的话会返回错误
    func sepBy<U>(_ separator: Parser<U, Stream>) -> Parser<[Token], Stream> {
        return Parser<[Token], Stream>(parse: { (stream) -> ParseResult<([Token], Stream)> in
            guard case let .success((first, remain)) = self.parse(stream) else {
                return .success(([], stream))
            }
            
            let remainParser = (separator *> self).many.notFollowedBy(separator)
            
            switch remainParser.parse(remain) {
            case let .success((tokens, r)):
                let results = [first] + tokens
                return .success((results.compactMap { $0 }, r))
            case .failure(let error):
                return .failure(error)
            }
        })
    }
    
    /// 至少匹配1个或多个由separator分隔的self，在解析完最后一个项目之后不能跟着分隔符
    ///
    /// - Parameter separator: 分隔符
    /// - Returns: parser的结果包含所有成功解析Token的数组，数组中至少包含一个结果；在解析完最后一个Token后如果还跟着分隔符的话会返回错误，如果结果为空也会返回错误
    func sepBy1<U>(_ separator: Parser<U, Stream>) -> Parser<[Token], Stream> {
        return self.flatMap({ (first) -> Parser<[Token], Stream> in
            return (separator *> self)
                .many
                .notFollowedBy(separator)
                .flatMap({ (tokens) -> Parser<[Token], Stream> in
                    return .result([first] + tokens)
                })
        })
    }
}

// MARK: - NotFollowedBy

/// 为`notFollowedBy`组合子加上出错时的状态数据
fileprivate func _notFollowedBy<Token, U>(_ this: Parser<Token, InputString>, _ p: Parser<U, InputString>) -> Parser<Token, InputString> {
    let not = Parser<U?, InputString>(parse: { (input) -> ParseResult<(U?, InputString)> in
        switch p.parse(input) {
        case .success(let (r, _)):
            return .failure(.notMatch("Unexpected token found: `\(r)` (row: \(input.row), column: \(input.column))"))
        case .failure(_):
            return .success((nil, input))
        }
    })
    
    return this <* not
}

extension Parser where Stream == InputString {
    /// `self.notFollowedBy(p)`仅当p失败的时候返回成功，不会消耗输入，成功时返回self的值
    ///
    /// - Parameter p: 任意结果类型的Parser
    /// - Returns: 新的Parser，成功时返回self的结果
    func notFollowedBy<U>(_ p: Parser<U, Stream>) -> Parser<Token, Stream> {
        return _notFollowedBy(self, p)
    }
}
