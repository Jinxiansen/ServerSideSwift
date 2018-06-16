//
//  EmailContent.swift
//  App
//
//  Created by Jinxiansen on 2018/5/30.
//

import Vapor

struct EmailContent: Content {

    var email: String
    var myName: String?
    var subject: String?
    var text: String?
    
    
}
