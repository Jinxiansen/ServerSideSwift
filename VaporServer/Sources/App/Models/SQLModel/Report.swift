//
//  Report.swift
//  App
//
//  Created by Jinxiansen on 2018/6/15.
//


//举报
struct Report: BaseSQLModel {
    var id: Int?
    
    static var entity: String { return self.name + "s" }

    var userID: String
    var content: String
    var county: String
    
    var imgName: String?
    var imgName2: String?
    var contact: String?

}
