//
//  AuthRouteController.swift
//  App
//
//  Created by Jinxiansen on 2018/6/1.
//

import Foundation
import Vapor
import Fluent
import Crypto
import Authentication

struct AuthenRouteController: RouteCollection {
    
    private let authController = AuthController()
    
    func boot(router: Router) throws {
        
        let group = router.grouped("api","token")
        
        group.post(RefreshTokenContainer.self, at: "refresh", use: refreshAccessTokenHandler)
        
        let basicAuthMiddleware = LoginUser.basicAuthMiddleware(using: BCrypt)
        let guardAuthMiddleware = LoginUser.guardAuthMiddleware()
        
        let basicAuthGroup = group.grouped([basicAuthMiddleware,guardAuthMiddleware])
        basicAuthGroup.post(UserIDContainer.self, at: "revoke", use: accessTokenRevocationHandler)
    }
    
}


extension AuthenRouteController {
    
    func refreshAccessTokenHandler(_ req: Request,container: RefreshTokenContainer) throws -> Future<AuthContainer> {
        return try authController.authContainer(for: container.refreshToken, on: req)
    }
    
    func accessTokenRevocationHandler(_ req: Request,container: UserIDContainer) throws -> Future<HTTPResponseStatus> {
        return try authController.remokeTokens(userID: container.userID, on: req).transform(to: .noContent)
    }
}


struct UserIDContainer: Content {
    
    let userID: String
    
    
}




