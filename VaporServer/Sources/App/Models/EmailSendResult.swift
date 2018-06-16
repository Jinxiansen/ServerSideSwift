//
//  EmailState.swift
//  App
//
//  Created by Jinxiansen on 2018/5/28.
//

import Vapor
import FluentMySQL

struct EmailSendResult: MySQLModel {
    var id: Int?
    
    var state: Bool?
    var email: String?
    var sendTime: String?
    
    
}


extension EmailSendResult: Migration { }
extension EmailSendResult: Content { }
extension EmailSendResult: Parameter { }
