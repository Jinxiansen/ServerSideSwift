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
        
//        let basicAuthMiddleware = MyUser.basicAuthMiddleware(using: BCrypt)
//        let guardAuthmiddleware = MyUser.guardAuthMiddleware()
//        let basicAuthGroup = group.grouped([basicAuthMiddleware,guardAuthmiddleware])
//        basicAuthGroup.get("basic", use: basicAuthRouteHandle)
//        
//        let tokenAuthMiddleware = MyUser.tokenAuthMiddleware()
//        let tokenAuthGroup = group.grouped([tokenAuthMiddleware,guardAuthmiddleware])
//        tokenAuthGroup.get("token", use: tokenAuthRouteHandler)
        
    }
    
}


extension ProtectedRoutersController {
    
    func basicAuthRouteHandle(_ req: Request) throws -> MyUser {
        return try req.requireAuthenticated(MyUser.self)
    }
    
    func tokenAuthRouteHandler(_ req: Request) throws -> MyUser {
        return try req.requireAuthenticated(MyUser.self)
    }
    
}
