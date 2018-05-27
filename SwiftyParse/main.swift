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
    return Int(digits.joined()) ?? 0
}


/*
 左递归文法
 expr ::= expr addop factor | factor
 addop ::= + | -
 factor ::= nat | ( expr )
 
 改写后的非左递归文法
 expr ::= factor
 */

let addop = S.char("+") <|> S.char("-")

