//
//  AuthUserMiddleware.swift
//  App
//
//  Created by Jinxiansen on 2018/6/7.
//

import Vapor

struct AuthUserMiddleware: Middleware {
    
    func respond(to request: Request, chainingTo next: Responder) throws -> EventLoopFuture<Response> {
        
        if let authToken = request.http.headers.firstValue(name: HTTPHeaderName("Authorization")) {
            print("the authToken is \(authToken)")
        }else {
            print("没有token\n")
        }
        
        
        return try next.respond(to: request)
    }
    
}


