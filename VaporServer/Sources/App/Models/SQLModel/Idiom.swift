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


// 歇后语对象，这个词特么实在没找着个像样的翻译。
struct XieHouIdiom: BaseSQLModel {
    
    var id: Int?
    static var entity: String { return self.name + "s" }
    
    var riddle : String //前半句
    var answer : String //后半句
    
}


// 单词
struct SinWord: BaseSQLModel {
    
    var id: Int?
    static var entity: String { return self.name + "s" }
    
    var ci: String
    var explanation: String?
}

// 字
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


