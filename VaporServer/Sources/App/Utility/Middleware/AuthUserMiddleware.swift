//
//  AuthUserMiddleware.swift
//  App
//
//  Created by Jinxiansen on 2018/6/7.
//

import Vapor

struct AuthUserMiddleware: Middleware {
    
    func respond(to request: Request, chainingTo next: Responder) throws -> EventLoopFuture<Response> {
        
        // ...
        
        return try next.respond(to: request)
    }
    
}


