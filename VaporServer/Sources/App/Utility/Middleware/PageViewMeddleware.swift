
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
        
//        request.http.headers.replaceOrAdd(name: .contentType, value: "text/plain; charset=utf-8")
        
        
    
        return try next.respond(to: request)
    }
    
    func printLog(_ request: Request) throws {
        
        let logger = try request.make(Logger.self)
        let method = request.http.method
        let path = request.http.url.path
        let remoteAddress = request.http.channel?.remoteAddress?.description ?? ""
        let reqString = "[\(method)]@\(path) -> Remote:\(remoteAddress))\n"
        logger.info(reqString)
        
    }
    
    func savePageView(_ req: Request) throws -> Future<PageView> {

        let http = req.http
        let page = PageView.init(desc: req.description,
                                 ip: http.remotePeer.hostname,
                                 body: http.body.description,
                                 url: http.urlString
//                                 version: req.http.version.description
        )

       return page.save(on: req)
    }
    
    
}





