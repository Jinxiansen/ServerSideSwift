//
//  XieHouIdiom.swift
//  App
//
//  Created by 晋先森 on 2018/6/10.
//


// 歇后语对象，这个词特么实在没找着个像样的翻译。
struct XieHouIdiom: BaseSQLModel {
    
    var id: Int?
    static var entity: String { return self.name + "s" }

    var riddle : String //前半句
    var answer : String //后半句

}
