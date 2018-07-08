//
//  CrawlerLog.swift
//  App
//
//  Created by Jinxiansen on 2018/7/5.
//

import Foundation
import Vapor
import FluentPostgreSQL

struct CrawlerLog: BaseSQLModel {
    
    var id: Int?
    static var entity: String { return self.name + "s" }

    var title: String
    var content: String?
    var time: String?
    var desc: String?
    
    static var createdAtKey: TimestampKey? = \CrawlerLog.createdAt
    static var updatedAtKey: TimestampKey? = \CrawlerLog.updatedAt
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
    
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        return Database.create(self, on: connection, closure: { (builder) in
            builder.field(for: \.id, isIdentifier: true)
            builder.field(for: \.title)
            builder.field(for: \.time)
            builder.field(for: \.createdAt)
            builder.field(for: \.updatedAt)
            builder.field(for: \.content, type: .text)
            builder.field(for: \.desc, type: .text)
            
            // 在MySQL 数据库中，String 默认为 varchar(256) ，如果大于 256 将导致无法存储，所以需要声明为 .text ，
            // 但是在 PostgreSQL 中，则没有这个问题，默认即为 .text 自增。
        })
    }
    
    static func revert(on connection: PostgreSQLConnection) -> Future<Void> {
        return Database.delete(self, on: connection)
    }
}
