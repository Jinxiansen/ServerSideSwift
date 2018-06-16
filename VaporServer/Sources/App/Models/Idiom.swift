//
//  idiom.swift
//  App
//
//  Created by 晋先森 on 2018/6/10.
//


import Foundation
import Vapor
import FluentMySQL

// 成语对象
struct Idiom: MySQLModel {
    var id: Int?
    
    var word: String
    var abbreviation: String?
    var derivation: String?
    var example: String?
    var explanation: String?
    var pinyin: String?
}


extension Idiom: Migration {}

extension Idiom: Content { }
extension Idiom: Parameter { }
