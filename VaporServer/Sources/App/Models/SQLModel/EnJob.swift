//
//  EnJob.swift
//  App
//
//  Created by Jinxiansen on 2018/9/1.
//

import Foundation
import FluentPostgreSQL


struct EnJob: BaseSQLModel {
    
    var id: Int?
    static var entity: String { return self.name + "s" }

    var title: String?
    var jobId: String
    var exp: String?
    var company: String?
    var loc: String?
    var more: String?
    var salary: String?
    var publisher: String?
    
}
