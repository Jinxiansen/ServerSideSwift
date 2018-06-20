//
//  Util.swift
//  App
//
//  Created by 晋先森 on 2018/6/9.
//

import Foundation
import Vapor
import Crypto

class VaporUtils {
    
    class func localRootDir(at path: String, req: Request) throws -> String {
        
        let workDir = DirectoryConfig.detect().workDir
        
        let envPath = req.environment.isRelease ? "":"debug_"
        
        var localPath = ""
        if (workDir.contains("jinxiansen")) {
            localPath = "/Users/jinxiansen/Documents/\(envPath)\(path)"
        }else if (workDir.contains("laoyuegou")) {
            localPath = "/Users/laoyuegou/Documents/\(envPath)\(path)"
        }else if (workDir.contains("ubuntu")) {
            localPath = "/home/ubuntu/image/\(envPath)\(path)"
        }else {
            localPath = "\(workDir)\(envPath)\(path)"
        }
        
        let manager = FileManager.default
        if !manager.fileExists(atPath: localPath) { //不存在则创建
            try manager.createDirectory(atPath: localPath, withIntermediateDirectories: true, attributes: nil)
        }
         
        return localPath
    }
    
    class func imageName() -> String {
        let fileName = Date().description.md5 + ".jpg"
        return fileName
    }
    
    
    class func queryRange(page: Int) -> Range<Int> {
        let start = page * pageCount
        let end = start + pageCount
        let queryRange: Range = start..<end
        return queryRange
    }
    
}



