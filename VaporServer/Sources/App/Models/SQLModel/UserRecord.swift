//
//  UserRecord.swift
//  App
//
//  Created by Jinxiansen on 2018/6/5.
//

import Vapor
import FluentMySQL

struct UserRecord: BaseSQLModel {
    
    var id: Int?
    
    static var entity: String { return self.name + "s" }
 
    var userID: String?
    var content: String?
    var title: String
    var time: String?
    var imgName: String?
    
}
