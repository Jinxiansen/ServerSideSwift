//
//  QueryBuilder+Extension.swift
//  App
//
//  Created by Jinxiansen on 2018/8/29.
//

import Foundation
import Fluent
import FluentPostgreSQL


extension QueryBuilder {
    
    public func query(page: Int) -> Self {
        let start = page * pageCount
        let end = start + pageCount
        let ran: Range = start..<end
        return self.range(ran)
    }
}
