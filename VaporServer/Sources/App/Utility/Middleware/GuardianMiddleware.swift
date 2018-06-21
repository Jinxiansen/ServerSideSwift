//
//  GuardianMiddleware.swift
//  App
//
//  Created by Jinxiansen on 2018/6/11.
//

import Foundation
import Vapor

public typealias BodyClosure = ((_ req: Request) throws -> Future<Response>?)

//访问频率控制。
public struct GuardianMiddleware: Middleware {
    
    internal var cache: MemoryKeyedCache
    internal let limit: Int
    internal let refreshInterval: Double
    
    internal var bodyClosure: BodyClosure?
    
    public init(rate: Rate,closure: BodyClosure? = nil) {
        self.cache = MemoryKeyedCache()
        self.bodyClosure = closure
        self.limit = rate.limit
        self.refreshInterval = rate.refreshInterval
    }
    
    public init(rate: Rate,closure: BodyClosure? = nil, cache: MemoryKeyedCache) {
        self.cache = cache
        self.bodyClosure = closure
        self.limit = rate.limit
        self.refreshInterval = rate.refreshInterval
    }
    
    public func respond(to request: Request, chainingTo next: Responder) throws -> EventLoopFuture<Response> {
        
        let peer = (request.http.remotePeer.hostname ?? "") + request.http.urlString
        
        return cache.get(peer, as: [String:String].self).flatMap { (entry) in
            
            let creatString = entry?[Keys.createdAt] ?? ""
            var createdAt = Double(creatString) ?? Date().timeIntervalSince1970
            var requestsLeft = Int(entry?[Keys.requestsLeft] ?? "") ?? self.limit
            let now = Date().timeIntervalSince1970
            
            if now - createdAt >= self.refreshInterval {
                createdAt = now
                requestsLeft = self.limit
            }

            defer {
                let dict = [Keys.createdAt:"\(createdAt)",
                            Keys.requestsLeft:String(requestsLeft)]
                _ = self.cache.set(peer, to: dict)
            }
            
            requestsLeft -= 1
            guard requestsLeft >= 0 else {
                guard let closure = self.bodyClosure,let body = try closure(request) else {
                    let json = ["status":"429","message":"Visit too often, please try again later"]
                    return try json.encode(for: request)
                }
                return try body.encode(for: request)
            }
            
            return try next.respond(to: request)
        }
    }
}


fileprivate struct Keys {
    static let createdAt = "createdAt"
    static let requestsLeft = "requestsLeft"
}

public struct Rate {
    
    public enum Interval {
        case second
        case minute
        case hour
        case day
    }
    
    let limit: Int
    let interval: Interval
    
    public init(limit: Int,interval: Interval) {
        self.limit = limit
        self.interval = interval
    }
    
    internal var refreshInterval: Double {
        switch interval {
        case .second:
            return 1
        case .minute:
            return 60
        case .hour:
            return 3600
        case .day:
            return 86400
        }
    }
    
}











