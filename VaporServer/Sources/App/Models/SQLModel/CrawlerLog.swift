//
//  CrawlerLog.swift
//  App
//
//  Created by Jinxiansen on 2018/7/5.
//

import Foundation
import Vapor
import FluentMySQL

struct CrawlerLog: BaseSQLModel {
    
    var id: Int?
    static var entity: String { return self.name + "s" }

    var title: String
    var content: String?
    var time: String?
    var desc: String?
    
    static let createdAtKey: TimestampKey? = \CrawlerLog.createdAt
    static let updatedAtKey: TimestampKey? = \CrawlerLog.updatedAt
    var createdAt: Date?
    var updatedAt: Date?
    
    init(title: String,content: String?,time: String,desc: String?) {
        self.title = title
        self.content = content
        self.time = time
        self.desc = desc
    }
    
}


extension CrawlerLog {
    
    static func prepare(on connection: MySQLConnection) -> Future<Void> {
        return Database.create(self, on: connection, closure: { (builder) in
            builder.field(for: \.id, isIdentifier: true)
            builder.field(for: \.title)
            builder.field(for: \.time)

            builder.field(for: \.content, type: .text)
            builder.field(for: \.desc, type: .text)
        })
    }
    
    static func revert(on connection: MySQLConnection) -> Future<Void> {
        return Database.delete(self, on: connection)
    }
}
