//
//  BaseModelProtocol.swift
//  App
//
//  Created by 晋先森 on 2018/6/16.
//

import Foundation
import Vapor
import FluentPostgreSQL
import Authentication

public typealias BaseSQLModel = PostgreSQLModel & Migration & Content


//MARK: 以下方法用于继承协议默认实现 createdAt、updatedAt、deletedAt 和 entity 属性，
//但即使如此，你也需要在 继承者里进行声明 createdAt、updatedAt、deletedAt，例如下面 MyModel 示例。
//如果你有更好的办法可以避免这三个属性重复声明，请告诉我，非常感谢！

//声明协议
protocol SuperModel: BaseSQLModel {

    static var entity: String { get }

    static var createdAtKey: TimestampKey? { get }
    static var updatedAtKey: TimestampKey? { get }
    static var deletedAtKey: TimestampKey? { get }
    
    var createdAt: Date? { get set }
    var updatedAt: Date? { get set }
    var deletedAt: Date? { get set }
}

//默认实现
extension SuperModel {
    
    var deletedAt: Date? { return nil }
    
    static var entity: String { return self.name + "s" }

    static var createdAtKey: TimestampKey? { return \Self.createdAt }
    static var updatedAtKey: TimestampKey? { return \Self.updatedAt }
    static var deletedAtKey: TimestampKey? { return \Self.deletedAt }
}

//遵守协议
struct MyModel: SuperModel {
    
    var id: Int?
    var updatedAt: Date?
    var createdAt: Date?
    var deletedAt: Date?
    
    var name: String?
    var count: Int = 0
    
    init(name: String?,count: Int) {
        self.name = name
        self.count = count
    }
}
















