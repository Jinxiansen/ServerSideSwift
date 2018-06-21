//
//  EmailSender.swift
//  App
//
//  Created by Jinxiansen on 2018/5/28.
//

import Vapor
import SwiftSMTP
import FluentMySQL

fileprivate let emailPassword = "drfnsdklpxirbibb"

fileprivate var emailDic = Dictionary<String,String>()

fileprivate let smtp = SMTP(hostname: "smtp.qq.com",
                            email: "hi.ya@qq.com",
                            password: emailPassword)

struct EmailSender {
    
    static func sendEmail(_ req:Request,content: EmailContent) throws -> Future<Bool> {
        
        let promise = req.eventLoop.newPromise(Bool.self)

        let emailUser = Mail.User(email: content.email)
        
        let myName = content.myName ?? "Jinxiansen"
        let sub = content.subject ?? "Swift Vapor SMTP \(TimeManager.shared.currentTime())"
        let text = content.text ?? "世界上一成不变的东西，只有“任何事物都是在不断变化的”这条真理。"
        
        let MyEmailUser = Mail.User(name: myName, email: "hi.ya@qq.com")

        let mail = Mail(from: MyEmailUser,
                        to: [emailUser],
                        subject:sub,
                        text: text)
        
        smtp.send(mail) { (error) in
            if let error = error {
                print("发送失败：",error)
                promise.fail(error: error)
            }else {
                print("发送成功")
                promise.succeed(result: true)
            }
        }
        
        return promise.futureResult
        
    }
}









