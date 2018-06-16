//
//  BaseModelProtocol.swift
//  App
//
//  Created by 晋先森 on 2018/6/16.
//

import Foundation
import Vapor
import FluentMySQL
import Authentication

public typealias BaseSQLModel = MySQLModel & Migration & Content
    
//    var createdAt: Date? { get set}
//    var updatedAt: Date? { get set}
//    var deletedAt: Date? { get set}

//extension where Self: BaseModelProtocol {

//    static let deletedAtKey: TimestampKey? = \Self.deletedAt
//    static let createdAtKey: TimestampKey? = \Self.createdAt
//    static let updatedAtKey: TimestampKey? = \Self.updatedAt
    
//}
