//
//  StringParserTest.swift
//  Tests
//
//  Created by LZephyr on 2018/1/3.
//  Copyright © 2018年 LZephyr. All rights reserved.
//

import XCTest

extension Parser {
    func assertSuccess(input: Stream, value: Token, remain: Stream) {
        
    }
    
    func assertFailure(input: Stream) {
        
    }
}

class StringParserTest: XCTestCase {
    
    let input = "hello"

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testChar() {
        switch char("h").parse(input) {
        case .success(let (r, remain)):
            XCTAssert(r == "h")
            XCTAssert(remain == "ello")
        case .failure(_):
            XCTAssert(false)
        }
    }
}
