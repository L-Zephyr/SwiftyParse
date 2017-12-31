//
//  ParserTest.swift
//  Tests
//
//  Created by LZephyr on 2017/12/30.
//  Copyright © 2017年 LZephyr. All rights reserved.
//

import XCTest

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
                return .failure(ParseError.Unkown)
            }
            return .success((s, Array(strings.dropFirst())))
        })
    }
    
    // MARK: - Functor

    func testMap() {
        let parser = match("a").map { (result) -> String in
            return result + result
        }
        
        guard case let .success((r, remain)) = parser.parse(["a", "b", "c"]) else {
            XCTAssert(false)
            return
        }
        
        XCTAssert(r == "aa")
        XCTAssert(remain.count == 2)
    }

    // MARK: - Applicative
    
    // MARK: - Alternative
    
    // MARK: - Monad
    
    // MARK: - Operators
    
    func testSeparatedBySuccess() {
        let input = ["a", ",", "a", ",", "a"]
        let parser = match("a").separatedBy(match(","))
        guard case let .success((r, remain)) = parser.parse(input) else {
            XCTAssert(false)
            return
        }
        XCTAssert(r == ["a", "a", "a"])
        XCTAssert(remain.count == 0)
    }
    
    func testSeparatedByFail() {
        let input = ["a"]
        let parser = match("a").separatedBy(match(","))
        guard case .failure(_) = parser.parse(input) else {
            XCTAssert(false)
            return
        }
    }
    
    func testSeparatedByEmpty() {
        let input = ["b"]
        let parser = match("a").separatedBy(match(","))
        guard case let .success((r, remain)) = parser.parse(input) else {
            XCTAssert(false)
            return
        }
        XCTAssert(r == [])
        XCTAssert(remain == ["b"])
    }
    
    func testMany() {
        let input = ["a", "a", "b"]
        
        guard case let .success((r, remain)) = match("a").many.parse(input) else {
            XCTAssert(false)
            return
        }
        XCTAssert(r == ["a", "a"])
        XCTAssert(remain == ["b"])
        
        guard case .failure(_) = match("b").many.parse(input) else {
            XCTAssert(false)
            return
        }
    }
    
    func testBetween() {
        let input = ["a", "b", "c"]
        guard case let .success((r, remain)) = match("b").between(match("a"), match("c")).parse(input) else {
            XCTAssert(false)
            return
        }
        
        XCTAssert(r == "b")
        XCTAssert(remain == [])

        guard case .failure(_) = match("a").between(match("a"), match("b")).parse(input) else {
            XCTAssert(false)
            return
        }
    }
}
