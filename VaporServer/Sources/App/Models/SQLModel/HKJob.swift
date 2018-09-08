//
//  HKJob.swift
//  App
//
//  Created by 晋先森 on 2018/8/6.
//

import Foundation
import Vapor


struct HKJob: BaseSQLModel {
    
    var id: Int?
    static var entity: String { return self.name + "s" }
    
    let title: String
    let jobId: String
    let type: String?
    let location: String?
    let money: String?
    let content: String?
    let company: String?
    let lastUpdate: String?
    
    var detailInfo: String?
    var date: String?
    var industry: String?
    
}


