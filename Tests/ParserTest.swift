//
//  ParserTest.swift
//  Tests
//
//  Created by LZephyr on 2017/12/30.
//  Copyright © 2017年 LZephyr. All rights reserved.
//

import XCTest

//extension Array: Equatable {
//    public static func == (_ lhs: Array, _ rhs: Array) -> Bool {
//        XCTAssert(false, "The Element in Array must implement Equatable!")
//        return false
//    }
//}

class ParserTest: XCTestCase {
    
    typealias TestParser = Parser<String, [String]>
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func match(_ s: String) -> TestParser {
        return TestParser(parse: { (strings) -> ParseResult<(String, [String])> in
            guard let first = strings.first, first == s else {
                return .failure(ParseError.unkown)
            }
            return .success((s, Array(strings.dropFirst())))
        })
    }
    
    // MARK: - Functor

    func testMap() {
        let parser = match("a").map { (result) -> String in
            return result + result
        }
        
        parser.assertSuccess(input: ["a", "b", "c"], value: "aa", remain: ["b", "c"])
    }

    // MARK: - Applicative
    
    // MARK: - Alternative
    
    func testChoice() {
        let parser = TestParser.choice(match("a"), match("b"))
        
        parser.assertSuccess(input: ["a", "b", "c"], value: "a", remain: ["b", "c"])
        parser.assertFailure(input: ["c", "d", "e"])
    }
    
    // MARK: - Monad
    
    // MARK: - Operators
    
    func testSeparatedBy() {
        let parser = match("a").separatedBy(match(","))
        
        parser.assertSuccess(input: ["a", ",", "a", ",", "a"], value: ["a", "a", "a"], remain: [])
        parser.assertFailure(input: ["a", ",", "a", ","]) // 结果不能跟着分隔符
        parser.assertFailure(input: ["a"]) // 至少有两个结果
    }

    func testMany() {
        match("a").many.assertSuccess(input: ["a", "a", "b"], value: ["a", "a"], remain: ["b"])
        match("b").many.assertSuccess(input: ["a", "a", "b"], value: [], remain: ["a", "a", "b"]) // many不返回错误
    }
    
    func testMany1() {
        match("b").many1.assertFailure(input: ["a", "a", "b"])
    }
    
    func testCount() {
        let input = ["a", "a", "b"]
        
        match("a").count(2).assertSuccess(input: input, value: ["a", "a"], remain: ["b"])
        match("a").count(3).assertFailure(input: input)
    }
    
    func testBetween() {
        let input = ["a", "b", "c"]
        
        match("b").between(match("a"), match("c")).assertSuccess(input: input, value: "b", remain: [])
        match("a").between(match("a"), match("b")).assertFailure(input: input)
    }
    
    func testManyTill() {
        let input = ["a", "a", "b", "c"]
        
        match("a").manyTill(match("b")).assertSuccess(input: input, value: ["a", "a"], remain: ["b", "c"])
    }
    
    func testAttempt() {
        let input = ["a", "b", "c"]
        
        guard case let .success((r, remain)) = match("b").attempt.parse(input) else {
            XCTAssert(false)
            return
        }
        
        XCTAssert(r == nil)
        XCTAssert(remain == input)
    }
    
    func testNotFollowedBy() {
        let input = ["a", "b", "c"]
        
        match("a").notFollowedBy(match("c")).assertSuccess(input: input, value: "a", remain: ["b", "c"])
        match("a").notFollowedBy(match("b")).assertFailure(input: input)
        match("b").notFollowedBy(match("b")).assertFailure(input: input)
    }
}
