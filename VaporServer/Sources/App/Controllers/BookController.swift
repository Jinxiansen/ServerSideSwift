//
//  BookController.swift
//  App
//
//  Created by Jinxiansen on 2018/7/25.
//

import Foundation
import Vapor
import Fluent
import FluentPostgreSQL
import SwiftSoup

private let header: HTTPHeaders = ["User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/67.0.3396.99 Safari/537.36"
    ,"Cookie": "yunsuo_session_verify=2a87ab507187674302f32bbc33248656"]


class BookController: RouteCollection {
    
    var elements : [Element]?
    var currentIndex = 0
    var typeId = 0
    var bookId = 0
    
    var amount:TimeAmount? = TimeAmount.seconds(3)
    
    func boot(router: Router) throws {
        
        let group = router.grouped("book")
        group.get("story", use: getBookLastChapterContentHandler)
        group.get("start", use: crawlerFanRenBookHandler)
        
    }
}

extension BookController {
    
    func getBookLastChapterContentHandler(_ req: Request) throws -> Future<Response> {
        let name = req.query[String.self,at:"name"] ?? ""
        
        return BookChapter.query(on: req).filter(\.bookName,.like,"%\(name)%").all().flatMap({ (books) in
            if books.count > 0 {
                return try ResponseJSON<BookChapter>(data: books.last).encode(for: req)
            }else {
                return try ResponseJSON<BookChapter>(status: .error, message: "没有此书: \(name)").encode(for: req)
            }
        })
    }
    
    
    func crawlerFanRenBookHandler(_ req: Request) throws -> Future<Response> {
        
        typeId = 9
        bookId = 9102
        let url = "https://www.piaotian.com/html/\(typeId)/\(bookId)/"
        
        let client = try req.make(FoundationClient.self)
        return client.get(url,headers: header)
            .flatMap(to: Response.self, { clientResponse in
                
                let html = clientResponse.http.body.gbkString
                let document = try SwiftSoup.parse(html)
                let mainBody = try document.select("div[class='mainbody']")
                
                var auther = ""
                var bookName = ""
                if let first = mainBody.first() {
                    let div = try first.select("div[class='list']").text()
                    auther = div.components(separatedBy: "收藏[").first?.replacingOccurrences(of: " ", with: "") ?? ""
                    bookName = div.components(separatedBy: "[").last?.components(separatedBy: "]").first ?? ""
                }
                let lis = try mainBody.select("div[class='centent']").select("a")
                
                print("\n\(bookName) \(auther) 当前总章节 \(lis.array().count) \(TimeManager.currentTime())")
                
                let revertLis = lis.reversed()
                
                self.elements = revertLis
                self.currentIndex = revertLis.count - 1
                
                _ = BookInfo.query(on: req).filter(\.bookId == self.bookId).first().map({ (exist) in
                    
                    if var exist = exist {
                        exist.chapterCount = revertLis.count
                        exist.updateTime = TimeManager.currentTime()
                        _ = exist.update(on: req)
                        print("本书已存在:\(exist.bookName ?? "") \(TimeManager.currentTime())")
                    }else {
                        let bookInfo = BookInfo(id: nil, typeId: self.typeId, bookId: self.bookId, bookName: bookName, chapterCount: revertLis.count, updateTime: TimeManager.currentTime(), content: nil, auther: auther,bookImg: nil)
                        _ = bookInfo.save(on: req).map({ (info) in
                            print("已保存本书:\(info)")
                        })
                    }
                    
                })
                
                func runRepeatTimer() throws {
                    
                    guard let amount = self.amount else { return }
                    
                    _ = req.eventLoop.scheduleTask(in: amount, {
                        
                        try runRepeatTimer()
                        try self.saveBookContentHandler(req: req,
                                                        lis: revertLis,
                                                        bookName: bookName,
                                                        auther: auther,
                                                        bookId: self.bookId,
                                                        typeId: self.typeId)
                    })
                }
                try runRepeatTimer()
                
                return try ResponseJSON<Empty>(status: .ok, message: "开始爬取凡人修仙传,\(self.typeId)/\(self.bookId)").encode(for: req)
            })
        
    }
    
    
    func saveBookContentHandler(req: Request,lis: [Element],bookName: String,auther: String,bookId: Int,typeId: Int) throws {
        
        guard let li = self.elements?[currentIndex] else { return }
        
        let address = try li.attr("href")
        let chpName = try li.text()
        let str = address.components(separatedBy: ".html").first ?? ""
        let chpId = Int(str) ?? 0
        let detailURL = "https://www.piaotian.com/html/\(typeId)/\(bookId)/\(address)"
        
        let first = BookChapter.query(on: req).filter(\.chapterId == chpId).first()
        
        _ = first.flatMap(to: Empty.self) { (exist) in
            
            if self.currentIndex > 0 {
                self.currentIndex -= 1
            }else {
                self.amount = nil
            }
            if let exist = exist {
                print("已存在: \(exist.chapterName ?? "none")\(TimeManager.currentTime())\n")
            }else {
                _ = try self.getDetailContentHandler(req, detailURL: detailURL).map({ (content) -> EventLoopFuture<BookChapter> in
                    let book = BookChapter(id: nil,typeId: typeId, bookId: bookId, bookName: bookName, chapterId: chpId, chapterName: chpName, updateTime: TimeManager.currentTime(), content: content, auther: auther, desc: "")
                    print("已保存：\(book.chapterName ?? "") \(TimeManager.currentTime())")
                    return book.save(on: req)
                })
            }
            return req.eventLoop.newSucceededFuture(result: Empty())
        }
    }
    
    func getDetailContentHandler(_ req: Request,detailURL: String) throws -> Future<String> {
        
        let client = try req.make(FoundationClient.self)
        
        return client.get(detailURL,headers: header).flatMap(to: String.self, { detailResponse in
            let html = detailResponse.http.body.gbkString
            let document = try SwiftSoup.parse(html)
            let content = try document.text().components(separatedBy: "返回书页     ").last?.components(separatedBy: " （快捷键 ←）上一章").first?.replacingOccurrences(of: "     ", with: "\n\n") ?? ""
            
            return req.eventLoop.newSucceededFuture(result: content)
        })
    }
    
    
    
    
}















