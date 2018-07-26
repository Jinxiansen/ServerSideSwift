//
//  BookInfo.swift
//  App
//
//  Created by Jinxiansen on 2018/7/26.
//

import Foundation
import Vapor

struct BookInfo: BaseSQLModel {
    var id: Int?
    
    static var entity: String { return self.name + "s" }

    var typeId: Int
    var bookId: Int
    var bookName: String?
    var chapterCount: Int
    
    var updateTime: String?
    var content: String?
    var auther: String?
    var bookImg: String?
}
