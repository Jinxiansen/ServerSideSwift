//
//  TestController.swift
//  App
//
//  Created by Jinxiansen on 2018/6/8.
//

import Foundation
import Vapor
import Fluent
import FluentMySQL
import Random

struct TestController: RouteCollection {
    
    func boot(router: Router) throws {
        
        router.group("test") { (group) in
            group.post("upload", use: uploadImage)
            
            group.get("getName", use: getNameHandler)
            
            group.get("getName2", String.parameter) { req -> [String:String] in
                let name = try req.parameters.next(String.self)
                return ["status":"0","message":"Hello,\(name) !"]
            }
            group.post("post1UserInfo", use: post1UserInfoHandler)
            group.post(UserContainer.self, at: "post2UserInfo", use: post2UserInfoHandler)
            
            group.get("doc", use: sendGetRequest)
            
            group.get("random", use: testRandom)
            
//            router.get("process") { (req: Request) -> Future<String> in
//                // asyncExecute returns a Future<Int32> where the value is the exit code of the process
//                Process.asyncExecute("/bin/bash", ["/Users/zsolt/test.sh"], on: req) { _ in }
//                .map { $0.description }
//            }
        }
        
    }
}



extension TestController {
    
    
    // post
    
    func readCityHandler(_ req: Request) throws -> Future<Response> {
        let name = try req.content.syncGet(String.self, at: "city")
        return try ResponseJSON<Empty>.init(status: .ok,message: name).encode(for: req)
    }
    
    func deleteRecord(_ req: Request) throws -> Future<Response> {
        
        return Record.find(3, on: req).flatMap { (record) in
            guard let record = record else {
                return try ResponseJSON<Empty>(status: .error, message: "not found").encode(for: req)
            }
            return record.delete(on: req).flatMap({ _ in
                return try ResponseJSON<Empty>(status: .ok, message: "delete success").encode(for: req)
            })
        }
    }
    
    func testRandom(_ req: Request) throws -> Future<Response> {
        let a: Int = Int(SimpleRandom.random(10...254))
        let b: Int = Int(SimpleRandom.random(10...254))
        let c: Int = Int(SimpleRandom.random(10...254))
        let d: Int = Int(SimpleRandom.random(10...254))
        
        let ip = "\(a).\(b).\(c).\(d)"
        return try ResponseJSON<String>(status: .ok, message: "success", data: ip).encode(for: req)
    }

    func sendGetRequest(req: Request) throws -> Future<String> {
        
        let client = try req.client()
        return client.get("http://api.jinxiansen.com")
            .map(to: String.self, { clientResponse in
                return clientResponse.http.body.utf8String
            })
    }
 
    
    func getNameHandler(_ req: Request) throws -> [String:String] {
        guard let name = req.query[String.self, at: "name"] else {
            return ["status":"-1","message": "缺少 name 参数"]
        }
        
        return ["status":"0","message":"Hello,\(name) !"]
    }
    
    func post1UserInfoHandler(_ req: Request) throws -> Future<[String:String]> {
        
        return try req.content.decode(UserContainer.self).map({ container in
            let age = container.age ?? 0
            let result = ["status":"0","message":"Hello,\(container.name) !","age": age.description]
            return result
        })
    }
    
    func post2UserInfoHandler(_ req: Request,container: UserContainer) throws -> Future<[String:String]> {
        
        let age = container.age ?? 0
        let result = ["status":"0","message":"Hello,\(container.name) !","age": age.description]
        return req.eventLoop.newSucceededFuture(result: result)
    }
    
    func uploadImage(_ req: Request) throws -> Future<Response> {
        
        return try req.content.decode(ImageContainer.self).flatMap({ (receive) in
            
            print(receive.imgName ?? "")

            let path = try VaporUtils.localRootDir(at: ImagePath.record, req: req) + "/" + VaporUtils.imageName()
            
            if let image = receive.image {
                
                guard image.count < ImageMaxByteSize else {
                    return try ResponseJSON<Empty>(status: .error, message: "有点大，得压缩！").encode(for: req)
                }
                
                try Data(image).write(to: URL(fileURLWithPath: path))
            }
 
            return try ResponseJSON<ImageContainer>(data: receive).encode(for: req)
        })
        
    }
    
}



struct ImageContainer: Content {
    
    var imgName: String?
    var image: Data?
    
}

struct UserContainer: Content {
    
    var name: String
    var age: Int?
}



