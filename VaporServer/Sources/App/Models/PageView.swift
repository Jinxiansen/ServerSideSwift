//
//  PageView.swift
//  App
//
//  Created by Jinxiansen on 2018/5/30.
//

import Vapor
import FluentMySQL

struct PageView: MySQLModel {
    var id: Int?
    
    var time: String?
    var desc: String?
    var ip: String?
    var body: String?
    var url: String?
    
//    var version: String?
    
    init(time: String = TimeManager.shared.currentTime(),
         desc:String?,
         ip: String?,
         body: String?,
         url: String?
//         version: String?
        ) {
        
        self.time = time
        self.desc = desc
        self.ip = ip
        self.body = body
        self.url = url
//        self.version = version
    }
}


extension PageView: Migration {}

extension PageView: Content { }
extension PageView: Parameter { }
