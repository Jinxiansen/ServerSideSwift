//
//  FanrenCrawler.swift
//  App
//
//  Created by Jinxiansen on 2018/7/24.
//

import Foundation
import Vapor
import SwiftSoup
import FluentPostgreSQL

private let header: HTTPHeaders = ["User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/67.0.3396.99 Safari/537.36"
    ,"Cookie": "yunsuo_session_verify=2a87ab507187674302f32bbc33248656"]

class FanRenCrawleProvider : Provider {
    
    var interval = 5
    
    var timer: Scheduled<()>?
    
    var elements : [Element]?
    var currentIndex = 0
    
    func register(_ services: inout Services) throws {
        
    }
    
    func didBoot(_ container: Container) throws -> EventLoopFuture<Void> {
        try checkNewChapter(container)
        return .done(on: container)
    }
    
    
    func checkNewChapter(_ container: Container) throws {
        
        //        func runRepeatTimer() throws {
        //            _  = container.eventLoop.scheduleTask(in: TimeAmount.seconds(interval), runRepeatTimer)
        //            try self.foo(on: container)
        //        }
        //        try runRepeatTimer()
        
        try self.foo(on: container)
    }
    
    
    func foo(on container: Container) throws {
        
       
    }
    

    

    
    
    
}







