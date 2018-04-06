//
//  Tests.swift
//  Tests
//
//  Created by LZephyr on 2017/12/30.
//  Copyright © 2017年 LZephyr. All rights reserved.
//

import XCTest

extension Array where Element: Equatable {
    public static func == (_ lhs: Array<String>, _ rhs: Array<String>) -> Bool {
        guard lhs.count == rhs.count else {
            return false
        }
        for index in 0..<lhs.count {
            if lhs[index] != rhs[index] {
                return false
            }
        }
        return true
    }
}

extension Parser where Token: Equatable, Stream: Equatable {
    
    /// 断言parse结果为.success
    ///
    /// - Parameters:
    ///   - input:  输入
    ///   - value:  期望的结果
    ///   - remain: 期望剩余的输入
    func assertSuccess(input: Stream, value: Token, remain: Stream, message: String = "") {
        switch self.parse(input) {
        case .success(let (r, rest)):
            XCTAssert(value == r, message)
            XCTAssert(rest == remain, message)
        case .failure(_):
            XCTAssert(false, message)
        }
    }
    
    /// 断言解析结果为.failure
    ///
    /// - Parameter input: 输入
    func assertFailure(input: Stream, message: String = "") {
        switch self.parse(input) {
        case .success(_):
            XCTAssert(false, message)
        case .failure(_):
            XCTAssert(true, message)
        }
    }
}

/// Tip: 下面这一段代码是冗余的，理想情况下应该是这样：extension Array: Equatable where Element: Equatable
///      但是目前swift不能给一个带泛型约束的extension添加新的协议，所以现在只能先这样写以满足测试需要
extension Parser where Token: Equatable, Stream == Array<String> {
    func assertSuccess(input: Stream, value: Token, remain: Stream, message: String = "") {
        switch self.parse(input) {
        case .success(let (r, rest)):
            XCTAssert(value == r, message)
            XCTAssert(rest == remain, message)
        case .failure(_):
            XCTAssert(false, message)
        }
    }
    
    func assertFailure(input: Stream, message: String = "") {
        switch self.parse(input) {
        case .success(_):
            XCTAssert(false, message)
        case .failure(_):
            XCTAssert(true, message)
        }
    }
}
extension Parser where Token == Array<String>, Stream == Array<String> {
    func assertSuccess(input: Stream, value: Token, remain: Stream, message: String = "") {
        switch self.parse(input) {
        case .success(let (r, rest)):
            XCTAssert(value == r, message)
            XCTAssert(rest == remain, message)
        case .failure(_):
            XCTAssert(false, message)
        }
    }
    
    func assertFailure(input: Stream, message: String = "") {
        switch self.parse(input) {
        case .success(_):
            XCTAssert(false, message)
        case .failure(_):
            XCTAssert(true, message)
        }
    }
}

// MARK: - Test Parser Type

typealias TestParser = Parser<String, [String]>

func match(_ s: String) -> TestParser {
    return TestParser(parse: { (strings) -> ParseResult<(String, [String])> in
        guard let first = strings.first, first == s else {
            return .failure(ParseError.unkown)
        }
        return .success((s, Array(strings.dropFirst())))
    })
}
