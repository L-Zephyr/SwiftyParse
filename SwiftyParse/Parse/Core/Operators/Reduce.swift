//
//  Reduce.swift
//  SwiftyParse
//
//  Created by LZephyr on 2018/5/27.
//  Copyright © 2018年 LZephyr. All rights reserved.
//

import Foundation

extension Parser {
    static func foldl(_ op: (Token, Token) -> Token, _ first: Token, _ seq: [Token]) -> Token {
        return seq.reduce(first, { (first, second) -> Token in
            return op(first, second)
        })
    }
    
    /// 解析self.many，并将结果通过combinator结合起来，用法类似Sequence的reduce
    ///
    /// - Parameters:
    ///   - first: 初始值
    ///   - combinator: 接收初始值和self的解析结果作为输入，返回值作为下一次的输入
    /// - Returns: 累积的结果，该Parser不会失败
    func reduce<Result>(_ first: Result, _ combinator: @escaping (Result, Token) -> Result) -> Parser<Result, Stream> {
        return self.many.map { (nextList) -> Result in
            nextList.reduce(first, { (first, two) -> Result in
                return combinator(first, two)
            })
        }
    }
    
    /// 连续解析 combinator + self，combinator解析得到一个闭包，initValue和self的结果作为参数传入闭包得到下一次的参数，用法类似Sequence的reduce，不同的是combinator也会参与解析
    ///
    /// - Parameters:
    ///   - initValue: 初始值，使用该值作为第一个参数传入闭包，并将结果累积
    ///   - combinator: 参与解析并返回一个闭包，该闭包的计算结果将作为累积的值参与下一次运算
    /// - Returns: 累积的结果，该Parser不会失败
    func reduce<Result>(_ initValue: Result, _ combinator: Parser<(Result, Token) -> Result, Stream>) -> Parser<Result, Stream> {
        return Parser<Result, Stream>(parse: { (input) -> ParseResult<(Result, Stream)> in
            var result = initValue
            var remain = input
            while case .success(let (op, r1)) = combinator.parse(remain), case .success(let (num, r2)) = self.parse(r1) {
                result = op(result, num)
                remain = r2
            }
            return .success((result, remain))
        })
    }
    
    /// 将self解析的结果作为初始值来调用`reduce`
    ///
    /// - Parameter op: Combinator Parser，解析结果为一个闭包
    /// - Returns: 累积的结果，当self第一次解析失败的时候返回错误
    func chain(_ op: Parser<(Token, Token) -> Token, Stream>) -> Parser<Token, Stream> {
        return self.flatMap { self.reduce($0, op) }
    }
}
