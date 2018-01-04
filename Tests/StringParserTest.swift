//
//  StringParserTest.swift
//  Tests
//
//  Created by LZephyr on 2018/1/3.
//  Copyright © 2018年 LZephyr. All rights reserved.
//

import XCTest

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
        char("h").assertSuccess(input: "hello", value: "h", remain: "ello")
    }
    
    func testSpaces() {
        
    }
}
