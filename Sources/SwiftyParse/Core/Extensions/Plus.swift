//
//  Plus.swift
//  SwiftyParse
//
//  Created by LZephyr on 2018/4/6.
//  Copyright © 2018年 LZephyr. All rights reserved.
//

import Foundation

/*
 `plus`操作符，从左向右依次解析两个相同类型的Parser，并将它们的结果保存在数组中返回
 */
precedencegroup ParserPlusLeft {
    associativity: left
    lowerThan: LogicalDisjunctionPrecedence
    higherThan: AssignmentPrecedence
}

// MARK: - +

infix operator ++ : ParserPlusLeft

// Result + Result = [Result]
public func ++ <Result, Stream>(_ lhs: Parser<Result, Stream>, _ rhs: Parser<Result, Stream>) -> Parser<[Result], Stream> {
    return lhs.plus(rhs)
}

// Result + [Result] = [Result]
public func ++ <Result, Stream>(_ lhs: Parser<Result, Stream>, _ rhs: Parser<[Result], Stream>) -> Parser<[Result], Stream> {
    return lhs.plus(rhs)
}

// [Result] + Result = [Result]
public func ++ <Result: Sequence, Stream>(_ lhs: Parser<Result, Stream>, _ rhs: Parser<Result.Element, Stream>) -> Parser<[Result.Element], Stream> {
    return lhs.plus(rhs)
}

// [Result] + [Result] = [Result]
public func ++ <Result:Sequence, Stream>(_ lhs: Parser<Result, Stream>, _ rhs: Parser<Result, Stream>) -> Parser<[Result.Element], Stream> {
    return lhs.plus(rhs)
}

// MARK: - Plus

public extension Parser {
    func plus(_ parser: Parser<Result, Stream>) -> Parser<[Result], Stream> {
        return self.flatMap({ (result1) -> Parser<[Result], Stream> in
            return parser.flatMap({ (result2) -> Parser<[Result], Stream> in
                return .result([result1, result2])
            })
        })
    }
    
    func plus(_ parser: Parser<[Result], Stream>) -> Parser<[Result], Stream> {
        return self.flatMap({ (result1) -> Parser<[Result], Stream> in
            return parser.flatMap({ (result2) -> Parser<[Result], Stream> in
                return .result([result1] + result2)
            })
        })
    }
}

public extension Parser where Result: Sequence {
    func plus(_ parser: Parser<Result.Element, Stream>) -> Parser<[Result.Element], Stream> {
        return self.flatMap({ (tokens) -> Parser<[Result.Element], Stream> in
            return parser.flatMap({ (token) -> Parser<[Result.Element], Stream> in
                return .result(Array(tokens) + [token])
            })
        })
    }
    
    func plus(_ parser: Parser<Result, Stream>) -> Parser<[Result.Element], Stream> {
        return self.flatMap({ (tokens1) -> Parser<[Result.Element], Stream> in
            return parser.flatMap({ (tokens2) -> Parser<[Result.Element], Stream> in
                return .result(Array(tokens1) + Array(tokens2))
            })
        })
    }
}
