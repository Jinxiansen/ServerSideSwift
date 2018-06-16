//
//  EmailState.swift
//  App
//
//  Created by Jinxiansen on 2018/5/28.
//

import Vapor
import FluentMySQL

struct EmailSendResult: BaseSQLModel {
    var id: Int?
    
    static var entity: String { return self.name + "s" }

    var state: Bool?
    var email: String?
    var sendTime: String?
    
    
}
 
