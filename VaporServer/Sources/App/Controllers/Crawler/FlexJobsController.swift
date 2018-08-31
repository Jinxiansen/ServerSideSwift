//
//  FlexJobsController.swift
//  App
//
//  Created by 晋先森 on 2018/8/31.
//

import Foundation
import Vapor
import SwiftSoup
import Fluent
import FluentPostgreSQL

class FlexJobsController: RouteCollection {
    
    
    func boot(router: Router) throws {
       
        router.group("in") { (router) in
            router.get("html", use: parseHtmlHandler)
            
        }
        
    }
}


extension FlexJobsController {
    
    func parseHtmlHandler(_ req: Request) throws -> Future<Response> {
        
        let url = "https://www.flexjobs.com/jobs/new"
        return try req.client().get(url,headers: CrawlerHeader).flatMap({ response in
            
            let html = try SwiftSoup.parse(response.http.utf8String)
            
            let group = try html.select("ul[id='joblist']").select("li")
            var titles = [String]()
            try group.forEach({ (element) in
                let title = try element.select("div[class='col-sm-6']").select("a").text()
//                let link = try element.select("div[class='col-sm-6']").select("a").attr("href")
                titles.append(title)
            })
            
            return try ResponseJSON<[String]>(data: titles).encode(for: req)
        })
    }
    
    
}













