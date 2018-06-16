//
//  Word.swift
//  App
//
//  Created by 晋先森 on 2018/6/10.
//

import Foundation
import Vapor
import FluentMySQL

struct Word: BaseSQLModel {
    var id: Int?
    
    static var entity: String { return self.name + "s" }

    var word: String
    var oldword: String?
    var strokes: String?
    var pinyin: String?
    var radicals: String?
    var explanation: String?
    var more: String?

}





