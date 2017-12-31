//
//  Monad.swift
//  SwiftyParse
//
//  Created by LZephyr on 2017/12/30.
//  Copyright © 2017年 LZephyr. All rights reserved.
//

import Foundation

func >>- <T, U, S>(lhs: Parser<T, S>, rhs: @autoclosure @escaping (T) -> Parser<U, S>) -> Parser<U, S> {
    return lhs.flatMap(rhs)
}

func -<< <T, U, S>(lhs: @autoclosure @escaping (T) -> Parser<U, S>, rhs: Parser<T, S>) -> Parser<U, S> {
    return rhs.flatMap(lhs)
}

extension Parser {
    func flatMap<U>(_ f: @escaping (Token) -> Parser<U, Stream>) -> Parser<U, Stream> {
        return Parser<U, Stream> { (tokens) -> ParseResult<(U, Stream)> in
            switch self.parse(tokens) {
            case .success(let (result, rest)):
                let p = f(result)
                return p.parse(rest)
                
            case .failure(let error):
                return .failure(error)
            }
        }
    }
}
