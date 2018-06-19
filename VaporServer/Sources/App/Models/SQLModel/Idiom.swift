//
//  idiom.swift
//  App
//
//  Created by 晋先森 on 2018/6/10.
//


// 成语对象
struct Idiom: BaseSQLModel {
    var id: Int?
    
    static var entity: String { return self.name + "s" }

    var word: String
    var abbreviation: String?
    var derivation: String?
    var example: String?
    var explanation: String?
    var pinyin: String?
}
