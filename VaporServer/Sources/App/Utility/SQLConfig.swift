//
//  MySQLConfig.swift
//  App
//
//  Created by 晋先森 on 2018/6/21.
//

import Foundation
import Vapor
import FluentPostgreSQL

extension PostgreSQLDatabaseConfig {
    
    static func loadSQLConfig(_ env: Environment) -> PostgreSQLDatabaseConfig {
        
        let database = env.isRelease ? "vaporDB":"vaporDebugDB"
        
        var hostname = "127.0.0.1"
        var username = "vapor"
        var password = ""
        var port = 5432
        
        #if os(Linux)
        let manager = FileManager.default
        let path = "/home/ubuntu/base.json"
        if let data = manager.contents(atPath: path) {
            
            struct Base: Content {
                var hostname: String
                var username: String
                var password: String
                var port: Int
            }
            
            if let base = try? JSONDecoder().decode(Base.self, from: data) {
                print(base.username,"\n\n")
                hostname = base.hostname
                username = base.username
                password = base.password
                port = base.port
            }else {
                PrintLogger().warning("数据库配置读取失败： 目录 \(path) 不存在！")
            }
        }
        #endif
        
        PrintLogger().info("启动数据库：\(database) \n")
        
        #if os(Linux)
        return PostgreSQLDatabaseConfig(hostname: hostname,
                                        port: port,
                                        username: username,
                                        database: database,
                                        password:password)
        #else
        return PostgreSQLDatabaseConfig(hostname: hostname,
                                        port: port,
                                        username: username,
                                        database: database)
        #endif
    }
        
}





