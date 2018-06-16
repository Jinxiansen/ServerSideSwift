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
        matter.locale = Locale.current
    }
    
    func currentTime() -> String {
        return matter.string(from: Date())
    }
}
