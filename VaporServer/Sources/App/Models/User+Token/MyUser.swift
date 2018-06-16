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

struct MyUser: Content,MySQLModel,Migration {
    var id: Int?
    
    var userID: String?
//    static var entity: String { return "myusers" }

    private(set) var email: String
    var password: String
    
}

//extension MyUser: Timestampable {
//    static var createdAtKey: WritableKeyPath<MyUser, Date?> {
//        return MyUser.createdAtKey
//    }
//
//    static var updatedAtKey: WritableKeyPath<MyUser, Date?> {
//        return MyUser.updatedAtKey
//    }
//
//}

extension MyUser: BasicAuthenticatable {
    static var usernameKey: WritableKeyPath<MyUser, String> = \.email
    static var passwordKey: WritableKeyPath<MyUser, String> = \.password
}

//extension MyUser: TokenAuthenticatable {
//
//    typealias TokenType = AccessToken
//}

//MARK: Validatable
extension MyUser: Validatable {
    
    static func validations() throws -> Validations<MyUser> {
        var valid = Validations(MyUser.self)
        valid.add(\.email, at: [], .email)
        valid.add(\.password, at: [], .password)
        
        return valid
    }
}


//extension MyUser {
//
//    func isExist(_ req: Request) throws -> Future<Bool> {
//        return try User.query(on: req).filter(\.email == self.email).first().map({ (user) in
//            return user != nil
//        })
//    }
//
//}
//
//
//extension MyUser: Parameter { }










