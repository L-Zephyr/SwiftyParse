//
//  Alternative.swift
//  SwiftyParse
//
//  Created by LZephyr on 2017/12/30.
//  Copyright © 2017年 LZephyr. All rights reserved.
//

import Foundation

func <|> <T, S>(lhs: Parser<T, S>, rhs: Parser<T, S>) -> Parser<T, S> {
    return lhs.or(rhs)
}

extension Parser {
    func or(_ p: Parser<Token, Stream>) -> Parser<Token, Stream> {
        return Parser<Token, Stream>(parse: { (tokens) -> ParseResult<(Token, Stream)> in
            let r = self.parse(tokens)
            switch r {
            case .success(_):
                return r
            case .failure(_):
                return p.parse(tokens) // 左侧失败时不消耗输入
            }
        })
    }
}
