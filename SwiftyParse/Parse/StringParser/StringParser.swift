//
//  StringParser.swift
//  SwiftyParse
//
//  Created by LZephyr on 2017/12/30.
//  Copyright © 2017年 LZephyr. All rights reserved.
//

import Foundation

public typealias StringParser = Parser<[String], String>
public typealias StringParserResult = ParseResult<([String], String)>
//public typealias StringsParser = Parser<[String], String>

// MARK: - 连接操作符

/// 连续解析两个相同类型的Parser，两个Parser的结果保存在数组中，任一Parser出错都会返回错误
func +(_ lhs: StringParser, _ rhs: StringParser) -> StringParser {
    return StringParser(parse: { (string) -> StringParserResult in
        switch lhs.parse(string) {
        case let .success((l, lrest)):
            switch rhs.parse(lrest) {
            case let .success((r, rrest)):
                let result = [l, r].flatMap { $0 }
                return .success((result, rrest)) // 成功
            case let .failure(error):
                return .failure(error)
            }
        case let .failure(error):
            return .failure(error)
        }
    })
}

// MARK: - 解析器组合子

// 解析一个指定的字符
public func char(_ c: Character) -> StringParser {
    return StringParser(parse: { (string) -> StringParserResult in
        guard let first = string.first else {
            return .failure(ParseError.unkown) // TODO: 错误处理
        }
        guard first == c else {
            return .failure(ParseError.unkown)
        }
        let left = String(string.dropFirst())
        let result = [String(first)]
        return .success((result, left))
    })
}

// 解析一个指定的字符串
public func string(_ s: String) -> StringParser {
    return StringParser(parse: { (string) -> StringParserResult in
        guard string.hasPrefix(s) else {
            return .failure(ParseError.unkown) // TODO: 错误处理
        }
        let remain = String(string.dropFirst(s.count))
        return .success(([s], remain))
    })
}

/// 解析结束
///
/// - Returns: 输入为空则返回成功，否则返回失败
public func end() -> StringParser {
    return StringParser(parse: { (string) -> StringParserResult in
        if string.count == 0 {
            return .success(([], string))
        } else {
            return .failure(.notMatch("Input stream is not end!"))
        }
    })
}

/// 以指定的字符串作为结尾
///
/// - Parameter s: 结尾的字符串
/// - Returns: 如果成功匹配字符串并且解析结束，返回成功匹配的结果；否则返回失败
public func endBy(_ s: String) -> StringParser {
    return string(s) <* end()
}

/// 指定一个开区间范围，匹配一个落在该范围内的字符
///
/// - Parameter chars: 字符范围："1"..<"5"
/// - Returns: 匹配该范围所有字符的解析器
public func range(_ chars: Range<String>) -> StringParser {
    return StringParser(parse: { (string) -> StringParserResult in
        let (first, rest) = string.decompose()
        if let first = first, chars.contains(String(first)) {
            return .success(([String(first)], rest))
        } else {
            return .failure(.notMatch("Not match range: " + chars.description))
        }
    })
}

/// 指定一个闭区间范围，匹配一个落在该范围内的字符
///
/// - Parameter chars: 字符范围："1"..."5"
/// - Returns: 匹配该范围所有字符的解析器
public func range(_ chars: ClosedRange<String>) -> StringParser {
    return StringParser(parse: { (string) -> StringParserResult in
        let (first, rest) = string.decompose()
        if let first = first, chars.contains(String(first)) {
            return .success(([String(first)], rest))
        } else {
            return .failure(.notMatch("Not match range: " + chars.description))
        }
    })
}

/// 返回一个匹配单个单词的的Parser，包括大小写字母
///
/// - Returns: 单词解析器
public func word() -> StringParser {
    let chars = (range("a"..."z") <|> range("A"..."Z")).many1
    return chars.map {
        $0.flatMap { $0 }.reduce([""], { (result, str) -> [String] in
            return [result[0] + str]
        })
    }
}

/// 匹配一个任意的字符
///
/// - Returns: 返回一个Parser，匹配任意字符，只有在输入为空的时候才返回错误
public func anyChar() -> StringParser {
    return StringParser(parse: { (string) -> StringParserResult in
        let (first, rest) = string.decompose()
        if let first = first {
            return .success(([String(first)], rest))
        } else {
            return .failure(.endOfStream)
        }
    })
}

// MARK: - private

fileprivate extension String {
    /// 将一个字符串分解为首字符和剩余字符串
    func decompose() -> (Character?, String) {
        var str = self
        if str.count == 0 {
            return (nil, str)
        } else {
            let first = str.removeFirst()
            return (first, str)
        }
    }
}

//public extension Parser where Token == [Character], Stream == String {
//
//    /// 创建一个解析指定字符的Parser
//    static func char(_ c: Character) -> StringParser {
//        return StringParser(parse: { (string) -> ParseResult<(Character, String)> in
//            guard let first = string.first else {
//                return .failure(ParseError.unkown) // TODO: 错误处理
//            }
//            guard first == c else {
//                return .failure(ParseError.unkown)
//            }
//            let left = String(string.dropFirst())
//            return .success((first, left))
//        })
//    }
//
//    /// 创建一个解析指定字符串的Parser
//    static func string(_ s: String) -> Parser<String, String> {
//        return Parser<String, String>(parse: { (string) -> ParseResult<(String, String)> in
//            guard string.hasPrefix(s) else {
//                return .failure(ParseError.unkown) // TODO: 错误处理
//            }
//            let remain = String(string.dropFirst(s.count))
//            return .success((s, remain))
//        })
//    }
//
//    /// 匹配所有的空白符：空格、\t，不包括换行
//    ///
//    /// - Returns: parser的结果包括匹配成功的空白符，不会返回错误
//    static func spaces() -> Parser<[Character], String> {
//        return Parser<[Character], String>(parse: { (input) -> ParseResult<([Character], String)> in
//            var dropped = [Character]()
//            let remain = input.drop(while: { (c) -> Bool in
//                if c == " " || c == "\t" {
//                    dropped.append(c)
//                    return true
//                }
//                return false
//            })
//
//            return .success((dropped, String(remain)))
//        })
//    }
//}
