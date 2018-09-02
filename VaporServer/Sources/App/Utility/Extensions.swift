//
//  CrawlerTools.swift
//  App
//
//  Created by 晋先森 on 2018/8/6.
//

import Foundation
import Vapor
import PerfectICONV
import Fluent
import FluentPostgreSQL


extension QueryBuilder {
    
    //客户端传 page 从 1 开始，服务端 -1 从 0 处理。
    public func query(page: Int) -> Self {
        
        let aPage = page < 1 ? 1 : page
        let start = (aPage - 1) * pageCount
        let end = start + pageCount
        let ran: Range = start..<end
        return self.range(ran)
    }
}

extension Request {
    
    var page: Int {
        return query[Int.self, at: "page"] ?? 1
    }
}

extension Response {
    
    var utf8String: String {
        return String(data: self.http.body.data ?? Data(), encoding: .utf8) ?? "n/a"
    }
    
    func convertGBKString(_ req: Request) throws -> Future<String> {
        
        let iconv = try Iconv(from: Iconv.CodePage.GBK, to: Iconv.CodePage.UTF8)
        
        return http.body.consumeData(on: req) // 1) read complete body as raw Data
            .map { (data: Data) -> String in
                var bytes = [UInt8](repeating: 0, count: data.count)
                let buffer = UnsafeMutableBufferPointer(start: &bytes, count: bytes.count)
                _ = data.copyBytes(to: buffer)
                
                let utf8Bytes = iconv.convert(buf: bytes) // !
                let utf8String = String(bytes: utf8Bytes, encoding: .utf8) // !
                return utf8String ?? "g/u"
        }
    }
}
