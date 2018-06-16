//
//  RecordController.swift
//  App
//
//  Created by Jinxiansen on 2018/6/5.
//

import Vapor
import Fluent
import Crypto
import Authentication
import FluentMySQL

class RecordController: RouteCollection {
    
    func boot(router: Router) throws {
        
        router.group("record") { (group) in
            // record/add
            group.post(RecordContainer.self, at: "add", use: postRecord)
            // record/getRecords
            group.get("getRecords", use: getRecords)
            // 32DG2342432813EF113.jpg/image 中间跟图片名
            group.get("image", use: getRecordImage)
            
        }
        
        //举报
        router.group("report") { (group) in
            group.post(ReportContainer.self, at: "add", use: reportUser)
        }
        
    }

}


extension RecordController {
    
    //TODO: 发个动态。
    func postRecord(_ req: Request,container: RecordContainer) throws -> Future<Response> {
        
        let token = BearerAuthorization(token: container.token)
        return AccessToken.authenticate(using: token, on: req)
            .flatMap({ (existToken)  in
            guard let existToken = existToken else {
                return try ResponseJSON<String>(state: .tokenInvalid).encode(for: req)
            }
            
            var imgName: String?
            if let image = container.image { //如果上传了图就判断、保存
                imgName = VaporUtils.imageName()
                let path = try VaporUtils.localRootDir(at: ImagePath.record,
                                                       req: req) + "/" + imgName!
                guard image.count < ImageMaxByteSize else {
                    return try ResponseJSON<String>(state: .error,message: "有点大，得压缩！").encode(for: req)
                }
                try Data(image).write(to: URL(fileURLWithPath: path))
            }
            
            let record = UserRecord(id: nil,
                                    userID: existToken.userID,
                                    content: container.content,
                                    key: container.key,
                                    time: TimeManager.shared.currentTime(),
                                    imgName: imgName)
            
            return record.save(on: req).flatMap({ (rc) in
                return try ResponseJSON<UserRecord>(state: .ok,
                                                    message: "发布成功").encode(for: req)
            })
        })
    }
    
    //TODO: 获取动态
    func getRecords(_ req: Request) throws -> Future<Response> {
        
        guard let page = req.query[Int.self, at: "page"],page >= 0 else {
            return try ResponseJSON<[UserRecord]>(state: .error,
                                                  message: "page 不能小于0").encode(for: req)
        }
        
        return try UserRecord.query(on: req)
            .range(VaporUtils.queryRange(page: page)).sort(\.time).all()
            .flatMap({ (cords) in
            guard cords.count > 0 else {
                return try ResponseJSON<[UserRecord]>(state: .ok,
                                                      message: "没有数据了",
                                                      data: []).encode(for: req)
            }
            return try ResponseJSON<[UserRecord]>.init(data: cords).encode(for: req)
        })
    }
    
    //TODO: 获取图片
    func getRecordImage(_ req: Request) throws -> Future<Response> {
        
        guard let name = req.query[String.self, at: "name"] else {
            let json = ResponseJSON<String>(state: .error, message: "缺少图片参数")
            return try json.encode(for: req)
        }
        
        let path = try VaporUtils.localRootDir(at: ImagePath.record, req: req) + "/" + name
        
        if !FileManager.default.fileExists(atPath: path) {
            let json = ResponseJSON<String>(state: .error, message: "图片不存在")
            return try json.encode(for: req)
        }
        
        return try req.streamFile(at: path)
    }
    
    //TODO: 举报
    func reportUser(_ req: Request,container: ReportContainer) throws -> Future<Response> {
        
        let token = BearerAuthorization.init(token: container.token)
        return AccessToken.authenticate(using: token, on: req)
            .flatMap({ (existToken) in
                guard let existToken = existToken else {
                    return try ResponseJSON<String>(state: .tokenInvalid).encode(for: req)
                }
                
                var imgName: String?
                var img2Name: String?
                if let image = container.image {
                    guard image.count < ImageMaxByteSize else {
                        return try ResponseJSON<String>(state: .error, message: "图片过大，得压缩！").encode(for: req)
                    }
                    imgName = VaporUtils.imageName()
                    let path = try VaporUtils.localRootDir(at: ImagePath.report, req: req) + "/" + imgName!
                    
                    try Data(image).write(to: URL(fileURLWithPath: path))
                }
                
                if let image2 = container.image2 {
                    guard image2.count < ImageMaxByteSize else {
                        return try ResponseJSON<String>(state: .error, message: "图片过大，得压缩！").encode(for: req)
                    }
                    img2Name = "2" + VaporUtils.imageName() //防止和上面的重复
                    let path = try VaporUtils.localRootDir(at: ImagePath.report, req: req) + "/" + img2Name!
                    
                    try Data(image2).write(to: URL(fileURLWithPath: path))
                }
                
                let report = Report(id: nil,
                                    userID: existToken.userID,
                                    receiveID: container.receiveID,
                                    content: container.content,
                                    imgName: imgName,
                                    imgName2: img2Name,
                                    contact: container.contact)
                
                return report.save(on: req).flatMap({ (rc) in
                    return try ResponseJSON<String>.init(state: .ok, message: "举报成功").encode(for: req)
                })
            })
        
    }
    
    
    
    
    
    
    
}


extension RecordController {
    
}


struct PageContainer: Content {
    var page: Int
}

struct RecordContainer: Content {
    
    var token: String
    var content: String
    var key: String?
    var image: Data?
}

struct ReportContainer: Content {
    var token: String
    var content: String
    var receiveID: String
    var image: Data?
    var image2: Data?
    var contact: String?
}

struct ImageContainer: Content {
    
    var imgName: String?
    var image: Data?
    
}





