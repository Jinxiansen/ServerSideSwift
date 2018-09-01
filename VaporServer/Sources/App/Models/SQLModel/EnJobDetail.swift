//
//  EnJobDetail.swift
//  App
//
//  Created by Jinxiansen on 2018/9/1.
//

import Foundation
import FluentPostgreSQL

struct EnJobDetail: BaseSQLModel {
    
    var id: Int?
    static var entity: String { return self.name + "s" }

    var jobId: String
    var title: String?
    var exp: String?
    var company: String?
    var loc: String?
    var more: String?
    var publisher: String?
    
    var views: String?
    var applys: String?
    
    var salary: String?
    var content: String?
    
    var desc: String?
    var keys: String?
    var desiredCandidateProfile: String?
    var companyProfile: String?
    var webSite: String?
    var telPhone: String?
    
    init(jobId: String) {
        self.jobId = jobId
    }
}

