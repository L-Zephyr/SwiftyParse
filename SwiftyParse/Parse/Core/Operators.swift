//
//  Operators.swift
//  SwiftyParse
//
//  Created by LZephyr on 2017/12/30.
//  Copyright © 2017年 LZephyr. All rights reserved.
//

import Foundation

/// 在parser失败的时候返回自定义的错误说明
///
/// - Parameters:
///   - p:     需要执行的parser
///   - msg:   自定义的错误信息
/// - Returns: 返回一个新的Parser，出错时返回msg
func <?><Token, Stream>(_ p: Parser<Token, Stream>, _ msg: String) -> Parser<Token, Stream> {
    return Parser<Token, Stream>(parse: { (input) -> ParseResult<(Token, Stream)> in
        switch p.parse(input) {
        case .success(let (r, remain)):
            return .success((r, remain))
        case .failure(_):
            return .failure(.custom(msg))
        }
    })
}

public extension Parser {
    /// 执行0次或多次parse，直到出错为止，解析结束返回结果列表，该Parser不会返回错误
    var many: Parser<[Token], Stream> {
        return Parser<[Token], Stream> { (stream) -> ParseResult<([Token], Stream)> in
            var result = [Token]()
            var remain = stream
            while true {
                switch self.parse(remain) {
                case .success(let (r, rest)):
                    result.append(r)
                    remain = rest
                case .failure(_):
                    return .success((result, remain))
                }
            }
        }
    }
    
    /// 尝试执行1次或多次parse，结果为空则返回错误
    var many1: Parser<[Token], Stream> {
        return Parser<[Token], Stream> { (stream) -> ParseResult<([Token], Stream)> in
            var result = [Token]()
            var remain = stream
            while true {
                switch self.parse(remain) {
                case .success(let (r, rest)):
                    result.append(r)
                    remain = rest
                case .failure(let error):
                    if result.count == 0 {
                        return .failure(error)
                    } else {
                        return .success((result, remain))
                    }
                }
            }
        }
    }
    
    /// `p.manyTill(end)`尝试多次应用p，直到end成功或解析错误为止，end不会消耗输入
    ///
    /// - Parameter end: 成功则表示结束
    /// - Returns:       成功解析的结果数组或错误
    func manyTill(_ end: Parser<Token, Stream>) -> Parser<[Token], Stream> {
        return Parser<[Token], Stream> { (input) -> ParseResult<([Token], Stream)> in
            var remain = input
            var results = [Token]()
            while true {
                if case .success(_) = end.parse(remain) {
                    return .success((results, remain))
                }
                
                switch self.parse(remain) {
                case .success(let (r, rest)):
                    results.append(r)
                    remain = rest
                case .failure(let error):
                    return .failure(error)
                }
            }
        }
    }
    
    /// 匹配0个或多个由separator分隔的self，在解析完最后一个项目之后不能跟着分隔符
    ///
    /// - Parameter separator: 分隔符
    /// - Returns: 所有的结果数组，如果只有一个结果或解析结果跟着分隔符则返回错误
    func separatedBy<U>(_ separator: Parser<U, Stream>) -> Parser<[Token], Stream> {
        return Parser<[Token], Stream>(parse: { (stream) -> ParseResult<([Token], Stream)> in
            guard case let .success((t, r)) = self.parse(stream) else {
                return .success(([], stream))
            }
            var remain = r
            var results = [t]
            
            let leftP = (separator *> self).many.notFollowedBy(separator)
            if case let .success((t, r)) = leftP.parse(remain) {
                results.append(contentsOf: t)
                remain = r
            }
            
            if results.count == 1 {
                return .failure(ParseError.unkown) // TODO: 错误处理
            } else {
                return .success((results, remain))
            }
        })
    }
    
    /// `p.count(n)`尝试将解析器p连续应用n次，返回结果集合
    ///
    /// - Parameter num: 解析次数, 为0则返回[]
    /// - Returns:       解析结果列表或错误
    func count(_ num: Int) -> Parser<[Token], Stream> {
        return Parser<[Token], Stream>(parse: { (input) -> ParseResult<([Token], Stream)> in
            var results = [Token]()
            var remain = input
            for _ in 0..<num {
                switch self.parse(remain) {
                case .success(let (r, rest)):
                    results.append(r)
                    remain = rest
                case .failure(let error):
                    return .failure(error)
                }
            }
            return .success((results, remain))
        })
    }
    
    /// 按照顺序依次解析open、self、close，最后返回self的结果，open和close会消耗输入但不会出现在结果中
    ///
    /// - Parameters:
    ///   - open:  在self左侧的操作符
    ///   - close: 在self右侧的操作符
    /// - Returns: 解析成功返回self的解析结果，失败返回错误
    func between<L, R>(_ open: Parser<L, Stream>, _ close: Parser<R, Stream>) -> Parser<Token, Stream> {
        return open *> self <* close;
    }
    
    /// 尝试解析，如果失败的话返回结果nil且不消耗输入，不会返回错误
    var attempt: Parser<Token?, Stream> {
        return Parser<Token?, Stream>(parse: { (input) -> ParseResult<(Token?, Stream)> in
            switch self.parse(input) {
            case .success(let (r, remain)):
                return .success((r, remain))
            case .failure(_):
                return .success((nil, input))
            }
        })
    }
    
    /// `self.notFollowedBy(p)`仅当p失败的时候返回成功，p不会消耗输入，成功时返回self的值
    ///
    /// - Parameter p: 任意结果类型的Parser
    /// - Returns: 新的Parser，成功时返回self的结果
    func notFollowedBy<U>(_ p: Parser<U, Stream>) -> Parser<Token, Stream> {
        let not = Parser<U?, Stream>(parse: { (input) -> ParseResult<(U?, Stream)> in
            switch p.parse(input) {
            case .success(let (r, _)):
                return .failure(.notMatch("Unexpected found: \(r)"))
            case .failure(_):
                return .success((nil, input))
            }
        })
        
        return self <* not
    }
}
