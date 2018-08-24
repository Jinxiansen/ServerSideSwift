//
//  TestController.swift
//  App
//
//  Created by Jinxiansen on 2018/6/8.
//

import Foundation
import Vapor
import Fluent
import Random

// 这里是测试 controller 
struct TestController: RouteCollection {
    
    func boot(router: Router) throws {
        
        router.group("test") { (group) in
            
            //localhost:8080/test/upload
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
            
            group.post("postCity", use: postCityHandler)
            
            group.post("send") { req -> Future<Response> in
                let city: String = try req.content.syncGet(at: "city")
                return try ["hello":city].encode(for: req)
            }
            
            group.get("tofu", use: testTofuHandler)
            
            group.get("myModel", use: saveMyModelHandler)
            
        }
        
    }
}

extension TestController {
    
    
    func testTofuHandler(_ req: Request) throws -> Future<Response> {
        
        struct HistoryModel: Content {
            
            var id: Int
            var img: String?
            var title: String?
            var content: String?
            var year: Int
            var month: Int
            var day: Int
        }
        
        struct MyData: Content {
            var affairArray: [HistoryModel]
            var more: Int
        }

        
        let h1 = HistoryModel(id: 2, img: "img1", title: "\(Int(SimpleRandom.random(10...254)))", content: "\(Int(SimpleRandom.random(10...254)))", year: 2018, month: 08, day: 10)
        
        let h2 = HistoryModel(id: 3, img: "img2", title: "\(Int(SimpleRandom.random(10...254)))", content: "\(Int(SimpleRandom.random(10...254)))", year: 2018, month: 5, day: 13)
        
        let data = MyData(affairArray: [h1,h2],more: 1)
        
        return try ResponseJSON<MyData>(data: data).encode(for: req)
    }
    
    
    func compactMap(_ req: Request) throws -> Future<Int> {
        
        let firstFuture = MyModel.query(on: req).first()
        let allFuture = MyModel.query(on: req).all()
        
        return map(to: Int.self, firstFuture, allFuture) { (first, all) in
            let f = first?.count ?? 0
            let a = all.count
            return f + a
        }
    }
    
    func saveMyModelHandler(_ req: Request) throws -> Future<MyModel> {
        let a: Int = Int(SimpleRandom.random(1...2540))
        return MyModel(name: "4ks", count: a).save(on: req).flatMap({ (model) in
            return req.eventLoop.newSucceededFuture(result: model)
        })
    }
    
    // post
    func postCityHandler(_ req: Request) throws -> Future<Response> {
        
        let name: String = try req.content.syncGet(at: "city")
        return try ResponseJSON<Empty>(status: .ok,message: name).encode(for: req)
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
        return client.get("http://api.jinxiansen.com").map(to: String.self, { clientResponse in
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
    
    private func post2UserInfoHandler(_ req: Request,container: UserContainer) throws -> Future<[String:String]> {
        
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



private struct ImageContainer: Content {
    
    var imgName: String?
    var image: Data?
    
}

private struct UserContainer: Content {
    
    var name: String
    var age: Int?
}



