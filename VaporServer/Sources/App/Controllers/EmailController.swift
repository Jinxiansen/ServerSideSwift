//
//  EmailController.swift
//  App
//
//  Created by Jinxiansen on 2018/5/30.
//

import Vapor
import FluentPostgreSQL

class EmailController: RouteCollection {
    
    func boot(router: Router) throws {
        
        router.post("sendEmail", use: sendEmail)
    }
    
}


extension EmailController {
    
    func sendEmail(_ req: Request) throws -> Future<Response> {
        
        return try req.content.decode(EmailContent.self).flatMap({ content in
            return EmailSendResult
                .query(on: req)
                .filter(\.email == content.email)
                .count()
                .flatMap({ (count) in
                guard count < 3 else {
                   return try ResponseJSON<Empty>(status: .error,
                                                  message: "达到发送上限").encode(for: req)
                }
                return try EmailSender.sendEmail(req, content: content).flatMap({ (state) in
                    let result = EmailSendResult.init(id: nil,
                                                      state: state,
                                                      email: content.email,
                                                      sendTime: TimeManager.shared.currentTime())
                    return result.save(on: req).flatMap({ (us) in
                        return try ResponseJSON(status: .ok,
                                                message: "发送成功", data: result).encode(for: req)
                    })
                })
            })
        
        })
    }
}


struct EmailContent: Content {
    
    var email: String
    var myName: String?
    var subject: String?
    var text: String?
    
    
}



