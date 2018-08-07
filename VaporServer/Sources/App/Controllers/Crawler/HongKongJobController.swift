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
        
        router.group("crawler/job") { (group) in
            
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
            
            let categorys = try soup.select("div[id='filter-category-list']").select("li").select("a").map{ try $0.text() }.joined(separator: "  ").replacingOccurrences(of: " / ", with: "/")
            
            let locations = try soup.select("div[id='filter-location-list']").select("li").select("a").map{ try $0.text() }.joined(separator: "  ")
            
            
            let result = JobTags(types: types, jobseeker: jobseeker, categorys: categorys, locations: locations)
            
            return try ResponseJSON<JobTags>(data: result).encode(for: req)
        }
        
    }
    
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
        let page = req.query[Int.self,at: "page"] ?? 1
        
        return HongKongJob.query(on: req)
            .filter(\.type,.like,"%\(type)%")
            .filter(\.location,.like,"%\(location)%")
            .filter(\.company,.like,"%\(company)%")
            .filter(\.industry,.like,"%\(industry)%")
            .range(VaporUtils.queryRange(page: page))
            .all()
            .flatMap({ (jobs) in
                
                struct JobResponse: Content {
                    var tags: JobTags?
                    var jobs: [HongKongJob]?
                }
                
                var message = "请求成功"
                var response = JobResponse(tags: nil, jobs: jobs)
                if page == 1 {
                    response.tags = self.requestExampleParameters()
                    message = "请求成功，本接口共有5个可选参数：page,type,location,company,industry；其中 type/location/industry 参数对应值为下面 tags 中所述，tags 中数据只会在第1页返回"
                }
                
                return try ResponseJSON<JobResponse>(status: .ok, message: message, data: response).encode(for: req)
            })
    }
    
    fileprivate func requestExampleParameters() -> JobTags {
        let categorys = "會計/核數 行政/秘書 廣告/媒體/娛樂 銀行/金融 客戶服務 社區/體育/消閒 樓宇/建築 教育 工程 醫療/醫護 旅遊/酒店/餐飲 人力資源 保險 資訊科技/電訊 法律 物流/運輸 製造 地產/物業 零售 銷售/市場管理 科學/化學 貿易 保健/美容"
        let types = "兼職 全職 合約 臨時工 Freelance 暑期工"
//        let jobseeker = "學生 家庭主婦 畢業生 退休人士 新來港人士"
        let locations = "香港島 中西區 灣仔 東區 南區 九龍 油尖旺 深水埗 九龍城 黃大仙 觀塘 新界 葵青 荃灣 屯門 元朗 北區 大埔 沙田 西貢 離島"
        
        return JobTags(types: types, jobseeker: nil, categorys: categorys, locations: locations)
    }
    
    fileprivate func saveCurrentPageWorksHandlers(_ req: Request) throws -> Future<Response> {
        
        guard let maxPage = self.maxPage,maxPage > 0,currentPage <= maxPage else {
            _ = try self.stopCrawlerWorksHandler(req)
            return try ResponseJSON<Empty>(status: .error, message: "没有数据。").encode(for: req)
        }
        print("当前页：\(self.currentPage) \(TimeManager.currentTime())")
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

fileprivate struct JobTags: Content {
    var types: String?
    var jobseeker: String?
    var categorys: String?
    var locations: String?
}
















