//
//  ParserTest.swift
//  Tests
//
//  Created by LZephyr on 2017/12/30.
//  Copyright © 2017年 LZephyr. All rights reserved.
//

import XCTest
@testable import SwiftyParse

class ParserTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
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
    
    func testSepBy() {
        let parser = match("a").sepBy(match(","))
        
        parser.assertSuccess(input: ["a", ",", "a", ",", "a"], value: ["a", "a", "a"], remain: [], message: "testSepBy-1")
        parser.assertSuccess(input: ["a"], value: ["a"], remain: [], message: "testSepBy-2")
        parser.assertSuccess(input: [","], value: [], remain: [","], message: "testSepBy-3")
        parser.assertSuccess(input: ["b", ",", "b"], value: [], remain: ["b", ",", "b"], message: "testSepBy-4")
        
        parser.assertFailure(input: ["a", ",", "a", ","], message: "testSepBy-5") // 结果不能跟着分隔符
        parser.assertFailure(input: ["a", ","], message: "testSepBy-6") // 结果不能跟着分隔符
    }
    
    func testSepBy1() {
        let parser = match("a").sepBy1(match(","))

        parser.assertSuccess(input: ["a", ",", "a", ",", "a"], value: ["a", "a", "a"], remain: [], message: "testSepBy1-1")
        parser.assertSuccess(input: ["a"], value: ["a"], remain: [], message: "testSepBy1-2")
        
        parser.assertFailure(input: ["b", ",", "b"], message: "testSepBy1-3")
        parser.assertFailure(input: [","], message: "testSepBy1-4")
        parser.assertFailure(input: ["a", ",", "a", ","], message: "testSepBy1-5") // 结果不能跟着分隔符
        parser.assertFailure(input: ["a", ","], message: "testSepBy1-6") // 结果不能跟着分隔符
    }
    
    func testEndBy() {
        let parser = match("a").endBy(match(","))
        
        parser.assertSuccess(input: ["a", ","], value: ["a"], remain: [])
        parser.assertSuccess(input: ["a", ",", "a", ","], value: ["a", "a"], remain: [])
        parser.assertSuccess(input: ["a"], value: [], remain: ["a"])
    }
    
    func testEndBy1() {
        let parser = match("a").endBy1(match(","))
        
        parser.assertSuccess(input: ["a", ","], value: ["a"], remain: [])
        parser.assertSuccess(input: ["a", ",", "a", ","], value: ["a", "a"], remain: [])
        parser.assertFailure(input: ["a"])
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
    
    func testTry() {
        let input = ["a", "b", "c"]
        
        guard case let .success((r, remain)) = match("b").try.parse(input) else {
            XCTAssert(false)
            return
        }
        
        XCTAssert(r == nil)
        XCTAssert(remain == input)
    }
    
    func testLookahead() {
        let input = ["a", "b", "c"]
        
        let parser = match("b").lookahead <|> match("a")
        parser.assertSuccess(input: input, value: "a", remain: ["b", "c"])
    }
    
//    func testNotFollowedBy() {
//        let input = ["a", "b", "c"]
//
//        match("a").notFollowedBy(match("c")).assertSuccess(input: input, value: "a", remain: ["b", "c"])
//        match("a").notFollowedBy(match("b")).assertFailure(input: input)
//        match("b").notFollowedBy(match("b")).assertFailure(input: input)
//    }
    
    func testRep() {
        let input = ["a", "a", "a", "b", "c"]
        
        match("a").repeat(2).assertSuccess(input: input, value: ["a", "a", "a"], remain: ["b", "c"])
        match("a").repeat(3).assertSuccess(input: input, value: ["a", "a", "a"], remain: ["b", "c"])
        match("a").repeat(4).assertFailure(input: input)
    }
}
