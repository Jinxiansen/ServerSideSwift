//
//  CrawlerTools.swift
//  App
//
//  Created by 晋先森 on 2018/8/6.
//

import Foundation
import Vapor
import PerfectICONV


public let CrawlerHeader: HTTPHeaders = ["User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/67.0.3396.99 Safari/537.36"
    ,"Cookie": "yunsuo_session_verify=2a87ab507187674302f32bbc33248656"]


func getHTMLResponse(_ req:Request,url: String) throws -> Future<String> {
    
    return try req.client().get(url,headers: CrawlerHeader).flatMap {
        let html = $0.http.utf8String
        return req.eventLoop.newSucceededFuture(result: html)
    }
}


//extension HTTPBody {
//
//    var utf8String: String {
//        return String(data: data ?? Data(), encoding: .utf8) ?? "n/a"
//    }
//
//}

extension HTTPResponse {
    
    var utf8String: String {
        return String(data: body.data ?? Data(), encoding: .utf8) ?? "n/a"
    }
}

extension Response {
    
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
