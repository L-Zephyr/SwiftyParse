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

// MARK: - StringParser

extension Parser where Token: Equatable, Stream == InputString {
    func assertSuccess(input: [Character], value: Token, remain: [Character], message: String = "") {
        switch self.parse(input) {
        case .success(let (r, rest)):
            XCTAssert(value == r, "结果: \(r), \(message)")
            XCTAssert(rest.characters == remain, "剩余: \(rest)") // NOTE: 先不考虑位置的对比
        case .failure(_):
            XCTAssert(false, "输入: \(input), \(message)")
        }
    }
    
    func assertFailure(input: [Character], message: String = "") {
        switch self.parse(input) {
        case .success(_):
            XCTAssert(false, "输入: \(input), \(message)")
        case .failure(_):
            XCTAssert(true, "输入: \(input), \(message)")
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

extension String {
    func toChars() -> [Character] {
        return Array(self)
    }
}
