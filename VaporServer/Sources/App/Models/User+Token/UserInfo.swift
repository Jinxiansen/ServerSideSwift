//
//  UserInfo.swift
//  App
//
//  Created by Jinxiansen on 2018/6/5.
//

import Vapor
import FluentMySQL

struct UserInfo : Content, MySQLModel {
    var id: Int?
    
    var userID: String
    
    var age: Int?
    var sex: Int?
    var nickName: String?
    
    var phone: String?
    var birthday: String?
    
    
    
}
