//
//  NoteController.swift
//  App
//
//  Created by 晋先森 on 2018/9/6.
//

import Foundation
import Vapor
import Fluent
import Authentication

struct NoteController: RouteCollection {
    
    func boot(router: Router) throws {
        
        router.group("note") { (router) in
            
            // 提交 Live
            router.post(LiveContainer.self, at: "live", use: postLiveDataHandler)
            
            // 获取所有 Lives ,可选参数 page, token；如果传了 token 则为获取我的 Lives
            router.get("live", use: getLiveDataHandler)
        }
    }
}


extension NoteController {
    
    func getLiveDataHandler(_ req: Request) throws -> Future<Response> {
        
        let token = BearerAuthorization(token: req.token)
        return AccessToken.authenticate(using: token, on: req).flatMap({
            return NoteLive.query(on: req)
                .filter(\.userID == $0?.userID ?? "")
                .query(page: req.page)
                .all()
                .flatMap({
                    return try ResponseJSON<[NoteLive]>(data: $0).encode(for: req)
                })
        })
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
    
}







