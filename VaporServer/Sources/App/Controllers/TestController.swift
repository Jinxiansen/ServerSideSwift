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
        
        struct Bill: Content {
            
            var id: String
            var category: Int
            var tags: String
            var place: String
            var introduce: String
            var describe: String
            var amount: Double
            var status: Int
            var remark: String
            var creatTime: String
            var memberId: String
            var tradeType: Int
        }
        
        struct MyData: Content {
            var bills: [Bill]
        }
        
        // 这是一段测试数据
        let b1 = Bill(id: "se331", category: 1, tags: "午饭", place: "老鸿兴", introduce: "同事聚餐", describe: "总共8人小聚", amount: 1335, status: 0, remark: "聚餐支出", creatTime: TimeManager.currentTime(), memberId: "3339", tradeType: 1)
        
        let b2 = Bill(id: "se436", category: 1, tags: "晚餐", place: "殇雪", introduce: "怡情", describe: "2人", amount: 530, status: 0, remark: "聚餐支出", creatTime: TimeManager.currentTime(), memberId: "3339", tradeType: 1)
        
        let b3 = Bill(id: "se398", category: 1, tags: "冰箱", place: "新街口", introduce: "买冰箱", describe: "带老婆买了个大冰箱", amount: 8999, status: 0, remark: "家具支出", creatTime: TimeManager.currentTime(), memberId: "3339", tradeType: 1)
        
        let b4 = Bill(id: "se335", category: 1, tags: "外快", place: "家里", introduce: "小项目", describe: "大概为期7天写的基于 Swift 服务端的跑步项目", amount: 5000, status: 0, remark: "外快收入", creatTime: TimeManager.currentTime(), memberId: "3339", tradeType: 2)
        
        return try ResponseJSON<[Bill]>(data: [b1,b2,b3,b4]).encode(for: req)
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
                return try ResponseJSON<Empty>(status: .error,
                                               message: "not found").encode(for: req)
            }
            return record.delete(on: req).flatMap({ _ in
                return try ResponseJSON<Empty>(status: .ok,
                                               message: "delete success").encode(for: req)
            })
        }
    }
    
    func testRandom(_ req: Request) throws -> Future<Response> {
        let a: Int = Int(SimpleRandom.random(10...254))
        let b: Int = Int(SimpleRandom.random(10...254))
        let c: Int = Int(SimpleRandom.random(10...254))
        let d: Int = Int(SimpleRandom.random(10...254))
        
        let ip = "\(a).\(b).\(c).\(d)"
        return try ResponseJSON<String>(status: .ok,
                                        message: "success", data: ip).encode(for: req)
    }
    
    func sendGetRequest(req: Request) throws -> Future<String> {
        
        let client = try req.client()
        return client
            .get("http://api.jinxiansen.com")
            .map(to: String.self, { clientResponse in
            return clientResponse.utf8String
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
                    return try ResponseJSON<Empty>(status: .error,
                                                   message: "有点大，得压缩！").encode(for: req)
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



