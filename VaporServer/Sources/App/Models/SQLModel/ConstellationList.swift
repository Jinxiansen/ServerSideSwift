//
//  ShenPoData.swift
//  App
//
//  Created by 晋先森 on 2018/8/5.
//

import Foundation
import Vapor


struct ConstellationList: BaseSQLModel {
    
    var id: Int?
    static var entity: String { return self.name + "s" }
    
    var name: String?
    var key: String?
    var abbr: String?
    var img: String?
    
    
}
