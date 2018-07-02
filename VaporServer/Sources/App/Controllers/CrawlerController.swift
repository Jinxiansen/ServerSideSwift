//
//  CrawlerController.swift
//  App
//
//  Created by Jinxiansen on 2018/6/27.
//

import Foundation
import Vapor
import SwiftSoup
import FluentMySQL


let LGHeader: HTTPHeaders = [
    "User-Agent":"Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36     (KHTML, like Gecko) Chrome/59.0.3071.115 Mobile Safari/537.36",
    "Referer":"https://www.lagou.com/jobs/list_ios"]

struct CrawlerController: RouteCollection {
    
    func boot(router: Router) throws {
        
        router.group("crawler") { (group) in
            
            group.get("swiftDoc", use: crawlerSwiftDocHandler)
            
            group.get("query", use: crawlerQueryHandler)
            
            group.get("lagou", use: crawlerLaGouWebHandler)
            
            group.get("lagou/para", use: requestDetailDataHandler)
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


//TODO: Static Func
extension CrawlerController {
    
    func crawlerLaGouWebHandler(_ req: Request) throws -> Future<Response> {
        
        let city = "上海"
        guard let urlStr = "https://www.lagou.com/jobs/positionAjax.json?city=\(city)&needAddtionalResult=false&isSchoolJob=0".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return try ResponseJSON<Void>(status: .error, message: "URL 转码错误").encode(for: req)
        }
        
        guard let url = urlStr.convertToURL() else {
            return try ResponseJSON<Void>(status: .error, message: "URL 错误").encode(for: req)
        }
        
        struct ReqBody: Content {
            var first: Bool = false //是否第一页
            var pn: Int //页码
            var kd: String //搜索关键字
        }
        //第一页 first = true
        let body = ReqBody(first: true, pn: 1, kd: "ios")
        
        //构造请求体。
        var httpReq = HTTPRequest(method: .POST, url: url, headers: LGHeader)
        let randomIP = self.randomIP()
        httpReq.headers.add(name: "Host", value: "www.lagou.com")
        httpReq.headers.add(name: "X-Real-IP", value: randomIP)
        httpReq.headers.add(name: "X-Forwarded-For", value: randomIP)
        let postReq = Request(http: httpReq, using: req)
        try postReq.content.encode(body, as: .urlEncodedForm)
        
        do {
            return try req.client().send(postReq).flatMap(to: Response.self, { (clientResponse) in
                
                let jsonString = clientResponse.http.body.utf8String
                let data = jsonString.convertToData()
                let decode = JSONDecoder()
                let lgItem = try decode.decode(LGResponseItem.self, from: data)
                
                if let result = lgItem.content?.positionResult?.result {
                    
                    for index in 0..<result.count {
                        let item = result[index]
                        // I need sleep 120 seconds
                        _ = LGWorkItem.query(on: req).filter(\.positionId == item.positionId).first().flatMap({ (exist) -> EventLoopFuture<LGWorkItem> in
                            
                            let fultureDetail = try self.requestDetailData(req, positionId: item.positionId)
                            return fultureDetail.flatMap({ (detail) in
                                
                                if let exist = exist {
                                    var updateItem = exist
                                    updateItem.address = detail.address
                                    updateItem.tag = detail.tag
                                    updateItem.jobDesc = detail.jobDesc
                                    
                                    return updateItem.update(on: req).flatMap({ (update) in
                                        debugPrint("已更新:\(TimeManager.shared.currentTime()) id:\(update.positionId))\n")
                                        return req.eventLoop.newSucceededFuture(result: update)
                                    })
                                }else {
                                    var saveItem = item
                                    saveItem.address = detail.address
                                    saveItem.tag = detail.tag
                                    saveItem.jobDesc = detail.jobDesc
                                    
                                    return saveItem.save(on: req).flatMap({ (save) in
                                        debugPrint("已保存:\(TimeManager.shared.currentTime()) id: \(save.positionId))\n")
                                        return req.eventLoop.newSucceededFuture(result: save)
                                    })
                                }
                            })
                        })
                    }
                }
                
                return try ResponseJSON<String>(status: .ok, message: "目前爬了第一页", data: "共\(15) 条数据").encode(for: req)
            })
        } catch {
            debugPrint("请求出错了： \(error)\n")
        }
        
        return try ResponseJSON<String>(status: .ok, message: "已爬完第一页", data: "共爬\(15) 条数据").encode(for: req)
        
    }
    
    //TODO: 请求详情页
    func requestDetailData(_ req: Request, positionId: Int) throws -> Future<LGDetailItem> {
        
        let urlStr = "https://www.lagou.com/jobs/\(positionId).html"
        
        guard let url = URL(string: urlStr) else {
            return req.eventLoop.newSucceededFuture(result: LGDetailItem(tag: "空", jobDesc: "空", address: "空"))
        }
        
        //构造请求体。
        var httpReq = HTTPRequest(method: .GET, url: url)
        //        httpReq.headers.add(name: "Host", value: "www.lagou.com")
        let randomIP = self.randomIP()
        httpReq.headers.add(name: "X-Real-IP", value: randomIP)
        httpReq.headers.add(name: "X-Forwarded-For", value: randomIP)
        let getReq = Request(http: httpReq, using: req)
        
        return try req.client().send(getReq).flatMap(to: LGDetailItem.self, { (clientResp) in
            let html = clientResp.http.body.utf8String
            let document = try SwiftSoup.parse(html)
            
            let tag = try document.select("dd[class='job_request']").text()
            
            let jobDesc = try document.select("dd[class='job_bt']").text()
            let address = try document.select("div[class='work_addr']").text().replacingOccurrences(of: "查看地图", with: "")
            debugPrint("\(randomIP) 解析结果 = \(tag)\n\(jobDesc)\naddress: \(address)\n")
            
            return req.eventLoop.newSucceededFuture(result: LGDetailItem(tag: tag, jobDesc: jobDesc, address: address))
        })
    }
    
    
    func requestDetailDataHandler(_ req: Request) throws -> Future<Response> {
        guard let positionId = req.query[Int.self, at: "id"] else {
            return try ResponseJSON<Void>(status: .error, message: " 缺少 id").encode(for: req)
        }
        return try requestDetailData(req, positionId: positionId).flatMap({ (item) in
            return try ResponseJSON<LGDetailItem>(data: item).encode(for: req)
        })
    }
    
    
    
    func randomIP() -> String {
        
        return "\(Int(arc4random()%244) + 10).\(Int(arc4random()%244) + 10).\(Int(arc4random()%244) + 10).\(Int(arc4random()%244) + 10)"
    }
    
}


struct LGDetailItem: Content {
    
    var tag: String?
    var jobDesc: String?
    var address: String?
    
}

extension HTTPBody {
    var utf8String: String {
        return String(data: data ?? Data(), encoding: .utf8) ?? "n/a"
    }
}
