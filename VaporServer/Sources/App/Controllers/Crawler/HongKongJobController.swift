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
    
    var amount:TimeAmount? = TimeAmount.seconds(5)
    
    func boot(router: Router) throws {
        
        router.group("job") { (group) in
            
            group.get("start", use: startCrawlerWorksHandler)
            group.get("stop", use: stopCrawlerWorksHandler)
            
            group.get("list", use: getWorkListHandler)
            
            group.get("area", use: getAreaDataHandler)
        }
    }
}

extension HongKongJobController {
    
    func getAreaDataHandler(_ req: Request) throws -> Future<Response> {
        
        return try getHTMLResponse(req, url: "http://www.parttime.hk/jobs/SearchResults.aspx").flatMap { html in
            
            let soup = try SwiftSoup.parse(html)
            
            //工作类型：兼职，全职等
            let types = try soup.select("div[id='filter-work-type-list']").select("li").map{ try $0.text() }.joined(separator: "  ")
            //求职人群：学生，主妇等。
            let jobseeker = try soup.select("div[id='filter-jobseeker-type-list']").select("li").map{ try $0.text() }.joined(separator: "  ")
            
            let industrys = try soup.select("div[id='filter-category-list']").select("li").select("a").map{ try $0.text() }.joined(separator: "  ").replacingOccurrences(of: " / ", with: "/")
            
            let locations = try soup.select("div[id='filter-location-list']").select("li").select("a").map{ try $0.text() }.joined(separator: "  ")
            
            
            let result = JobTags(types: types, jobseeker: jobseeker, industrys: industrys, locations: locations)
            
            return try ResponseJSON<JobTags>(data: result).encode(for: req)
        }
        
    }
    
    func stopCrawlerWorksHandler(_ req: Request) throws -> Future<Response> {
        
        self.amount = nil
        return try ResponseJSON<Empty>(status: .error,
                                       message: "任务已结束").encode(for: req)
    }
    
    func startCrawlerWorksHandler(_ req: Request) throws -> Future<Response> {
        
        guard let amount = self.amount else {
            return try ResponseJSON<Empty>(status: .error,
                                           message: "任务已开始").encode(for: req)
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
                    _ = try self.saveCurrentPageWorksHandlers(req)
                })
            }
            try runRepeatTimer()
            
            let message = "已开始,总共：\(self.maxPage ?? 0) 页"
            return try ResponseJSON<Empty>(status: .ok,
                                           message: message).encode(for: req)
        })
        
    }
    
    func getWorkListHandler(_ req: Request) throws -> Future<Response> {
        
        let type = req.query[String.self,at: "type"] ?? ""
        let location = req.query[String.self,at: "location"] ?? ""
        let company = req.query[String.self,at: "company"] ?? ""
        let industry = req.query[String.self,at: "industry"] ?? ""
        
        //        let path = req.http.headers["path"].first?.description ?? ""
        //        guard path == req.http.urlString.description else {
        //            return HongKongJob.query(on: req).first().flatMap({ (job) in
        //                var jobs = [HongKongJob]()
        //                if let job = job {
        //                    jobs.append(job)
        //                }
        //                return try ResponseJSON<[HongKongJob]>(data: jobs).encode(for: req)
        //            })
        //        }
        
        
        return HongKongJob.query(on: req)
            .filter(\.type ~~ type)
            .filter(\.location ~~ location)
            .filter(\.company ~~ company)
            .filter(\.industry ~~ industry)
            .query(page: req.page)
            .all()
            .flatMap({ (jobs) in
                
                return try ResponseJSON<[HongKongJob]>(data: jobs).encode(for: req)
            })
    }
    
    private func requestExampleParameters() -> JobTags {
        let categorys = "會計/核數 行政/秘書 廣告/媒體/娛樂 銀行/金融 客戶服務 社區/體育/消閒 樓宇/建築 教育 工程 醫療/醫護 旅遊/酒店/餐飲 人力資源 保險 資訊科技/電訊 法律 物流/運輸 製造 地產/物業 零售 銷售/市場管理 科學/化學 貿易 保健/美容"
        let types = "兼職 全職 合約 臨時工 Freelance 暑期工"
        //let jobseeker = "學生 家庭主婦 畢業生 退休人士 新來港人士"
        let locations = "中西區 灣仔 東區 南區 油尖旺 深水埗 九龍城 黃大仙 觀塘 葵青 荃灣 屯門 元朗 北區 大埔 沙田 西貢 離島"
        
        return JobTags(types: types, jobseeker: nil, industrys: categorys, locations: locations)
    }
    
    private func saveCurrentPageWorksHandlers(_ req: Request) throws -> Future<Response> {
        
        guard let maxPage = self.maxPage,maxPage > 0,currentPage <= maxPage else {
            _ = try self.stopCrawlerWorksHandler(req)
            return try ResponseJSON<Empty>(status: .error,
                                           message: "没有数据。").encode(for: req)
        }
        debugPrint("当前页：\(self.currentPage) \(TimeManager.currentTime())")
        let url = "http://www.parttime.hk/jobs/SearchResults.aspx?pg=\(self.currentPage)"
        return try getHTMLResponse(req, url: url).flatMap({ (html) in
            
            self.currentPage += 1
            
            let soup = try SwiftSoup.parse(html)
            let jobs = try soup.select("ul[class='reset-list jobs']").select("li").select("div[class='featured-job-card']")
            
            _ = try jobs.map({ job in
                
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
                        debugPrint("已存在：\(exist.jobId) \(TimeManager.currentTime())")
                    }else {
                        _ = try self.getDetailInfoHandler(req: req, link: link).map({ (detail) in
                            let work = HongKongJob.init(id: nil, title: title, jobId: jobId, type: type, location: location, money: money, content: content, company: company, lastUpdate: lastUpdate, detailInfo: detail.detailInfo, date: detail.date, industry: detail.industry)
                            _ = work.save(on: req).map({ (result) in
                                debugPrint("已保存: \(result.jobId) \(TimeManager.currentTime())")
                            })
                        })
                    }
                })
            })
            
            return try ResponseJSON<String>(data: html).encode(for: req)
        })
    }
    
    private func getDetailInfoHandler(req: Request,link: String) throws -> Future<DetailItem> {
        
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

private struct DetailItem {
    var detailInfo: String?
    var date: String?
    var industry: String?
    
}

private struct JobTags: Content {
    var types: String?
    var jobseeker: String?
    var industrys: String?
    var locations: String?
}
















