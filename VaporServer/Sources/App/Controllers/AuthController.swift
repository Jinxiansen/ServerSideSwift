//
//  AuthController.swift
//  App
//
//  Created by Jinxiansen on 2018/6/1.
//

import Foundation
import Vapor
import Fluent
import FluentMySQL
import Crypto

struct AuthController {
    
    func authContainer(for refreshToken: RefreshToken.Token, on connection: DatabaseConnectable) throws -> Future<AuthContainer> {
        return try existingUser(matchingTokenString: refreshToken, on: connection).flatMap({ (user) in
            guard let user = user else { throw Abort(.notFound) }
            return try self.authContainer(for: user, on: connection)
        })
    }
    
    func authContainer(for user: MyUser,on connection: DatabaseConnectable) throws -> Future<AuthContainer> {
        return try removeAllTokens(for: user, on: connection).flatMap({ _ in
            return try map(to: AuthContainer.self, self.accessToken(for: user, on: connection), self.refreshToken(for: user, on: connection), { (access, refresh) in
                return AuthContainer(accessToken: access, refreshToken: refresh)
            })
        })
    }
    
    func remokeTokens(forEmail email: String,on connection: DatabaseConnectable) throws -> Future<Void> {
        return try MyUser.query(on: connection).filter(\.email == email).first().flatMap({ (user) in
            guard let user = user else { return Future.map(on: connection) { Void()} }
            return try self.removeAllTokens(for: user, on: connection)
        })
    }
    
}


private extension AuthController {
    
    func existingUser(matchingTokenString tokenString: RefreshToken.Token,on connection: DatabaseConnectable) throws -> Future<MyUser?> {
        return try RefreshToken.query(on: connection).filter(\.tokenString == tokenString).first().flatMap({ (token) in
            guard let token = token else { throw Abort(.notFound) }
            return try MyUser.query(on: connection).filter(\.userID == token.userID).first()
        })
    }
    
    func existingUser(matching user: MyUser, on connection: DatabaseConnectable) throws -> Future<MyUser?> {
        return try MyUser.query(on: connection).filter(\.email == user.email).first()
    }
    
    func removeAllTokens(for user:MyUser,on connection: DatabaseConnectable) throws -> Future<Void> {
        let accessTokens = try AccessToken.query(on: connection).filter(\.userID == user.userID).delete()
        let refreshToken = try RefreshToken.query(on: connection).filter(\.userID == user.userID).delete()
        return map(to: Void.self, accessTokens, refreshToken, { (_, _) in
            Void()
        })
    }
    
    func accessToken(for user: MyUser, on connection: DatabaseConnectable) throws -> Future<AccessToken> {
        return try AccessToken(userID: user.userID ?? "").save(on: connection)
    }
    
    func refreshToken(for user: MyUser,on connection: DatabaseConnectable) throws -> Future<RefreshToken> {
        return try RefreshToken(userID: user.userID ?? "").save(on: connection)
    }
    
    func accessToken(for refreshToken: RefreshToken,on connection: DatabaseConnectable) throws -> Future<AccessToken> {
        return try AccessToken(userID: refreshToken.userID).save(on: connection)
    }
    
 
    
}
