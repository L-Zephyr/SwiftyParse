//
//  StringParserTest.swift
//  Tests
//
//  Created by LZephyr on 2018/1/3.
//  Copyright © 2018年 LZephyr. All rights reserved.
//

import XCTest

extension Parser where Token == Array<String>, Stream == String {
    func assertSuccess(input: Stream, value: Token, remain: Stream) {
        switch self.parse(input) {
        case .success(let (r, rest)):
            XCTAssert(value == r, "结果: \(r)")
            XCTAssert(rest == remain, "剩余: \(rest)")
        case .failure(_):
            XCTAssert(false, "输入: \(input)")
        }
    }

    func assertFailure(input: Stream) {
        switch self.parse(input) {
        case .success(_):
            XCTAssert(false, "输入: \(input)")
        case .failure(_):
            XCTAssert(true, "输入: \(input)")
        }
    }
}

class StringParserTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testChar() {
        char("a").assertSuccess(input: "abc", value: ["a"], remain: "bc")
    }
    
    func testString() {
        string("hello").assertSuccess(input: "hello world", value: ["hello"], remain: " world")
    }
    
    func testAdd() {
        let parser = string("hello") + string(" ") + string("world")
        parser.assertSuccess(input: "hello world", value: ["hello", " ", "world"], remain: "")
    }
    
    func testEnd() {
        end().assertSuccess(input: "", value: [], remain: "")
        end().assertFailure(input: "a")
    }
    
    func testEndBy() {
        endBy("world").assertFailure(input: "hello world")
        endBy("world").assertFailure(input: "world ")
        endBy("world").assertSuccess(input: "world", value: ["world"], remain: "")
    }
    
    func testRange() {
        // 开区间
        range("0"..<"4").assertSuccess(input: "23", value: ["2"], remain: "3")
        range("0"..<"4").assertFailure(input: "4")
        
        // 闭区间
        range("0"..."4").assertSuccess(input: "43", value: ["4"], remain: "3")
        range("0"..."4").assertFailure(input: "5")
    }
    
    func testWord() {
        word().assertSuccess(input: "hello world", value: ["hello"], remain: " world")
        word().assertSuccess(input: "HELLO world", value: ["HELLO"], remain: " world")
        word().assertSuccess(input: "hElLo world", value: ["hElLo"], remain: " world")
    }
    
    func testLine() {
        let line = anyChar().manyTill(char("\n"))
    }
}
