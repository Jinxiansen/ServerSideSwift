//
//  Record.swift
//  App
//
//  Created by Jinxiansen on 2018/6/5.
//

//动态
struct Record: BaseSQLModel {
    
    var id: Int?
    
    static var entity: String { return self.name + "s" }
 
    var userID: String
    var content: String?
    var title: String
    var county: String?
    
    var time: String
    var imgName: String?
    
}



