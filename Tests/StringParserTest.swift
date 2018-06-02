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
        S.char("a").assertSuccess(input: ["a", "b", "c"], value: "a", remain: ["b", "c"])
    }
    
    func testString() {
        S.string("abc").assertSuccess(input: "abcd".toChars(), value: "abc", remain: "d".toChars())
    }

    func testAdd() {
        let parser = S.string("hello") ++ S.string(" ") ++ S.string("world")
        parser.assertSuccess(input: "hello world".toChars(), value: ["hello", " ", "world"], remain: "".toChars())
    }
    
    func testRange() {
        // 开区间
        S.range("0"..<"4").assertSuccess(input: "23".toChars(), value: "2", remain: "3".toChars())
        S.range("0"..<"4").assertFailure(input: "4".toChars())
        
        // 闭区间
        S.range("0"..."4").assertSuccess(input: "43".toChars(), value: "4", remain: "3".toChars())
        S.range("0"..."4").assertFailure(input: "5".toChars())
    }
    
    func testSpaces() {
        S.spaces.assertSuccess(input: [" ", "\t", "\t", "\n", "a"], value: " \t\t\n", remain: ["a"])
        S.spaces.assertSuccess(input: ["a"], value: "", remain: ["a"])
    }
}
