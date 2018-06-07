//
//  Extensions.swift
//  SwiftyParse
//
//  Created by LZephyr on 2018/6/6.
//  Copyright © 2018年 LZephyr. All rights reserved.
//

import Foundation

internal extension Sequence {
    /// 判断Sequence是否为空
    func isEmpty() -> Bool {
        for _ in self {
            return false
        }
        return true
    }
}

internal extension Array where Element == Character {
    /// 将Array的第一个元素取出来，与剩下的元素组合成一个二元组返回
    func decompose() -> (Element?, [Element]) {
        if let first = self.first {
            return (first, Array(self.dropFirst()))
        }
        return (nil, self)
    }
}
