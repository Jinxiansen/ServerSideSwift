//
//  TimeManager.swift
//  App
//
//  Created by Jinxiansen on 2018/5/29.
//

import Vapor

struct TimeManager {
    
    static let shared = TimeManager()
    
    fileprivate let matter = DateFormatter()
    
    init() {
        matter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        matter.timeZone = TimeZone(identifier: "Asia/Shanghai")
    }
    
    func currentTime() -> String {
        return matter.string(from: Date())
    }
    
    static func currentTime() -> String {
        return self.shared.matter.string(from: Date())
    }
}



