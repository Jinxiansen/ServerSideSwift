//
//  ProcessController.swift
//  App
//
//  Created by 晋先森 on 2018/7/20.
//

import Foundation
import Vapor

class ProcessController: RouteCollection {
    
    func boot(router: Router) throws {
        
        router.group("process") { (group) in
            
            group.get("screenshot", use: uploadLeafHandler)
            group.post(ConvertImage.self, at: "convertImage", use: convertImagesUsePythonHandler)
            
            group.get("sum", use: sumTestHandler)
        }
    }
    
}


extension ProcessController {
    
    func sumTestHandler(_ req: Request) throws -> Future<String> {
        
        let promise = req.eventLoop.newPromise(String.self)
        
        let a = req.query[String.self,at: "a"] ?? "0"
        let b = req.query[String.self,at: "b"] ?? "0"
        
        let task = Process()
        task.launchPath = VaporUtils.python3Path()
        task.arguments = ["sum.py",a,b]
        
        let outPipe = Pipe()
        let errPipe = Pipe()
        task.standardOutput = outPipe
        task.standardError = errPipe
        
        let pyFileDir = DirectoryConfig.detect().workDir + "Public/py"
        task.currentDirectoryPath = pyFileDir + "/demo"
        task.terminationHandler = { proce in
            
            let data = outPipe.fileHandleForReading.readDataToEndOfFile()
            let result = String(data: data, encoding: .utf8) ?? ""
            promise.succeed(result: result)
        }
        
        task.launch()
        task.waitUntilExit()
        
        return promise.futureResult
        
    }
    
    func uploadLeafHandler(_ req: Request) throws -> Future<View> {
        return try req.view().render("process/screenshot")
    }
    
    func convertImagesUsePythonHandler(_ req: Request,container: ConvertImage) throws -> Future<Response> {
        
        let promise = req.eventLoop.newPromise(Response.self)
        
        let pyFileDir = DirectoryConfig.detect().workDir + "Public/py"
        
        let inputPath = pyFileDir + "/convert/input"
        let manager = FileManager.default
        if !manager.fileExists(atPath: inputPath) { //不存在则创建
            try manager.createDirectory(atPath: inputPath, withIntermediateDirectories: true, attributes: nil)
        }
        
        var imgPath: String?
        if let file = container.img {
            guard file.data.count < ImageMaxByteSize else {
                return try ResponseJSON<Empty>(status: .error,
                                               message: "图片过大，得压缩！").encode(for: req)
            }
            let imgName = try VaporUtils.randomString() + ".png"
            imgPath = inputPath + "/" + imgName
            
            try Data(file.data).write(to: URL(fileURLWithPath: imgPath!))
        }
        
        var bgPath: String?
        if let file = container.bg {
            guard file.data.count < ImageMaxByteSize else {
                return try ResponseJSON<Empty>(status: .error,
                                               message: "图片过大，得压缩！").encode(for: req)
            }
            let bgName = try VaporUtils.randomString() + ".png"
            bgPath = inputPath + "/" + bgName
            
            try Data(file.data).write(to: URL(fileURLWithPath: bgPath!))
        }
        
        let arcName = try VaporUtils.randomString()
        let task = Process()
        
        task.launchPath = VaporUtils.python3Path()
        
        task.arguments = ["toImage.py",arcName,container.d ?? "1",imgPath ?? "",bgPath ?? ""]
        
        //        let outPipe = Pipe()
        //        let errPipe = Pipe()
        //        task.standardOutput = outPipe
        //        task.standardError = errPipe
        
        task.currentDirectoryPath = pyFileDir + "/convert"
        
        task.terminationHandler = { proce in
            
            let filePath = pyFileDir + "/convert/out/\(arcName).jpg"
            if let data = manager.contents(atPath: filePath) {
                let res = req.makeResponse(data)
                promise.succeed(result: res)
            }else {
                promise.succeed(result: req.makeResponse("必须上传2张图片"))
            }
        }
        
        task.launch()
        task.waitUntilExit()
        
        //        let data = outPipe.fileHandleForReading.readDataToEndOfFile()
        //        print(String(data: data, encoding: .utf8) ?? "gg")
        
        return promise.futureResult
    }
    
}



struct ConvertImage: Content {
    var d: String?
    var img: File?
    var bg: File?
    
}






