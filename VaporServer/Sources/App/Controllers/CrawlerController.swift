//
//  CrawlerController.swift
//  App
//
//  Created by Jinxiansen on 2018/6/27.
//

import Foundation
import Vapor
import SwiftSoup

struct CrawlerController: RouteCollection {
    
    func boot(router: Router) throws {
        
        router.group("crawler") { (group) in
            
            group.get("swiftDoc", use: crawlerSwiftDocHandler)
            
            group.get("query", use: crawlerQueryHandler)
        }
    }
}

extension CrawlerController {
    
    func crawlerSwiftDocHandler(_ req: Request) throws -> Future<Response> {
        
        let urlStr = "http://swiftdoc.org"
        guard let url = URL(string: urlStr) else {
            return try ResponseJSON<Void>(status: .error,
                                          message: "URL 错误").encode(for: req)
        }
        let client = try req.client()
        return client.get(url)
            .flatMap(to: Response.self, { clientResponse in
                
                struct Item: Content {
                    var type: String
                    var titles: [String]
                }
                let html = clientResponse.http.body.utf8String
                let document = try SwiftSoup.parse(html)
                
                var items = [Item]()
                let elements = try document.select("div[class='col-sm-12']")
                for element in elements {
                    
                    let type = try? element.select("article[class='content']").select("h2").text()
                    guard let mainlist = try? element.select("ul[class='main-list'],li").select("a") else {
                        return try ResponseJSON<Void>(status: .error,
                                                      message: "节点 错误").encode(for: req)
                    }
                    var titles = [String]()
                    for list in mainlist {
                        let text = try list.text()
                        titles.append(text)
                    }
                    items.append(Item(type: type ?? "", titles: titles))
                }
                return try ResponseJSON<[Item]>(status: .ok,
                                                message: "解析成功,解析地址：\(urlStr)",
                                                data: items).encode(for: req)
            })
    }
    
    
    func crawlerQueryHandler(_ req: Request) throws -> Future<Response> {
        
        guard let urlStr = req.query[String.self, at: "url"] else {
            return try ResponseJSON<Void>(status: .error,
                                          message: "缺少 url 参数").encode(for: req)
        }
        
        guard let parse = req.query[String.self, at: "parse"] else {
            return try ResponseJSON<Void>(status: .error,
                                          message: "缺少 parse 参数").encode(for: req)
        }
        
        guard let url = URL(string: urlStr) else {
            return try ResponseJSON<Void>(status: .error,
                                          message: "url 错误").encode(for: req)
        }
        
        return try req.make(FoundationClient.self)
            .get(url)
            .flatMap(to: Response.self, { (clientResponse) in
            
            let html = clientResponse.http.body.utf8String
            let document = try SwiftSoup.parse(html)
            let elements = try document.select(parse)
            
            struct Item: Content {
                var text: String?
                var html: String?
            }
            
            var items = [Item]()
            for element in elements {
                let text = try element.text()
                let html = try element.outerHtml()
                items.append(Item(text: text, html: html))
            }
            return try ResponseJSON<[Item]>(status: .ok,
                                            message: "解析成功,解析地址：\(urlStr)",
                                            data: items).encode(for: req)
        })
    }
    
    
}


extension HTTPBody {
    var utf8String: String {
        return String(data: data ?? Data(), encoding: .utf8) ?? "n/a"
    }
}
