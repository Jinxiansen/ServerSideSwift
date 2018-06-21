//
//  RecordController.swift
//  App
//
//  Created by Jinxiansen on 2018/6/5.
//

import Vapor
import Crypto
import Authentication
import FluentMySQL

class RecordController: RouteCollection {
    
    func boot(router: Router) throws {
        
        router.group("record") { (group) in
            // record/add
            group.post(RecordContainer.self, at: "add", use: postRecord)
            
            // record/getRecords 获取全部动态
            group.get("getRecords", use: getAllRecords)
            
            group.get("image", use: getRecordImage)
            
            //获取我发布的动态。
            group.get("getMyRecords", use: getMyRecords)
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
                return try ResponseJSON<Void>(status: .token).encode(for: req)
            }
            
            var imgName: String?
            if let image = container.image { //如果上传了图就判断、保存
                imgName = try VaporUtils.imageName()
                let path = try VaporUtils.localRootDir(at: ImagePath.record,
                                                       req: req) + "/" + imgName!
                guard image.data.count < ImageMaxByteSize else {
                    return try ResponseJSON<Void>(status: .error,message: "有点大，得压缩！").encode(for: req)
                }
                try Data(image.data).write(to: URL(fileURLWithPath: path))
            }
            
            let record = Record(id: nil,
                                    userID: existToken.userID,
                                    content: container.content,
                                    title: container.title,
                                    county: container.county,
                                    time: TimeManager.shared.currentTime(),
                                    imgName: imgName)
            
            return record.save(on: req).flatMap({ (rc) in
                return try ResponseJSON<Record>(status: .ok,
                                                    message: "发布成功").encode(for: req)
            })
        })
    }
    
    //TODO: 获取动态
    func getAllRecords(_ req: Request) throws -> Future<Response> {
        
        guard let county = req.query[String.self, at: "county"],county.count > 0 else {
            return try ResponseJSON<Void>(status: .error,
                                              message: "缺少 county 参数").encode(for: req)
        }
        
        guard let page = req.query[Int.self, at: "page"],page >= 0 else {
            return try ResponseJSON<Void>(status: .error,
                                              message: "page 不能小于0").encode(for: req)
        }
        
//        let sql = "SELECT * FROM \(TableKey.content) WHERE county = \(county) LIMIT \(start),\(pageCount)"
        return Record.query(on: req).filter(\.county == county).range(VaporUtils.queryRange(page: page)).all()
            .flatMap({ (cords) in
                guard cords.count > 0 else {
                    return try ResponseJSON<[Record]>(status: .ok,
                                                      message: "没有数据了",
                                                      data: []).encode(for: req)
                }
                return try ResponseJSON<[Record]>(data: cords).encode(for: req)
            })
    }
    
    //TODO: 获取图片
    func getRecordImage(_ req: Request) throws -> Future<Response> {
        
        guard let name = req.query[String.self, at: "name"] else {
            let json = ResponseJSON<Void>(status: .error, message: "缺少图片参数")
            return try json.encode(for: req)
        }
        
        let path = try VaporUtils.localRootDir(at: ImagePath.record, req: req) + "/" + name
        
        if !FileManager.default.fileExists(atPath: path) {
            let json = ResponseJSON<Void>(status: .error, message: "图片不存在")
            return try json.encode(for: req)
        }
        
        return try req.streamFile(at: path)
    }
    
    //TODO: 举报
    func reportUser(_ req: Request,container: ReportContainer) throws -> Future<Response> {
        
        let token = BearerAuthorization(token: container.token)
        return AccessToken.authenticate(using: token, on: req)
            .flatMap({ (existToken) in
                guard let existToken = existToken else {
                    return try ResponseJSON<Void>(status: .token).encode(for: req)
                }
                
                var imgName: String?
                if let file = container.image {
                    
                    guard file.data.count < ImageMaxByteSize else {
                        return try ResponseJSON<Void>(status: .error, message: "图片过大，得压缩！").encode(for: req)
                    }
                    imgName = try VaporUtils.imageName()
                    let path = try VaporUtils.localRootDir(at: ImagePath.report, req: req) + "/" + imgName!
                    
                    try Data(file.data).write(to: URL(fileURLWithPath: path))
                }
                
                let report = Report(id: nil,
                                    userID: existToken.userID,
                                    content: container.content,
                                    county: container.county,
                                    imgName: imgName,
                                    contact: container.contact)
                
                return report.save(on: req).flatMap({ (rc) in
                    return try ResponseJSON<Void>(status: .ok, message: "举报成功").encode(for: req)
                })
            })
    }
    
    //TODO: 获取我发布的动态
    func getMyRecords(_ req: Request) throws -> Future<Response> {
        
        guard let token = req.query[String.self, at: "token"] else {
            return try ResponseJSON<Void>(status: .error, message: "缺少 token 参数").encode(for: req)
        }
        guard let county = req.query[String.self, at: "county"] else {
            return try ResponseJSON<Void>(status: .error, message: "缺少 county 参数").encode(for: req)
        }
        guard let page = req.query[Int.self, at: "page"] else {
            return try ResponseJSON<Void>(status: .error, message: "缺少 page 参数").encode(for: req)
        }
        
        let bear = BearerAuthorization(token: token)
        return AccessToken.authenticate(using: bear, on: req).flatMap({ (existToken) in
            
            guard let existToken = existToken else {
                return try ResponseJSON<Void>(status: .token).encode(for: req)
            }
            
            return Record.query(on: req)
                .filter(\Record.county == county)
                .filter(\Record.userID == existToken.userID)
                .range(VaporUtils.queryRange(page: page))
                .all()
                .flatMap({ (records) in
                let results = records.compactMap({ (record) -> Record in
                    var rec = record; rec.id = nil; return rec
                })
                return try ResponseJSON(data: results).encode(for: req)
            })
        })
    }
    
    
    
    
}

struct PageContainer: Content {
    var page: Int
}

struct CountyContainer: Content {
    var county: String
}

struct RecordContainer: Content {
    
    var token: String
    var content: String
    var title: String
    var image: File?
    var county: String
}

struct ReportContainer: Content {
    var token: String
    var content: String
    var county: String
    
    var image: File?
    var contact: String?
}





