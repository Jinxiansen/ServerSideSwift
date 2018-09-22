//
//  RefreshToken.swift
//  App
//
//  Created by Jinxiansen on 2018/5/29.
//


import Crypto

struct RefreshToken: BaseSQLModel {
    var id: Int?
    
    static var entity: String { return self.name + "s" }

    typealias Token = String
    
    let tokenString: Token
    let userID: String
    
    init(userID: String) throws {
        self.tokenString = try CryptoRandom().generateData(count: 32).base64URLEncodedString()
        self.userID = userID
    }
}





