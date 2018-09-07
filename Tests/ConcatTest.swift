//
//  ConcatTest.swift
//  Tests
//
//  Created by LZephyr on 2018/4/6.
//  Copyright © 2018年 LZephyr. All rights reserved.
//

import XCTest
@testable import SwiftyParse

class ConcatTest: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSingleAddSingle() {
        let parser = match("a") ++ match("b")
        
        parser.assertSuccess(input: ["a", "b", "c"], value: ["a", "b"], remain: ["c"])
        parser.assertSuccess(input: ["a", "b"], value: ["a", "b"], remain: [])
        parser.assertFailure(input: ["a", "c"])
    }
    
    func testSingleAddSeq() {
        let parser = match("a") ++ match("b").many
        
        parser.assertSuccess(input: ["a", "b", "b", "c"], value: ["a", "b", "b"], remain: ["c"])
        parser.assertSuccess(input: ["a", "b", "b"], value: ["a", "b", "b"], remain: [])
        parser.assertSuccess(input: ["a", "b"], value: ["a", "b"], remain: [])
        parser.assertSuccess(input: ["a"], value: ["a"], remain: []) // many可以为空
        parser.assertSuccess(input: ["a", "c"], value: ["a"], remain: ["c"])
        parser.assertSuccess(input: ["a", "a", "b", "c"], value: ["a"], remain: ["a", "b", "c"])
        
        parser.assertFailure(input: ["b"])
    }
    
    func testSeqAddSingle() {
        let parser = match("a").many ++ match("b")
        
        parser.assertSuccess(input: ["a", "b", "b", "c"], value: ["a", "b"], remain: ["b", "c"])
        parser.assertSuccess(input: ["a", "b", "b"], value: ["a", "b"], remain: ["b"])
        parser.assertSuccess(input: ["a", "b"], value: ["a", "b"], remain: [])
        parser.assertSuccess(input: ["a", "a", "b", "c"], value: ["a", "a", "b"], remain: ["c"])
        parser.assertSuccess(input: ["b"], value: ["b"], remain: [])

        parser.assertFailure(input: ["c"])
        parser.assertFailure(input: ["a", "c"])
        parser.assertFailure(input: ["a"])
    }
    
    func testSeqAddSeq() {
        let parser = match("a").many ++ match("b").many
        
        parser.assertSuccess(input: ["a", "a", "b", "b", "c"], value: ["a", "a", "b", "b"], remain: ["c"])
        parser.assertSuccess(input: ["a", "a", "b"], value: ["a", "a", "b"], remain: [])
        parser.assertSuccess(input: ["a", "b", "b"], value: ["a", "b", "b"], remain: [])
    }
}
