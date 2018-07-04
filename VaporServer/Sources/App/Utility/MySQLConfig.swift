//
//  MySQLConfig.swift
//  App
//
//  Created by 晋先森 on 2018/6/21.
//

import Foundation
import Vapor

struct MySQLConfig {
    
    var hostname: String
    var port: Int
    var username: String
    var password: String
    var database: String
    
}


extension MySQLConfig {
    
    static func sqlData(_ env: Environment) -> MySQLConfig {
        
        let database = env.isRelease ? "vaporDB":"vaporDebugDB"
        
        var hostname = "localhost"
        var username = "sqluser"
        var password = "qwer1234"
        var port = 3306
        
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
                print(base.username,base.password,"\n\n")
                hostname = base.hostname
                username = base.username
                password = base.password
                port = base.port
            }else {
                PrintLogger().warning("数据库配置读取失败： 目录 \(path) 不存在！")
                Abort.init(.gone)
            }
        }
        #endif
        
        PrintLogger().info("启动数据库：\(database) \n")
        return MySQLConfig(hostname: hostname, port: port, username: username, password: password, database: database)
    }
        
}





