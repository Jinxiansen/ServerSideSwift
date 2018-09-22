//
//  PageView.swift
//  App
//
//  Created by Jinxiansen on 2018/5/30.
//

import Vapor


struct PageView: BaseSQLModel {
    
    var id: Int?
    static var entity: String { return self.name + "s" }

    var time: String?
    var desc: String?
    var ip: String?
    var body: String?
    var url: String?
    
    init(time: String = TimeManager.current(),
         desc:String?,
         ip: String?,
         body: String?,
         url: String? ) {
        self.time = time
        self.desc = desc
        self.ip = ip
        self.body = body
        self.url = url
    }
}

