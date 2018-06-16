//
//  RefreshToken.swift
//  App
//
//  Created by Jinxiansen on 2018/5/29.
//

import Vapor
import FluentMySQL
import Crypto

struct RefreshToken: Content,MySQLModel,Migration {
    var id: Int?
    
    typealias Token = String
    
    let tokenString: Token
    let userID: String
    
    init(userID: String) throws {
        self.tokenString = try CryptoRandom().generateData(count: 32).base64URLEncodedString()
        self.userID = userID
    }
}





