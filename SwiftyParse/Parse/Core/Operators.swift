//
//  Operators.swift
//  SwiftyParse
//
//  Created by LZephyr on 2017/12/30.
//  Copyright © 2017年 LZephyr. All rights reserved.
//

import Foundation

extension Parser {
    /// 尝试执行多次parse，至少执行一次，结果为空则返回错误
    var many: Parser<[Token], Stream> {
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
                        #if DEBUG
                            print("many parse stop: \(error)")
                        #endif
                        return .success((result, remain))
                    }
                }
            }
        }
    }
    
    /// 匹配0个或多个由separator分隔的self
    ///
    /// - Parameter separator: 分隔符
    /// - Returns: 所有的结果数组，如果只有一个结果则返回错误
    func separatedBy<U>(_ separator: Parser<U, Stream>) -> Parser<[Token], Stream> {
        return Parser<[Token], Stream>(parse: { (stream) -> ParseResult<([Token], Stream)> in
            guard case let .success((t, r)) = self.parse(stream) else {
                return .success(([], stream))
            }
            var remain = r
            var results = [t]
            
            let next = separator *> self
            while case let .success((t, r)) = next.parse(remain) {
                results.append(t)
                remain = r
            }
            
            if results.count == 1 {
                return .failure(ParseError.Unkown) // TODO: 错误处理
            } else {
                return .success((results, remain))
            }
        })
    }
    
    /// 按照顺序依次解析open、self、close，最后返回self的结果，open和close中的输入被消耗掉
    ///
    /// - Parameters:
    ///   - open:  在self左侧的操作符
    ///   - close: 在self右侧的操作符
    /// - Returns: 解析成功返回self的解析结果，失败返回错误
    func between<L, R>(_ open: Parser<L, Stream>, _ close: Parser<R, Stream>) -> Parser<Token, Stream> {
        return open *> self <* close;
    }
}
