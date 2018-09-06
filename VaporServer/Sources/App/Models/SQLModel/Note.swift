//
//  Note.swift
//  App
//
//  Created by 晋先森 on 2018/9/6.
//

import Foundation

// 生活动态、心情
struct NoteLive: BaseSQLModel {
    
    var id: Int?
    static var entity: String { return self.name + "s" }

    var uid: String
    var time: TimeInterval?
    var title: String?
    var content: String?
    var imgName: String?
    
    var desc: String?
    
}

// 账单
struct NoteBill: BaseSQLModel {
    
    var id: Int?
    
    var uid: String
    var time: TimeInterval?
    var number: Float
    var desc: String? //
    
    
    
}













