//
//  ConstellationController.swift
//  App
//
//  Created by 晋先森 on 2018/8/5.
//

import Foundation
import Vapor
import FluentPostgreSQL
import SwiftSoup
import Fluent

class ConstellationController: RouteCollection {
    
    var startUrl = "https://www.meiguoshenpo.com/baiyang/"
    var type = "xingzuo"
    
    private var constells: [ConstellationContainer]?
    private var types: [ConstellationType]?
    
    func boot(router: Router) throws {
        
        router.group("sp") { (group) in
            group.get("xingzuo", use: getListHandler)
        }
    }
}


extension ConstellationController {
    
    private func getListHandler(_ req: Request) throws -> Future<Response> {
        
        return try getHTMLResponse(req, url: startUrl).flatMap(to: Response.self, { (html) in
            
            let soup = try SwiftSoup.parse(html)
            
            // 白羊 金牛 双子 巨蟹 ...
            let allXingzuo = try soup.select("div[class='astro_box']").select("a")
            
            self.constells = try allXingzuo.map({ (xingzuo) in
                
                let link = try xingzuo.attr("href")
                let key = try xingzuo.attr("title")
                let abbr = try xingzuo.attr("class")
                let name = try xingzuo.text()
                
                return ConstellationContainer(name: name, link: link, key: key, abbr: abbr)
            })
            
            // 白羊座 运势 百科 爱情 事业 性格 排行 故事 名人
            let eleTypes = try soup.select("div[class='index_left']").select("li").select("a")
            
            self.types = try eleTypes.map { element -> ConstellationType in
                let link = try element.attr("href")
                let key = try element.attr("title")
                let name = try element.text()
                
                return ConstellationType(name: name, link: link, key: key)
            }
            
            struct Result: Content {
                var targetUrl: String
                var constells: [ConstellationContainer]?
                var types: [ConstellationType]?
            }
            
            let data = Result(targetUrl: self.startUrl,constells: self.constells, types: self.types)
            return try ResponseJSON<Result>(data: data).encode(for: req)
        })
    }
    
}


fileprivate struct ConstellationContainer: Content {
    
    var name: String?
    var link: String?
    var key: String?
    var abbr: String?
 
}

fileprivate struct ConstellationType: Content {
    
    var name: String?
    var link: String?
    var key: String?
    
}











