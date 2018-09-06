//
//  NoteController.swift
//  App
//
//  Created by 晋先森 on 2018/9/6.
//

import Foundation
import Vapor
import Fluent

struct NoteController: RouteCollection {
    
    func boot(router: Router) throws {
        
        router.group("note") { (router) in
            router.get("live", use: getLiveDataHandler)
        }
    }
}


extension NoteController {
    
    func getLiveDataHandler(_ req: Request) throws -> Future<Response> {

        return NoteLive.query(on: req)
            .filter(\.uid == req.uid)
            .query(page: req.page)
            .all()
            .flatMap({
            return try ResponseJSON<[NoteLive]>(data: $0).encode(for: req)
        })
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
