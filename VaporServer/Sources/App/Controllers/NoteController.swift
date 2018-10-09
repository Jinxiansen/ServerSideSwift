//
//  NoteController.swift
//  App
//
//  Created by 晋先森 on 2018/9/6.
//

import Foundation
import Vapor
import Fluent
import FluentPostgreSQL
import Authentication

struct NoteController: RouteCollection {
    
    func boot(router: Router) throws {
        
        router.group("note") { (router) in
            
            // 提交 Live
            router.post(LiveContainer.self, at: "live", use: postLiveDataHandler)
            // 获取所有 Lives ,可选参数 page
            router.get("lives", use: getLivesDataHandler)
            router.get("image",String.parameter, use: getLiveImageHandler)
            
            router.post(LiveContainer.self, at: "updateLive", use: updateLiveContentHandler)
            
            router.post(BillContainer.self, at: "bill", use: postBillDataHandler)
            router.get("bills", use: getBillsDataHandler)
            
            
        }
    }
}


extension NoteController {
    
    //MARK: Bill
    func getBillsDataHandler(_ req: Request) throws -> Future<Response> {
        
        let token = BearerAuthorization(token: req.token)
        
        return AccessToken.authenticate(using: token, on: req).flatMap({
            guard let user = $0 else {
                return try ResponseJSON<Empty>(status: .token).encode(for: req)
            }
            
            //分页、排序(time)。
            let futureAll = NoteBill.query(on: req).filter(\.userID == user.userID).query(page: req.page).sort(\.time,.descending).all()
            
            return futureAll.flatMap({
                return try ResponseJSON<[NoteBill]>(data: $0).encode(for: req)
            })
        })
    }
    
    
    private func postBillDataHandler(_ req: Request, container: BillContainer) throws -> Future<Response> {
        
        let token = BearerAuthorization(token: container.token)
        return AccessToken.authenticate(using: token, on: req).flatMap({
            
            guard let user = $0 else {
                return try ResponseJSON<Empty>(status: .token).encode(for: req)
            }
            
            let bill = NoteBill(id: nil, userID: user.userID, time: TimeManager.currentDate(), total: container.total, number: container.number ?? 1, type: container.type ?? 1 , desc: container.desc)
            
            return bill.save(on: req).flatMap({ _ in
                return try ResponseJSON<Empty>(status: .ok, message: "保存成功").encode(for: req)
            })
        })
        
    }
    
}


extension NoteController {
    
    
    //MARK: Live
    func getLivesDataHandler(_ req: Request) throws -> Future<Response> {
        
        let token = BearerAuthorization(token: req.token)
        return AccessToken.authenticate(using: token, on: req).flatMap({ _ in
            
            let futureAllLives = NoteLive.query(on: req).query(page: req.page).all()
            
            return futureAllLives.flatMap({
                
                // 取出查询到的动态数组中的所有 userID
                let allIDs = $0.compactMap({ return $0.userID })
                
                // 取出此用户数组中的 用户信息，可能会出现 5条动态，只有3条用户信息，因为5条信息总共是3个人发的
                let futureAllInfos = UserInfo.query(on: req).filter(\.userID ~~ allIDs).all()
                
                struct ResultLive: Content {
                    
                    var userInfo: UserInfo?
                    
                    var title: String
                    var time: TimeInterval?
                    var content: String?
                    var imgName: String?
                    var desc: String?
                }
                
                return flatMap(to: Response.self, futureAllLives, futureAllInfos, { (lives, infos) in
                    
                    var results = [ResultLive]()
                    
                    //拼接返回数据，双层 forEach 效率怕是有影响，期待有更好的方法。🙄
                    lives.forEach({ (live) in
                        
                        var result = ResultLive(userInfo: nil,
                                                title: live.title,
                                                time: live.time,
                                                content: live.content,
                                                imgName: live.imgName,
                                                desc: live.desc)
                        
                        infos.forEach({
                            if $0.userID == live.userID {
                                result.userInfo = $0
                            }
                        })
                        
                        results.append(result)
                    })
                    return try ResponseJSON<[ResultLive]>(data: results).encode(for: req)
                })
            })
        })
    }
    
    
    
    //MARK: Update Live Content
    private func updateLiveContentHandler(_ req: Request, container: LiveContainer) throws -> Future<Response> {
        
        let token = BearerAuthorization(token: container.token)
        return AccessToken.authenticate(using: token, on: req).flatMap({
            guard let _ = $0 else {
                return try ResponseJSON<Empty>(status: .token).encode(for: req)
            }
            
            let futureFirst = NoteLive.query(on: req).filter(\.id == container.liveId).first()
            return futureFirst.flatMap({
                guard var live = $0 else {
                    return try ResponseJSON<Empty>(status: .error,
                                                   message: " 此 id 不存在 ").encode(for: req)
                }
                
                live.title = container.title
                if let content = container.content {
                    live.content = content
                }
                if let desc = container.desc {
                    live.desc = desc
                }
                
                return live.update(on: req).flatMap({ _ in
                    return try ResponseJSON<Empty>(status: .ok,
                                                   message: "更新成功").encode(for: req)
                })
            })
        })
        
        
    }
    
    
    func getLiveImageHandler(_ req: Request) throws -> Future<Response> {
        
        let name = try req.parameters.next(String.self)
        let path = try VaporUtils.localRootDir(at: ImagePath.note, req: req) + "/" + name
        if !FileManager.default.fileExists(atPath: path) {
            let json = ResponseJSON<Empty>(status: .error,
                                           message: "图片不存在")
            return try json.encode(for: req)
        }
        return try req.streamFile(at: path)
    }
    
    private func postLiveDataHandler(_ req: Request, container: LiveContainer) throws -> Future<Response> {
        
        let token = BearerAuthorization(token: container.token)
        return AccessToken.authenticate(using: token, on: req).flatMap({
            guard let aToken = $0 else {
                return try ResponseJSON<Empty>(status: .token).encode(for: req)
            }
            
            var imgName: String?
            if let data = container.img?.data { //如果上传了图就判断、保存
                imgName = try VaporUtils.imageName()
                let path = try VaporUtils.localRootDir(at: ImagePath.note,
                                                       req: req) + "/" + imgName!
                guard data.count < ImageMaxByteSize else {
                    return try ResponseJSON<Empty>(status: .error,
                                                   message: "有点大，得压缩！").encode(for: req)
                }
                try Data(data).write(to: URL(fileURLWithPath: path))
            }
            
            let live = NoteLive(id: nil,
                                userID: aToken.userID,
                                title: container.title,
                                time: Date().timeIntervalSince1970,
                                content: container.content,
                                imgName: imgName,
                                desc: container.desc)
            
            return live.save(on: req).flatMap({ _ in
                return try ResponseJSON<Empty>.init(status: .ok,
                                                    message: "发布成功").encode(for: req)
            })
        })
    }
    
    
}

fileprivate struct LiveContainer: Content {
    
    var token: String
    var title: String
    var content: String?
    var img: File?
    var desc: String?
    
    var liveId: Int?
}


fileprivate struct BillContainer: Content {
    
    var token: String
    var type: Int?
    var total: Float
    var number: Int?
    var desc: String?
    
}






