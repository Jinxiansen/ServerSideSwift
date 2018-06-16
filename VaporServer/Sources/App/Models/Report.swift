//
//  Report.swift
//  App
//
//  Created by Jinxiansen on 2018/6/15.
//

import Foundation
import Vapor
import FluentMySQL

struct Report: MySQLModel {
    var id: Int?
    
    var userID: String
    var receiveID: String
    var content: String
    var imgName: String?
    var imgName2: String?
    var contact: String?
    
}


extension Report: Content {}
extension Report: Parameter {}
extension Report: Migration {}
