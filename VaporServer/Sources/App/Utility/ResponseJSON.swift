//
//  ResponseJSON.swift
//  App
//
//  Created by 晋先森 on 2018/5/26.
//

import Vapor

struct Empty: Content {}

struct ResponseJSON<T: Content>: Content {
    
    private var status: ResponseStatus
    private var message: String
    private var data: T?
    
    init(data: T) {
        self.status = .ok
        self.message = status.desc
        self.data = data
    }
    
    init(status:ResponseStatus = .ok) {
        self.status = status
        self.message = status.desc
        self.data = nil
    }
    
    
    init(status:ResponseStatus = .ok,
         message: String = ResponseStatus.ok.desc) {
        self.status = status
        self.message = message
        self.data = nil
    }
    
    init(status:ResponseStatus = .ok,
         message: String = ResponseStatus.ok.desc,
         data: T?) {
        self.status = status
        self.message = message
        self.data = data
    }
}
 

enum ResponseStatus:Int,Content {
    case ok = 0
    case error = 1
    case missesPara = 3
    case token = 4
    case unknown = 10
    case userExist = 20
    case userNotExist = 21
    case passwordError = 22
    
    var desc : String {
        switch self {
        case .ok:
            return "请求成功"
        case .error:
            return "请求失败"
        case .missesPara:
            return "缺少参数"
        case .token:
            return "Token 已失效，请重新登录"
        case .unknown:
            return "未知失败"
        case .userExist:
            return "用户已存在"
        case .userNotExist:
            return "用户不存在"
        case .passwordError:
            return "密码不正确"
        
            
        }
    }
    
}






