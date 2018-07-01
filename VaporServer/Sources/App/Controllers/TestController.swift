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
        }
        
    }
}



extension TestController {

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
                    return try ResponseJSON<Void>(status: .error, message: "有点大，得压缩！").encode(for: req)
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



