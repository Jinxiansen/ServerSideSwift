//
//  FanRenBook.swift
//  App
//
//  Created by Jinxiansen on 2018/7/24.
//

import Foundation
import FluentPostgreSQL

struct BookChapter: BaseSQLModel {
    var id: Int?
    
    static var entity: String { return self.name + "s" }
    
    var typeId: Int
    var bookId: Int
    var bookName: String?
    
    var chapterId: Int
    var chapterName: String?
    
    var updateTime: String?
    var content: String?
    var auther: String?
    var desc: String?
 
    
    
}

extension BookChapter {
    
//    static func revert(on connection: PostgreSQLConnection) -> Future<Void> {
//        return Database.delete(self, on: connection)
//    }
}
