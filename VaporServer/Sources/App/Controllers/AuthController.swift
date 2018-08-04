//
//  AuthController.swift
//  App
//
//  Created by Jinxiansen on 2018/6/1.
//

import Foundation
import Vapor
import Fluent
import Crypto

struct AuthController {
    
    func authContainer(for refreshToken: RefreshToken.Token, on connection: DatabaseConnectable) throws -> Future<AuthContainer> {
        return try existingUser(matchingTokenString: refreshToken, on: connection).flatMap({ (user) in
            guard let user = user else { throw Abort(.notFound) }
            return try self.authContainer(for: user, on: connection)
        })
    }
    
    func authContainer(for user: LoginUser,on connection: DatabaseConnectable) throws -> Future<AuthContainer> {
        return try removeAllTokens(for: user, on: connection).flatMap({ _ in
            return try map(to: AuthContainer.self,
                           self.accessToken(for: user, on: connection),
                           self.refreshToken(for: user, on: connection),
                           { (access, refresh) in
                return AuthContainer(accessToken: access,
                                     refreshToken: refresh)
            })
        })
    }
    
    func remokeTokens(userID: String,on connection: DatabaseConnectable) throws -> Future<Void> {
        return LoginUser
            .query(on: connection)
            .filter(\.userID == userID)
            .first()
            .flatMap({ (user) in
            guard let user = user else { return Future.map(on: connection) { Void()} }
            return try self.removeAllTokens(for: user, on: connection)
        })
    }
    
}


private extension AuthController {
    
    func existingUser(matchingTokenString tokenString: RefreshToken.Token,on connection: DatabaseConnectable) throws -> Future<LoginUser?> {
        return RefreshToken.query(on: connection)
            .filter(\.tokenString == tokenString)
            .first()
            .flatMap({ (token) in
            guard let token = token else { throw Abort(.notFound) }
            return LoginUser
                .query(on: connection)
                .filter(\.userID == token.userID)
                .first()
        })
    }
    
    func existingUser(matching user: LoginUser, on connection: DatabaseConnectable) throws -> Future<LoginUser?> {
        return LoginUser
            .query(on: connection)
            .filter(\.account == user.account)
            .first()
    }
    
    func removeAllTokens(for user:LoginUser,on connection: DatabaseConnectable) throws -> Future<Void> {
        let accessTokens = AccessToken
            .query(on: connection)
            .filter(\.userID == user.userID!)
            .delete()
        let refreshToken = RefreshToken
            .query(on: connection)
            .filter(\.userID == user.userID!)
            .delete()
        return map(to: Void.self, accessTokens, refreshToken, { (_, _) in
            Void()
        })
    }
    
    func accessToken(for user: LoginUser, on connection: DatabaseConnectable) throws -> Future<AccessToken> {
        return try AccessToken(userID: user.userID ?? "")
            .save(on: connection)
    }
    
    func refreshToken(for user: LoginUser,on connection: DatabaseConnectable) throws -> Future<RefreshToken> {
        return try RefreshToken(userID: user.userID ?? "")
            .save(on: connection)
    }
    
    func accessToken(for refreshToken: RefreshToken,on connection: DatabaseConnectable) throws -> Future<AccessToken> {
        return try AccessToken(userID: refreshToken.userID)
            .save(on: connection)
    }
    
 
    
}
