//
//  main.swift
//  SwiftyParse
//
//  Created by LZephyr on 2017/12/30.
//  Copyright © 2017年 LZephyr. All rights reserved.
//

import Foundation

let parser = StringParser.satisfy("a").many

print(parser.parse("aabc"))
