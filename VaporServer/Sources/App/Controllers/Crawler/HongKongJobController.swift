//
//  HongKongJobController.swift
//  App
//
//  Created by 晋先森 on 2018/8/6.
//

import Foundation
import Vapor
import Fluent
import FluentPostgreSQL
import SwiftSoup

class HongKongJobController: RouteCollection {
    
    var maxPage: Int?
    var currentPage = 1
    
    var amount:TimeAmount? = TimeAmount.seconds(10)
    
    func boot(router: Router) throws {
        
        router.group("crawler/job") { (group) in
            
            group.get("start", use: startCrawlerWorksHandler)
            group.get("stop", use: stopCrawlerWorksHandler)
        }
    }
}

extension HongKongJobController {
    
    
    func stopCrawlerWorksHandler(_ req: Request) throws -> Future<Response> {
        
        self.amount = nil
        return try ResponseJSON<Empty>(status: .error, message: "任务已结束").encode(for: req)
    }
    
    func startCrawlerWorksHandler(_ req: Request) throws -> Future<Response> {
        
        guard let amount = self.amount else {
            return try ResponseJSON<Empty>(status: .error, message: "任务已开始").encode(for: req)
        }
        
        return try getHTMLResponse(req, url: "http://www.parttime.hk/jobs/SearchResults.aspx").flatMap({ (html) in
            
            let soup = try SwiftSoup.parse(html)
            
            let pagination = try soup.select("nav").select("ul[id='pagination']").select("li")
            let reversed = pagination.reversed()
            self.maxPage = Int(try reversed[1].text()) ?? 0
            self.currentPage = 1
         
            func runRepeatTimer() throws {
                guard let amount = self.amount else { return }
                _ = req.eventLoop.scheduleTask(in: amount, {
                    try runRepeatTimer()
                     _ = try self.getAllWorksHandlers(req)
                })
            }
            try runRepeatTimer()
            
            let message = "已开始,总共：\(self.maxPage ?? 0) 页"
            return try ResponseJSON<Empty>(status: .ok, message: message).encode(for: req)
        })
        
    }
    
    fileprivate func getAllWorksHandlers(_ req: Request) throws -> Future<Response> {

        guard let maxPage = self.maxPage,maxPage > 0,currentPage <= maxPage else {
            _ = self.stopCrawlerWorksHandler(req)
            return try ResponseJSON<Empty>(status: .error, message: "没有数据。").encode(for: req)
        }
        print("当前页：\(self.currentPage) \(TimeManager.currentTime())")
        let url = "http://www.parttime.hk/jobs/SearchResults.aspx?pg=\(self.currentPage)"
        return try getHTMLResponse(req, url: url).flatMap({ (html) in
            
            self.currentPage += 1
            
            let soup = try SwiftSoup.parse(html)
            let jobs = try soup.select("ul[class='reset-list jobs']").select("li").select("div[class='featured-job-card']")
            
            try jobs.map({ job in
                
                let jobTitle = try job.select("div[class='featured-job-card-title']")
                let title = try jobTitle.text()
                let link = try jobTitle.select("a[class='res-jobtitle']").attr("href")
                let jobId = link.components(separatedBy: "/").last ?? ""
                // industry 行业
                
                let jobBody = try job.select("div[class='featured-job-card-body']").select("div")
                
                let jobArray = jobBody.array()
                let type = try jobArray[1].text()
                let location = try jobArray[2].text()
                let money = try jobBody.select("div[class='text-danger']").text()
                
                let content = try jobArray[4].text()
                
                let company = try jobBody.select("span[class='text-success']").text()
                
                let lastUpdate = try jobBody.select("div[class='dateposted']").text()
                
                _ = HongKongJob.query(on: req).filter(\.jobId == jobId).first().map({ (exist) in
                    
                    if let exist = exist {
                        print("已存在：\(exist.jobId) \(TimeManager.currentTime())")
                    }else {
                        _ = try self.getDetailInfoHandler(req: req, link: link).map({ (detail) in
                            let work = HongKongJob.init(id: nil, title: title, jobId: jobId, type: type, location: location, money: money, content: content, company: company, lastUpdate: lastUpdate, detailInfo: detail.detailInfo, date: detail.date, industry: detail.industry)
                            _ = work.save(on: req).map({ (result) in
                                print("已保存: \(result.jobId) \(TimeManager.currentTime())")
                            })
                        })
                    }
                })
                
            })
            
            
            return try ResponseJSON<String>(data: html).encode(for: req)
        })
    }
    
    fileprivate func getDetailInfoHandler(req: Request,link: String) throws -> Future<DetailItem> {
        
        return try getHTMLResponse(req, url: link).map({ (html) in
            
            let soup = try SwiftSoup.parse(html)
            let body = try soup.select("div[id='jobdetails-body']").select("p").map{ try $0.text()}
            
            let detailInfo = body.joined(separator: "\n")
            
            let table = try soup.select("table[class='job-details-summary-table']").select("tr").map{ try $0.text() }
            
            let date = table[1]
            let industry = table[2] //行业
            
            let item = DetailItem(detailInfo: detailInfo, date: date, industry: industry)
            return item
        })
    }
    
}

fileprivate struct DetailItem {
    
    var detailInfo: String?
    var date: String?
    var industry: String?
    
}

















