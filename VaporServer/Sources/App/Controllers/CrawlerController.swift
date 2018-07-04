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

private let crawlerInterval = TimeAmount.minutes(2) // 间隔2分钟

private let city = "上海" //搜索城市
private let key = "ios" //搜索关键词

class CrawlerController: RouteCollection {
    
    var timer: Scheduled<()>?
    
    var page = 1
    var filterIndex: Int = 0
    var result: [LGWorkItem]?
    
    func boot(router: Router) throws {
        
        router.group("crawler") { (group) in
            
            group.get("swiftDoc", use: crawlerSwiftDocHandler)
            
            group.get("query", use: crawlerQueryHandler)
            
            group.get("lagou/ios", use: readLGIOSJSON)
            
            group.get("lagou/para", use: requestDetailDataHandler)
            group.get("lagou/start", use: startTimer)
            group.get("lagou/cancel", use: cancelTimer)
        }
    }
}

extension CrawlerController {
    
    func startTimer(_ req: Request) throws -> Future<Response> {
        
        #if os(Linux)
        if let hostName = req.http.remotePeer.hostname?.description {
            if !hostName.contains("localhost") && !hostName.contains("127.0.0.1") {
                return try ResponseJSON<Empty>(status: .error, message: "无权访问").encode(for: req)
            }
        }
        #endif
        
        guard self.timer == nil else {
            return try ResponseJSON<Empty>(status: .error, message: "正在运行，请先调用 Cancel api").encode(for: req)
        }
        
         _ = try self.crawlerLaGouWebHandler(req)

        return try ResponseJSON<Empty>(status: .ok, message: "开始爬取任务：\(city) \(key)").encode(for: req)
    }
    
    func cancelTimer(_ req: Request) throws -> Future<Response> {
        self.timer?.cancel()
        return try ResponseJSON<Empty>(status: .ok, message: "已取消").encode(for: req)
    }
    
    func runRepeatTimer(_ req: Request) throws {
        
        if let result = self.result,result.count > 0 {
            if self.filterIndex == result.count - 1 {
                debugPrint("第\(page)页已爬完。\n")
                page += 1
                _ = try self.crawlerLaGouWebHandler(req)
                return
            }
        }
            
        self.timer = req.eventLoop.scheduleTask(in: crawlerInterval) {
            debugPrint("当前运行时间：" + TimeManager.shared.currentTime())
            _ = try self.parseResultHandler(req)
        }
    }
}

extension CrawlerController {
    
    func crawlerSwiftDocHandler(_ req: Request) throws -> Future<Response> {
        
        let urlStr = "http://swiftdoc.org"
        guard let url = URL(string: urlStr) else {
            return try ResponseJSON<Empty>(status: .error,
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
                        return try ResponseJSON<Empty>(status: .error,
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
            return try ResponseJSON<Empty>(status: .error,
                                          message: "缺少 url 参数").encode(for: req)
        }
        
        guard let parse = req.query[String.self, at: "parse"] else {
            return try ResponseJSON<Empty>(status: .error,
                                          message: "缺少 parse 参数").encode(for: req)
        }
        
        guard let url = URL(string: urlStr) else {
            return try ResponseJSON<Empty>(status: .error,
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
        
        guard let urlStr = "https://www.lagou.com/jobs/positionAjax.json?city=\(city)&needAddtionalResult=false&isSchoolJob=0".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return try ResponseJSON<Empty>(status: .error, message: "URL 转码错误").encode(for: req)
        }
        
        guard let url = urlStr.convertToURL() else {
            return try ResponseJSON<Empty>(status: .error, message: "URL 错误").encode(for: req)
        }
        
        let LGHeader: HTTPHeaders = [
            "User-Agent":"Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36     (KHTML, like Gecko) Chrome/59.0.3071.115 Mobile Safari/537.36",
            "Referer":"https://www.lagou.com/jobs/list_\(key)"]
        
        struct ReqBody: Content {
            var first: Bool = false //是否第一页
            var pn: Int //页码
            var kd: String //搜索关键字
        }
        //第一页 first = true
        let body = ReqBody(first: page == 1 ? true: false, pn: page, kd: key)
        
        //构造请求体。
        var httpReq = HTTPRequest(method: .POST, url: url, headers: LGHeader)
        let randomIP = self.randomIP()
        httpReq.headers.add(name: "Host", value: "www.lagou.com")
        httpReq.headers.add(name: "X-Real-IP", value: randomIP)
        httpReq.headers.add(name: "X-Forwarded-For", value: randomIP)
        let postReq = Request(http: httpReq, using: req)
        try postReq.content.encode(body, as: .urlEncodedForm)
        
        return try req.client().send(postReq).flatMap(to: Response.self, { (clientResponse) in
            
            let jsonString = clientResponse.http.body.utf8String
            let data = jsonString.convertToData()
            let decode = JSONDecoder()
            let lgItem = try decode.decode(LGResponseItem.self, from: data)
            
            if let result = lgItem.content?.positionResult?.result,result.count > 0 {
                self.result = result
                self.filterIndex = 0
                
                print("取到第\(self.page)页,\(result.count)条数据 -> 启动定时器：" + TimeManager.shared.currentTime())
                try self.runRepeatTimer(req) //取到数据开始定时解析
                
                return try ResponseJSON<Empty>(status: .ok, message: "爬到\(result.count)条数据").encode(for: req)
            }else {
                self.timer?.cancel()
            }
            return try ResponseJSON<Empty>(status: .error, message: "没有数据了，任务已取消").encode(for: req)
        })
        
    }
    
    
    func parseResultHandler(_ req: Request) throws -> Future<LGWorkItem?> {
        
        guard let result = self.result,result.count > 0 else {
            return req.eventLoop.newSucceededFuture(result: nil)
        }
        
        let item = result[filterIndex]
        
        return LGWorkItem.query(on: req).filter(\.positionId == item.positionId).first().flatMap({ (exist)  in
            
            let fultureDetail = try self.requestDetailData(req, positionId: item.positionId)
            return fultureDetail.flatMap({ (detail) in
                
                if var exist = exist {
                    exist.address = detail.address
                    exist.tag = detail.tag
                    exist.jobDesc = detail.jobDesc

                    self.filterIndex += 1
                    try self.runRepeatTimer(req)
                    return exist.update(on: req).flatMap({ (update) in
                        debugPrint("已更新:\(TimeManager.shared.currentTime()) id:\(update.positionId))\n")
                        return req.eventLoop.newSucceededFuture(result: update)
                    })
                }else {
                    let newItem = LGWorkItem(
                        id: nil, adWord: item.adWord, appShow: item.appShow,
                        approve: item.approve, city: item.city, companyFullName: item.companyFullName,
                        companyId: item.companyId, companyLogo: item.companyLogo, companyShortName: item.companyShortName,
                        companySize: item.companySize, createTime: item.createTime, deliver: item.deliver,
                        district: item.district, education: item.education, financeStage: item.financeStage,
                        firstType: item.firstType, formatCreateTime: item.formatCreateTime, imState: item.imState,
                        industryField: item.industryField, isSchoolJob: item.isSchoolJob, jobNature: item.jobNature,
                        lastLogin: item.lastLogin, latitude: item.latitude, linestaion: item.linestaion,
                        longitude:item.longitude, pcShow: item.pcShow, positionAdvantage:item.positionAdvantage,positionId:
                        item.positionId, positionName: item.positionName, publisherId: item.publisherId,
                        resumeProcessDay: item.resumeProcessDay, resumeProcessRate: item.resumeProcessRate,
                        salary: item.salary, score: item.score, secondType: item.secondType,
                        stationname: item.stationname, subwayline: item.subwayline, workYear: item.workYear,
                        tag: detail.tag, jobDesc: detail.jobDesc, address: detail.address)
                    
                    let save = newItem.save(on: req)
                    save.whenFailure({ (error) in
                        debugPrint("保存失败: \(error)\n")
                    })
                    self.filterIndex += 1
                    try self.runRepeatTimer(req)
                    return save.flatMap({ (saveResult) in
                        debugPrint("已保存:\(TimeManager.shared.currentTime()) id: \(saveResult.positionId))\n")
                        return req.eventLoop.newSucceededFuture(result: saveResult)
                    })
                }
            })
        })
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
            debugPrint("\(randomIP) 解析结果 = \(tag)\n\n")
            
            return req.eventLoop.newSucceededFuture(result: LGDetailItem(tag: tag, jobDesc: jobDesc, address: address))
        })
    }
    
    
    func requestDetailDataHandler(_ req: Request) throws -> Future<Response> {
        guard let positionId = req.query[Int.self, at: "id"] else {
            return try ResponseJSON<Empty>(status: .error, message: " 缺少 id").encode(for: req)
        }
        return try requestDetailData(req, positionId: positionId).flatMap({ (item) in
            return try ResponseJSON<LGDetailItem>(data: item).encode(for: req)
        })
    }
    
    
    func readLGIOSJSON(_ req: Request) throws -> Future<Response> {
        
        return LGWorkItem.query(on: req).all().flatMap({ (items) in
            return try ResponseJSON<[LGWorkItem]>(data: items).encode(for: req)
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
