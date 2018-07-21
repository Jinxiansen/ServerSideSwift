//
//  Util.swift
//  App
//
//  Created by 晋先森 on 2018/6/9.
//

import Foundation
import Vapor
import Crypto
import Random

class VaporUtils {
    
    class func localRootDir(at path: String, req: Request) throws -> String {
        
        let workDir = DirectoryConfig.detect().workDir
        
        let envPath = req.environment.isRelease ? "":"debug"
        let addPath = "vapor_\(envPath)/\(path)"
        
        var localPath = ""
        if (workDir.contains("jinxiansen")) {
            localPath = "/Users/jinxiansen/Documents/\(addPath)"
        }else if (workDir.contains("laoyuegou")) {
            localPath = "/Users/laoyuegou/Documents/\(addPath)"
        }else if (workDir.contains("ubuntu")) {
            localPath = "/home/ubuntu/image/\(addPath)"
        }else {
            localPath = "\(workDir)\(addPath)"
        }
        
        let manager = FileManager.default
        if !manager.fileExists(atPath: localPath) { //不存在则创建
            try manager.createDirectory(atPath: localPath, withIntermediateDirectories: true, attributes: nil)
        }
         
        return localPath
    }
    
    
    class func imageName() throws -> String {
        return try randomString() + ".jpg"
    }
    
    class func randomString() throws -> String {
        let r = try CryptoRandom().generate(Int.self)
        let d = Date().timeIntervalSince1970.description
        let fileName = (r.description + d).md5
        return fileName
    }
    
    class func queryRange(page: Int) -> Range<Int> {
        let start = page * pageCount
        let end = start + pageCount
        let queryRange: Range = start..<end
        return queryRange
    }
    
}



