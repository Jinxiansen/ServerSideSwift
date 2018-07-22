//
//  ScreenShot.swift
//  App
//
//  Created by 晋先森 on 2018/7/22.
//

import Foundation


struct ScreenShot: BaseSQLModel {
    var id: Int?
    
    static var entity: String { return self.name + "s" }
    
    var imgPath: String?
    var bgPath: String?
    var outPath: String?
    var desc: String?
    var time: String?
    
}
