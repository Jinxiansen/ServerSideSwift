
//
//  PageViewMeddleware.swift
//  App
//
//  Created by Jinxiansen on 2018/5/30.
//

import Vapor

public final class PageViewMeddleware : Middleware {
    
    public func respond(to request: Request, chainingTo next: Responder) throws -> EventLoopFuture<Response> {
        
        return try savePageView(request).flatMap({ pg in
            return try next.respond(to: request)
        })
    
    }
    
    func savePageView(_ req: Request) throws -> Future<PageView> {
        
        let method = req.http.method
        let path = req.http.url.absoluteString
        let reqString = "\(method) \(path) \(TimeManager.current()) \n"
        print(reqString)
        
        var body = ""
        var desc = ""
        if let subType = req.http.contentType?.subType, subType != "form-data" {
            desc = req.http.description
            body = req.http.body.description
        }
        
        let page = PageView(desc: desc,
                            ip: req.http.remotePeer.description,
                            body: body,
                            url: req.http.urlString)
        return page.save(on: req)
    }
    
    
}





