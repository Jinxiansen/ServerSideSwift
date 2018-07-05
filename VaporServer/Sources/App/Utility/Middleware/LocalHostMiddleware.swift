//
//  LocalHostMiddleware.swift
//  App
//
//  Created by Jinxiansen on 2018/7/5.
//

import Foundation
import Vapor

public final class LocalHostMiddleware: Middleware,Service {
    
    public func respond(to request: Request, chainingTo next: Responder) throws -> EventLoopFuture<Response> {
        
        let urlString = request.http.urlString
        let container = urlString.contains("lagou/start") || urlString.contains("lagou/getLogs") || urlString.contains("lagou/cancel")
        
        #if os(Linux)
        if container {
            if let hostName = request.http.remotePeer.hostname?.description {
                if hostName.contains("localhost") || hostName.contains("127.0.0.1") {
                    return try next.respond(to: request)
                }else{
                    return try ResponseJSON<Empty>(status: .error, message: "无权访问").encode(for: request)
                }
            }
        }
        #endif
        
        return try next.respond(to: request)
    }
    
}
