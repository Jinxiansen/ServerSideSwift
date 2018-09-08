//
//  User.swift
//  App
//
//  Created by 晋先森 on 2018/5/26.
//

import Authentication


struct APPUser: BaseSQLModel {
    
    var id: Int?
    
    var userID: String?
    
    static var entity: String { return self.name + "s" }
    
    private(set) var account: String
    var password: String
 
    init(userID: String,account: String,password: String) {
        self.userID = userID
        self.account = account
        self.password = password
    }
   
    static var createdAtKey: TimestampKey? = \APPUser.createdAt
    static var updatedAtKey: TimestampKey? = \APPUser.updatedAt
    var createdAt: Date?
    var updatedAt: Date?
    
}


extension APPUser: BasicAuthenticatable {
    static var usernameKey: WritableKeyPath<APPUser, String> = \.account
    static var passwordKey: WritableKeyPath<APPUser, String> = \.password
}

//extension User: TokenAuthenticatable {
//
//    typealias TokenType = AccessToken
//}
//
//extension User: Validatable {
//
//    static func validations() throws -> Validations<User> {
//        var valid = Validations(User.self)
//        valid.add(\.account, at: [], .account)
//        valid.add(\.password, at: [], .password)
//
//        return valid
//    }
//}
//




