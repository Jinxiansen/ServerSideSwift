//
//  String+Extension.swift
//  App
//
//  Created by Jinxiansen on 2018/6/7.
//

import Foundation
import Vapor
import Crypto

extension String {
    
    var isEmail : Bool {
        let pattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let str = "SELF MATCHES \(pattern)"
        let pred = NSPredicate(format: str)
        let isMatch:Bool = pred.evaluate(with: self)
        return isMatch
    }
    
    func hashString(_ req: Request) throws -> String {
       return try req.make(BCryptDigest.self).hash(self)
    }
 
    
}

extension String {
    
    var outPutUnit: String {
        #if os(Linux)
        let s = "%s" // Linux上使用 %@ 输出编译不过，得用 %s 输出C字符串。
        #else
        let s = "%@"
        #endif
        return s
    }
    
}




