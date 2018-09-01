//
//  LocalHostMiddleware.swift
//  App
//
//  Created by Jinxiansen on 2018/7/5.
//

import Foundation
import Vapor

//以下 uris 中包含的 api，只允许本地访问。
public final class LocalHostMiddleware: Middleware,Service {
    
    public func respond(to request: Request, chainingTo next: Responder) throws -> EventLoopFuture<Response> {
        
        let urlString = request.http.urlString
        var container = false
        
        let paths = urlPaths()
        
        _ = paths.map { if urlString.contains($0) { container = true } }
        
        #if os(Linux)
        if container {
            if let hostName = request.http.remotePeer.hostname?.description {
                if hostName.contains("localhost") || hostName.contains("127.0.0.1") {
                    return try next.respond(to: request)
                }else{
                    return try ResponseJSON<Empty>(status: .error,
                                                   message: "无权访问").encode(for: request)
                }
            }
        }
        #endif
        
        return try next.respond(to: request)
    }
    
}

extension LocalHostMiddleware {
    
    func urlPaths() -> [String] {
        
        return ["lagou/start",
                "lagou/getLogs",
                "lagou/cancel",
                "book/start",
                "job/start",
                "job/stop",
                "enJob/start",
                ]
    }
    
}










