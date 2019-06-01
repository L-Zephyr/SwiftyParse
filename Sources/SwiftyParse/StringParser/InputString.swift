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
    
    var range: Range<Int> = 0..<1 // 成功解析的范围
    var offset: Int = 0 // 当前位置在文件中的偏移量
    
    init(characters: [Character], row: Int, column: Int) {
        self.characters = characters
        self.row = row
        self.column = column
        self.range = offset..<offset+1
    }
}

// MARK: - Extension

extension InputString: Sequence {
    public typealias Element = Character
    public typealias Iterator = Array<Character>.Iterator
    
    public func makeIterator() -> Iterator {
        return self.characters.makeIterator()
    }
}

extension InputString: Equatable {
    public static func == (_ lhs: InputString, _ rhs: InputString) -> Bool {
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
