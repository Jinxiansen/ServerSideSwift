//
//  ExceptionMiddleware.swift
//  App
//
//  Created by Jinxiansen on 2018/6/14.
//

import Foundation
import Vapor

public final class ExceptionMiddleware: Middleware,Service {

    private let closure: (Request) throws -> (Future<Response>?)

    init(closure: @escaping (Request) throws -> (Future<Response>?)) {
        self.closure = closure
    }
    
    public func respond(to request: Request, chainingTo next: Responder) throws -> EventLoopFuture<Response> {
        
        return try next.respond(to: request).flatMap({ (resp) in
            
            let status = resp.http.status
            if status == .notFound {
                if let resp = try self.closure(request) {
                    return resp
                }
            }
            
            return try next.respond(to: request)
        })
    }
    
}







