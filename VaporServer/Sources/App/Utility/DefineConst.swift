//
//  DefineConst.swift
//  App
//
//  Created by Jinxiansen on 2018/6/15.
//

import Foundation
import Vapor
import PerfectICONV
import Fluent
import FluentPostgreSQL


struct ImagePath {
    
    static let record = "record" //动态
    static let report = "report" // 举报
    static let userPic = "userPic" // 用户头像
    static let note = "note" // 
}

public let pageCount = 20
public let ImageMaxByteSize = 2048000

public let PasswordMaxCount = 18
public let passwordMinCount = 6

public let AccountMaxCount = 18
public let AccountMinCount = 6




public let CrawlerHeader: HTTPHeaders = ["User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/67.0.3396.99 Safari/537.36"
    ,"Cookie": "yunsuo_session_verify=2a87ab507187674302f32bbc33248656"]


func getHTMLResponse(_ req:Request,url: String) throws -> Future<String> {
    
    return try req.client().get(url,headers: CrawlerHeader).map {
        return $0.utf8String
    }
}





