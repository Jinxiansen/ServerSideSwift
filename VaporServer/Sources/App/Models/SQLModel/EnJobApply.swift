//
//  EnJobApply.swift
//  App
//
//  Created by 晋先森 on 2018/9/2.
//

import Foundation
import Vapor

struct EnJobApply: BaseSQLModel {
    
    var id: Int?
    
    var jobId: String
    var userID: String
    var email: String?
    var name: String?
    var phone: String?
    var desc: String?
    var time: TimeInterval
    
}
