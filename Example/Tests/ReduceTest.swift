//
//  ReduceTest.swift
//  Tests
//
//  Created by LZephyr on 2018/5/27.
//  Copyright © 2018年 LZephyr. All rights reserved.
//

import XCTest
@testable import SwiftyParse

class ReduceTest: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func addop(_ n1: Int, _ n2: Int) -> Int {
        return n1 + n2
    }
    
    // x^y
    func expop(_ x: Int, _ y: Int) -> Int {
        return Int(pow(Double(x), Double(y)))
    }

    func testReduce1() {
        let num = S.digit.map { Int($0)! }
        let expr = num.reduce(0, addop)
        
        expr.assertSuccess(input: ["1", "2", "3"], value: 6, remain: [])
        expr.assertSuccess(input: [], value: 0, remain: [])
        expr.assertSuccess(input: ["v", "s"], value: 0, remain: ["v", "s"])
    }
    
    func testReduce2() {
        let num = S.digit.map { Int($0)! }
        let add = S.char("+").map { _ in return self.addop }
        let expr = num.reduce(0, add)
        
        expr.assertSuccess(input: ["1", "2", "3"], value: 0, remain: ["1", "2", "3"], message: "Reduce1")
        expr.assertSuccess(input: ["1", "+", "2", "+", "3"], value: 0, remain: ["1", "+", "2", "+", "3"], message: "Reduce2")
        expr.assertSuccess(input: ["+", "2", "+", "3", "+"], value: 5, remain: ["+"], message: "Reduce3")
        expr.assertSuccess(input: ["v", "s"], value: 0, remain: ["v", "s"], message: "Reduce4")
    }
    
    func testChainLeft() {
        let num = S.digit.map { Int($0)! }
        let add = S.char("+").map { _ in return self.addop }
        let expr = num.chainL(add)
        
        expr.assertSuccess(input: ["1", "2", "3"], value: 1, remain: ["2", "3"])
        expr.assertSuccess(input: ["1", "+", "2", "+", "3"], value: 6, remain: [])
        expr.assertSuccess(input: ["1", "+", "2", "+"], value: 3, remain: ["+"])
        expr.assertFailure(input: ["+", "2", "+", "3", "+"])
        expr.assertFailure(input: ["v", "s"])
    }
    
    func testChainRight() {
        let num = S.digit.map { Int($0)! }
        let exp = S.char("^").map { _ in return self.expop }
        let expr = num.chainR(exp)
        
        expr.assertSuccess(input: ["2", "^", "2", "^", "3"], value: 256, remain: [])
        expr.assertSuccess(input: ["2", "3"], value: 2, remain: ["3"])
        expr.assertFailure(input: ["c", "2", "^"])
    }
}
