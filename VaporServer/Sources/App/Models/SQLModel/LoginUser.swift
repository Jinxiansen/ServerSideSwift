//
//  User.swift
//  App
//
//  Created by 晋先森 on 2018/5/26.
//

import Foundation
import Vapor
import FluentMySQL
import Authentication

struct LoginUser: BaseSQLModel {
    var id: Int?
    
    var userID: String?
    
    static var entity: String { return self.name + "s" }

    private(set) var email: String
    var password: String
 
    init(userID: String,email: String,password: String) {
        self.userID = userID
        self.email = email
        self.password = password
    }
   
    static let createdAtKey: TimestampKey? = \LoginUser.createdAt
    static let updatedAtKey: TimestampKey? = \LoginUser.updatedAt
    var createdAt: Date?
    var updatedAt: Date?
}


extension LoginUser {
 
    func validation() -> (Bool,String) {
        
        if email.isAccount().0 == true {
            return email.isAccount()
        }
        
        if password.isPassword().0 == true {
            return email.isPassword()
        }
        
        if password == email {
            return (false,"账号密码不能一样")
        }
        return (true,"验证成功")
    }
}

extension LoginUser: BasicAuthenticatable {
    static var usernameKey: WritableKeyPath<LoginUser, String> = \.email
    static var passwordKey: WritableKeyPath<LoginUser, String> = \.password
}

//extension LoginUser: TokenAuthenticatable {
//
//    typealias TokenType = AccessToken
//}

extension LoginUser: Validatable {
    
    static func validations() throws -> Validations<LoginUser> {
        var valid = Validations(LoginUser.self)
        valid.add(\.email, at: [], .email)
        valid.add(\.password, at: [], .password)
        
        return valid
    }
}





