//
//  LaGouItem.swift
//  App
//
//  Created by 晋先森 on 2018/6/30.
//

import Foundation
import Vapor

struct LGResponseItem: Content {
    
    var code : Int?
    var content : LGContentItem?
    var success : Bool?
    
//不确定的数据类型，暂不解析
//    var msg : AnyObject?
//    var requestId : AnyObject?
//    var resubmitToken : AnyObject?
}


struct LGContentItem: Content {
    
    var hrInfoMap : [String: LGHRInfoMap]?
    var pageNo : Int?
    var pageSize : Int?
    var positionResult : LGPositionResult?
}

struct LGHRInfoMap: Content {
    
    var canTalk : Bool?
    var phone : String?
    var positionName : String?
    var realName : String?
    var receiveEmail : String?
    var userId : Int?
    var userLevel : String?
    
    //    var portrait : AnyObject?
}

struct LGPositionResult: Content {
    
      //不确定的数据类型，暂不解析
//    var hiTags : AnyObject?
//    var hotLabels : AnyObject?
//    var locationInfo : LocationInfo?
//    var queryAnalysisInfo : QueryAnalysisInfo?
//    var strategyProperty : StrategyProperty?
    var result : [LGWorkItem]?
    var resultSize : Int?
    var totalCount : Int?
}












