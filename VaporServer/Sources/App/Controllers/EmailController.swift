//
//  EmailController.swift
//  App
//
//  Created by Jinxiansen on 2018/5/30.
//

import Vapor

class EmailController: RouteCollection {
    
    func boot(router: Router) throws {
        
        router.post("sendEmail", use: sendEmail)
    }
    
}


extension EmailController {
    
    func sendEmail(_ req: Request) throws -> Future<ResponseJSON<EmailSendResult>> {
        
        return try req.content.decode(EmailContent.self).flatMap({ content in
            
            var result = EmailSendResult()
            
            guard content.email.isEmail else {
                return result.save(on: req).map({ (us) in
                    return ResponseJSON(state: .error, message: "邮件地址错误", data: result)
                })
            }
            
//            return EmailSendResult.query(on: req).all().map({ (result) in
//
//                guard result.count >= 3 else {
//                   return ResponseJSON(state: -1, message: "达到发送上限", data: nil)
//                }
            
                return try EmailSender.sendEmail(req, content: content).flatMap({ (state) in
                    result.state = state
                    result.email = content.email
                    result.sendTime = TimeManager.shared.currentTime()
                    
                    return result.save(on: req).map({ (us) in
                        return ResponseJSON(state: .ok, message: "发送成功", data: result)
                    })
                })
//            })
        
        })
    }
}




