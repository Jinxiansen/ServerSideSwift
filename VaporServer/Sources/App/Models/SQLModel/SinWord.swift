//
//  SinWord.swift
//  App
//
//  Created by Jinxiansen on 2018/8/22.
//

import Foundation
import Vapor
import FluentPostgreSQL

struct SinWord: BaseSQLModel {
    var id: Int?
    static var entity: String { return self.name + "s" }

    var ci: String
    var explanation: String?
}
