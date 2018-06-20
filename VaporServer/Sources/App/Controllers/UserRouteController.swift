//
//  UserRouteController.swift
//  App
//
//  Created by 晋先森 on 2018/5/26.
//
import Vapor
import FluentMySQL
import Crypto
import Authentication


final class UserRouteController: RouteCollection {
    
    private let authController = AuthController()
    
    func boot(router: Router) throws {
        
        let group = router.grouped("users")
        
        group.post(LoginUser.self, at: "login", use: loginUserHandler)
        group.post(LoginUser.self, at: "register", use: registerUserHandler)
        group.post(ChangePasswordContainer.self, at: "changePassword", use: changePassword)
        group.post("exit", use: exitUserHandler)
        
    }
    
}


private extension LoginUser {
    
    func user(with digest: BCryptDigest) throws -> LoginUser {
        return try LoginUser(userID: UUID().uuidString, account: account, password: digest.hash(password))
    }
}

extension UserRouteController {
    
    //TODO: 登录
    func loginUserHandler(_ req: Request,user: LoginUser) throws -> Future<Response> {
        return LoginUser.query(on: req).filter(\.account == user.account).first().flatMap({ (existingUser) in
            guard let existingUser = existingUser else {
                return try ResponseJSON<AccessContainer>(status: .error, message: "\(user.account) 不存在,请先注册").encode(for: req)
            }
            
            let digest = try req.make(BCryptDigest.self)
            guard try digest.verify(user.password, created: existingUser.password) else {
                return try ResponseJSON<AccessContainer>(status: .error, message: "密码不正确").encode(for: req)
            }
            
            return try self.authController.authContainer(for: existingUser, on: req).flatMap({ (container) in
                
                var access = AccessContainer(accessToken: container.accessToken)
                
                if !req.environment.isRelease {
                    access.userID = existingUser.userID
                }
                
                return try ResponseJSON<AccessContainer>(status: .ok, message: "登录成功",data: access).encode(for: req)
            })
        })
    }
    
    //TODO: 注册
    func registerUserHandler(_ req: Request, newUser: LoginUser) throws -> Future<Response> {
        
        let futureFirst = LoginUser.query(on: req).filter(\.account == newUser.account).first()
        
        return futureFirst.flatMap { existingUser in
            guard existingUser == nil else {
                return try ResponseJSON<AccessContainer>(status: .userExist, message: "\(newUser.account) 已存在").encode(for: req)
            }
            
            if newUser.validation().0 == false {
                return try ResponseJSON<AccessContainer>(status: .error, message: newUser.validation().1).encode(for: req)
            }
            return try newUser.user(with: req.make(BCryptDigest.self)).save(on: req).flatMap { user in
                
                let logger = try req.make(Logger.self)
                logger.warning("New user creatd: \(user.account)")
                
                return try self.authController.authContainer(for: user, on: req).flatMap({ (container) in
                    
                    var access = AccessContainer(accessToken: container.accessToken)
                    if !req.environment.isRelease {
                        access.userID = user.userID
                    }
                    
                    return try ResponseJSON<AccessContainer>(status: .ok, message: "注册成功", data: access).encode(for: req)
                })
            }
        }
    }
    
    func exitUserHandler(_ req: Request) throws -> Future<Response> {
        
        return try req.content.decode(TokenContainer.self).flatMap({ container in
            
            let token = BearerAuthorization(token: container.token)
            
            return AccessToken.authenticate(using: token, on: req).flatMap({ (existToken) in
                guard let existToken = existToken else {
                    return try ResponseJSON<Void>(status: .token).encode(for: req)
                }
                
                return try self.authController.remokeTokens(userID: existToken.userID, on: req).flatMap({ _ in
                    return try ResponseJSON<Void>(status: .ok).encode(for: req)
                })
                
            })
            
        })
        
    }
    
    //TODO: 修改密码
    func changePassword(_ req: Request,inputContent: ChangePasswordContainer) throws -> Future<Response> {
        return LoginUser.query(on: req).filter(\.account == inputContent.account).first().flatMap({ (existUser) in
            
            guard let existUser = existUser else {
                return try ResponseJSON<TokenContainer>(status: .error, message: "账号不存在").encode(for: req)
            }
            let digest = try req.make(BCryptDigest.self)
            guard try digest.verify(inputContent.password, created: existUser.password) else {
                return try ResponseJSON<TokenContainer>(status: .error, message: "密码不正确").encode(for: req)
            }
            
            if inputContent.newPassword.isPassword().0 == false {
                return try ResponseJSON<TokenContainer>(status: .error, message: inputContent.newPassword.isPassword().1).encode(for: req)
            }
            
            var user = existUser
            user.password = try req.make(BCryptDigest.self).hash(inputContent.newPassword)
            
            return user.save(on: req).flatMap { newUser in
                
                let logger = try req.make(Logger.self)
                logger.info("Password Changed Success: \(newUser.account)")
                
                return try self.authController.authContainer(for: newUser, on: req).flatMap({ (container) in
                    
                    let token = TokenContainer(token: container.accessToken)
       
                    return try ResponseJSON<TokenContainer>(status: .ok, message: "修改成功", data: token).encode(for: req)
                })
            }
            
        })
    }
    
}



struct TokenContainer: Content {
    var token: String
}

struct ChangePasswordContainer: Content {
    var account: String
    var password: String
    var newPassword: String
    
}

struct AccessContainer: Content {
    
    var accessToken: String
    var userID:String?
    
    init(accessToken: String,userID: String? = nil) {
        self.accessToken = accessToken
        self.userID = userID
    }
}


