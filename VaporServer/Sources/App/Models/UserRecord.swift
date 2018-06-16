//
//  UserRecord.swift
//  App
//
//  Created by Jinxiansen on 2018/6/5.
//

import Vapor
import FluentMySQL

struct UserRecord: Content, MySQLModel,Migration {
    
    var id: Int?
    
    var userID: String?
    var content: String?
    var key: String?
    var time: String?
    var imgName: String?
    
}
