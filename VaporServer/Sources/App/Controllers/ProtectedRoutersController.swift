//
//  ProtectedRoutersController.swift
//  App
//
//  Created by Jinxiansen on 2018/6/1.
//

import Foundation
import Vapor
import Crypto
import Authentication

struct ProtectedRoutersController: RouteCollection {
    
    func boot(router: Router) throws {
        
//        let group = router.grouped("api","protected")
        
//        let basicAuthMiddleware = LoginUser.basicAuthMiddleware(using: BCrypt)
//        let guardAuthmiddleware = LoginUser.guardAuthMiddleware()
//        let basicAuthGroup = group.grouped([basicAuthMiddleware,guardAuthmiddleware])
//        basicAuthGroup.get("basic", use: basicAuthRouteHandle)
//        
//        let tokenAuthMiddleware = LoginUser.tokenAuthMiddleware()
//        let tokenAuthGroup = group.grouped([tokenAuthMiddleware,guardAuthmiddleware])
//        tokenAuthGroup.get("token", use: tokenAuthRouteHandler)
        
    }
    
}


extension ProtectedRoutersController {
    
    func basicAuthRouteHandle(_ req: Request) throws -> LoginUser {
        return try req.requireAuthenticated(LoginUser.self)
    }
    
    func tokenAuthRouteHandler(_ req: Request) throws -> LoginUser {
        return try req.requireAuthenticated(LoginUser.self)
    }
    
}
