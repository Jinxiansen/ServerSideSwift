//
//  XieHouIdiom.swift
//  App
//
//  Created by 晋先森 on 2018/6/10.
//


import Foundation
import Vapor
import FluentMySQL

// 歇后语对象，这个词特么实在没找着个像样的翻译。
struct XieHouIdiom: MySQLModel {
    var id: Int?
    
    var riddle : String //前半句
    var answer : String //后半句

}


extension XieHouIdiom: Migration {}

extension XieHouIdiom: Content { }
extension XieHouIdiom: Parameter { }

