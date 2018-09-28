//
//  HTMLController.swift
//  APIErrorMiddleware
//
//  Created by Jinxiansen on 2018/6/1.
//

import Vapor


class HTMLController: RouteCollection {
    
    func boot(router: Router) throws {
        
        router.get("/", use: api)
      
        router.group("h5") { (group) in
            
            group.get("login", use: login)
            group.get("welcome", use: api)
            group.get("hello", use: hello)
            
            group.get("u", use: dogView)
            group.get("loader", use: loader)
            group.get("reboot", use: reboot)
            group.get("keyboard", use: keyboard)
            group.get("color", use: color)
            group.get("line", use: line)
            
        }
        
    }
    

}

extension HTMLController {

    
    func api(_ req: Request) throws -> Future<View> {
        
        return try req.view().render("leaf/web")
    }
    
    //MARK: H
    func login(_ req: Request) throws -> Future<View> {
        return try req.view().render("leaf/login")
    }
    
    func hello(_  req: Request) throws -> Future<View> {
        
        struct Person: Content {
            var name: String?
            var age: Int?
        }
        let per = Person(name: "jack", age: 18)
        return try req.view().render("leaf/hello",per)
    }
    
    func dogView(_ req: Request) throws -> Future<View> {
        return try req.view().render("leaf/dog")
    }
    
    func line(_ req: Request) throws -> Future<View> {
        return try req.view().render("leaf/line")
    }
    
    func reboot(_ req: Request) throws -> Future<View> {
        return try req.view().render("leaf/reboot")
    }
    
    func loader(_ req: Request) throws -> Future<View> {
        return try req.view().render("leaf/loader")
    }
    
    func keyboard(_ req: Request) throws -> Future<View> {
        return try req.view().render("leaf/keyboard")
    }
    
    func color(_ req: Request) throws -> Future<View> {
        return try req.view().render("leaf/color")
    }

    
}












