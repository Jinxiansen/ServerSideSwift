
//
//  PageViewMeddleware.swift
//  App
//
//  Created by Jinxiansen on 2018/5/30.
//

import Vapor

public final class PageViewMeddleware : Middleware {
    
    public func respond(to request: Request, chainingTo next: Responder) throws -> EventLoopFuture<Response> {
    
        try printLog(request)
    
        return try next.respond(to: request)
    }
    
    func printLog(_ request: Request) throws {
        
        let method = request.http.method
        let path = request.http.url.absoluteString
        let reqString = "\(method) \(path) \(TimeManager.currentTime()) \n"
        print(reqString)
        
    }
 
    
}





