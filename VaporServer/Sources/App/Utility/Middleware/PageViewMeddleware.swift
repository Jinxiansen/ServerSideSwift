
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
    
    func printLog(_ req: Request) throws {
        
        let method = req.http.method
        let path = req.http.url.absoluteString
        let reqString = "\(method) \(path) \(TimeManager.currentTime()) \n"
        print(reqString)
        
        let page = PageView(desc: req.http.description,
                            ip: req.http.remotePeer.description,
                            body: req.http.body.description,
                            url: req.http.urlString)
        _ = page.save(on: req)
    }
 
    
}





