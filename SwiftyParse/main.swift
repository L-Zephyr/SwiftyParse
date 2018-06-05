//
//  main.swift
//  SwiftyParse
//
//  Created by LZephyr on 2017/12/30.
//  Copyright © 2017年 LZephyr. All rights reserved.
//

import Foundation

extension Array where Element == String {
    var merged: String {
        var result = ""
        for s in self {
            result.append(s)
        }
        return result
    }
}

let input = "123+456"

let parser = S.digit

// 匹配一个整数
let integer = S.digit.many1.map { (digits) -> Int in
    return Int(digits.joined())!
}

let integer2 = S.digit.map { Int($0)! }
    .chainL(Parser<(Int, Int) -> Int, InputString>.result({ return 10 * $0 + $1 }))

print(integer2.parse("1234"))

/*
 左递归文法
 expr ::= expr addop factor | factor
 addop ::= + | -
 factor ::= nat | ( expr )
 
 改写后的非左递归文法
 expr = factor expr'
 expr' = addop factor expr' |
 addop = + | -
 factor = nat | ( expr )
 */

func add(_ n1: Int, _ n2: Int) -> Int {
    return n1 + n2
}

func minus(_ n1: Int, _ n2: Int) -> Int {
    return n1 - n2
}

//let factor = integer
//let addop = S.char("+").map { _ in add } <|> S.char("-").map { _ in minus }
//

