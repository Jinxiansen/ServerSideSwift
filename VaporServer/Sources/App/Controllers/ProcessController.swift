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
            
            group.get("convertImage", use: convertImagesUsePythonHandler)
            
        }
    }
    
}


extension ProcessController {
    
    func convertImagesUsePythonHandler(_ req: Request) throws -> Future<Response> {
        
        let promise = req.eventLoop.newPromise(Response.self)
        
        let roomPath = "/Users/jinxiansen/Desktop/toImage"
        let task = Process()
        
        task.launchPath = "/usr/local/bin/python3"
        task.arguments = ["toImage.py"]
        task.currentDirectoryPath = roomPath
        task.terminationHandler = { proce in
            print("proce: \( proce)\n")
            let filePath = roomPath + "/out.png"
            
            if let data = FileManager.default.contents(atPath: filePath) {
                let res = req.makeResponse(data)
                promise.succeed(result: res)
            }else {
                promise.succeed(result: req.makeResponse())
            }
        }
        
        task.launch()
        task.waitUntilExit()
        
        //        let outPipe = Pipe()
        //        let errPipe = Pipe()
        //        task.standardOutput = outPipe
        //        task.standardError = errPipe
        //        let data = outPipe.fileHandleForReading.readDataToEndOfFile()
        //        print(String(data: data, encoding: .utf8) ?? "gg")
        
        return promise.futureResult
    }
    
}
