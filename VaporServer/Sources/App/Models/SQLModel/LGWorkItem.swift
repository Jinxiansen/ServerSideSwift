//
//  WorkItem.swift
//  App
//
//  Created by 晋先森 on 2018/6/30.
//

import Foundation
import Vapor
import FluentMySQL

struct LGWorkItem: BaseSQLModel {
    
    var id: Int?
    static var entity: String { return self.name + "s" }
    
    var adWord: Int?
    var appShow: Int?
    var approve: Int?
    var city: String?
    var companyFullName: String?
    var companyId: Int?
    var companyLogo: String?
    var companyShortName: String?
    var companySize: String?
    var createTime: String?
    var deliver: Int?
    var district: String?
    var education: String?
    
    var financeStage: String?
    var firstType: String?
    var formatCreateTime: String?
    var imState: String?
    var industryField: String?

    var isSchoolJob: Int?
    var jobNature: String?
    var lastLogin: Int?
    var latitude: String?
    var linestaion: String?
    var longitude: String?
    var pcShow: Int?
    var positionAdvantage: String?
    var positionId: Int
    var positionName: String?
    var publisherId: Int?
    var resumeProcessDay: Int?
    var resumeProcessRate: Int?
    var salary: String?
    var score: Int?
    var secondType: String?
    var stationname: String?
    var subwayline: String?
    var workYear: String?
    
    // 构造的详情数据
    var tag: String?
    var jobDesc: String?
    var address: String?
    
    
    //以下注释数据是因为在 拉勾返回数据中要么一直是 null ，要么一会儿 null 一会儿 字符串数组，解析会崩。
    //目前 Vapor 的 MySQL 内部不支持 Codable 的这种解析，我已经提了1个 issue ，
    //详情见： https://github.com/vapor/mysql/issues/195
    
//    var positionLables: String? //职位标签
//    var hiTags: String? //福利待遇
//    var businessZones: String?
//    var explain: String?
//    var gradeDescription: String?
//
//    var companyLabelList: String?
//    var industryLables: String? // 行业标签
//    var plus: String? // 不确定类型
//    var promotionScoreExplain: String?
    
}

extension LGWorkItem {
    
    static func prepare(on connection: MySQLConnection) -> Future<Void> {
        return Database.create(self, on: connection, closure: { (builder) in
            builder.field(for: \.id, isIdentifier: true)
            builder.field(for: \.adWord)
            builder.field(for: \.appShow)
            builder.field(for: \.approve)
            builder.field(for: \.companyId)
            builder.field(for: \.deliver)
            builder.field(for: \.isSchoolJob)
            builder.field(for: \.lastLogin)
            
            builder.field(for: \.city)
            builder.field(for: \.companyFullName)
            builder.field(for: \.companyLogo)
            builder.field(for: \.companyShortName)
            builder.field(for: \.companySize)
            builder.field(for: \.createTime)
            builder.field(for: \.district)
            builder.field(for: \.education)
            
            builder.field(for: \.financeStage)
            builder.field(for: \.firstType)
            builder.field(for: \.formatCreateTime)
            builder.field(for: \.imState)
            builder.field(for: \.industryField)
            
            builder.field(for: \.jobNature)
            builder.field(for: \.latitude)
            builder.field(for: \.linestaion)
            builder.field(for: \.longitude)
            builder.field(for: \.pcShow)
            builder.field(for: \.positionAdvantage)
            builder.field(for: \.positionId)
            builder.field(for: \.positionName)
            builder.field(for: \.publisherId)
            builder.field(for: \.resumeProcessDay)
            builder.field(for: \.resumeProcessRate)
            builder.field(for: \.salary)
            builder.field(for: \.score)
            builder.field(for: \.secondType)
            builder.field(for: \.stationname)
            builder.field(for: \.subwayline)
            builder.field(for: \.workYear)
            
//            builder.field(for: \.positionLables)
//            builder.field(for: \.hiTags)
//            builder.field(for: \.businessZones)
//            builder.field(for: \.explain)
//            builder.field(for: \.gradeDescription)
//
//            builder.field(for: \.companyLabelList)
//            builder.field(for: \.industryLables)
//            builder.field(for: \.plus)
//            builder.field(for: \.promotionScoreExplain)
            
            builder.field(for: \.address)
            builder.field(for: \.jobDesc, type: .text)
            builder.field(for: \.tag, type: .text)
        })
    }
    
    static func revert(on connection: MySQLConnection) -> Future<Void> {
        return Database.delete(self, on: connection)
    }
}



/**
 
 {
 "createTime":"2018-06-29 10:08:03",
 "companyId":97604,
 "positionId":3847060,
 "score":0,
 "positionAdvantage":"nice,open,money,free",
 "salary":"15k-20k",
 "companySize":"150-500人",
 "companyLabelList":["带薪年假","定期体检","五险一金","股票期权"],
 "publisherId":4518267,
 "district":"徐汇区",
 "workYear":"3-5年",
 "education":"本科",
 "city":"上海",
 "positionName":"iOS",
 "companyLogo":"i/image/M00/23/1F/CgqKkVcW3nqADRrtAAB5WGock4I583.jpg",
 "financeStage":"D轮及以上",
 "industryField":"移动互联网",
 "approve":1,
 "jobNature":"全职",
 "positionLables":["js","Android","Java","移动开发"],
 "industryLables":[],
 "businessZones":null,
 "companyShortName":"太美医疗科技",
 "longitude":"121.404808",
 "latitude":"31.165281",
 "formatCreateTime":"1天前发布",
 "companyFullName":"嘉兴太美医疗科技有限公司",
 "hitags":null,
 "resumeProcessRate":100,
 "resumeProcessDay":1,
 "imState":"threeDays",
 "lastLogin":1530238073000,
 "explain":null,
 "plus":null,
 "pcShow":0,
 "appShow":0,
 "deliver":0,
 "gradeDescription":null,
 "promotionScoreExplain":null,
 "firstType":"开发/测试/运维类",
 "secondType":"前端开发/移动开发",
 "isSchoolJob":0,
 "subwayline":"9号线",
 "stationname":"漕河泾开发区",
 "linestaion":"9号线_漕河泾开发区;12号线_虹梅路;12号线_虹漕路;12号线_桂林公园",
 "adWord":0
 
 }
 
 */






