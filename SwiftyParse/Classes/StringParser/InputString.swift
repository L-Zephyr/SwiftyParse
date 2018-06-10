//
//  InputString.swift
//  SwiftyParse
//
//  Created by LZephyr on 2018/6/6.
//  Copyright © 2018年 LZephyr. All rights reserved.
//

import Foundation


/// 作为数据源输入的字符串
public struct InputString {
    let characters: [Character] // 剩余的字符
    let row: Int // 当前位置在原始输入中的行号
    let column: Int // 当前位置在原始输入中的列号
}

// MARK: - Extension

public extension InputString: Sequence {
    typealias Element = Character
    typealias Iterator = Array<Character>.Iterator
    
    func makeIterator() -> Iterator {
        return self.characters.makeIterator()
    }
}

public extension InputString: Equatable {
    static func == (_ lhs: InputString, _ rhs: InputString) -> Bool {
        return lhs.characters == rhs.characters && lhs.row == rhs.row && lhs.column == rhs.column
    }
}

public extension InputString {
    /// 去掉第一个字符，向前进一位，重新计算当前的位置
    func dropFirst() -> InputString {
        let (first, remain) = self.characters.decompose()
        if let first = first {
            switch first {
            case "\n":
                return InputString(characters: remain, row: row + 1, column: 0)
            case "\t":
                return InputString(characters: remain, row: row, column: column + 8)
            default:
                return InputString(characters: remain, row: row, column: column + 1)
            }
        }
        return InputString(characters: remain, row: row, column: column)
    }
    
    /// 去掉前n个字符
    func drop(_ n: Int) -> InputString {
        var result: InputString = self
        for _ in 0..<n {
            result = result.dropFirst()
        }
        return result
    }
    
    /// 获取第一个字符
    func first() -> Character? {
        return self.characters.first
    }
    
    /// 是否包含指定前缀
    func hasPrefix(_ s: String) -> Bool {
        return String(characters).hasPrefix(s) // ?
    }
}
