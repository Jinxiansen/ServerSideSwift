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
        let pred = NSPredicate(format: "SELF MATCHES %@", pattern)
        let isMatch:Bool = pred.evaluate(with: self)
        
        return isMatch
    }
    
    func hashString(_ req: Request) throws -> String {
       return try req.make(BCryptDigest.self).hash(self)
    }
 
    
}


