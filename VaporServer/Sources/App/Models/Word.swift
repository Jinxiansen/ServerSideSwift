//
//  Word.swift
//  App
//
//  Created by 晋先森 on 2018/6/10.
//

import Foundation
import Vapor
import FluentMySQL

struct Word: MySQLModel {
    var id: Int?
    
    var word: String
    var oldword: String?
    var strokes: String?
    var pinyin: String?
    var radicals: String?
    var explanation: String?
    var more: String?

}

extension Word: Migration {}

extension Word: Content { }
extension Word: Parameter { }






