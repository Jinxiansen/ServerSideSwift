//
//  UserRouteController.swift
//  App
//
//  Created by 晋先森 on 2018/5/26.
//
import Vapor
import FluentMySQL
import Crypto


final class UserRouteController: RouteCollection {
    
    private let authController = AuthController()
    
    func boot(router: Router) throws {
        
        //        let tokenAuthMiddleware = LoginUser.guardAuthMiddleware()
        let group = router.grouped("users")
        //        let group = router.grouped(AuthUserMiddleware.self)
        
        group.post(LoginUser.self, at: "login", use: loginUserHandler)
        group.post(LoginUser.self, at: "register", use: registerUserHandler)
        
        group.post(ChangePasswordContainer.self, at: "changePassword", use: changePassword)
    }
    
}


private extension LoginUser {
    
    func user(with digest: BCryptDigest) throws -> LoginUser {
        return try LoginUser(userID: UUID().uuidString, email: email, password: digest.hash(password))
    }
}

extension UserRouteController {
    
    //TODO: 登录
    func loginUserHandler(_ req: Request,user: LoginUser) throws -> Future<Response> {
        return LoginUser.query(on: req).filter(\.email == user.email).first().flatMap({ (existingUser) in
            guard let existingUser = existingUser else {
                return try ResponseJSON<AccessContainer>(state: .error, message: "\(user.email) 不存在,请先注册").encode(for: req)
            }
            
            let digest = try req.make(BCryptDigest.self)
            guard try digest.verify(user.password, created: existingUser.password) else {
                return try ResponseJSON<AccessContainer>(state: .error, message: "密码不正确").encode(for: req)
            }
            
            return try self.authController.authContainer(for: existingUser, on: req).flatMap({ (container) in
                
                var access = AccessContainer(accessToken: container.accessToken)
                
                if !req.environment.isRelease {
                    access.userID = existingUser.userID
                }
                
                return try ResponseJSON<AccessContainer>(state: .ok, message: "登录成功",data: access).encode(for: req)
            })
        })
    }
    
    //TODO: 注册
    func registerUserHandler(_ req: Request, newUser: LoginUser) throws -> Future<Response> {
        
        let futureFirst = LoginUser.query(on: req).filter(\.email == newUser.email).first()
        
        return futureFirst.flatMap { existingUser in
            guard existingUser == nil else {
                return try ResponseJSON<AccessContainer>(state: .error, message: "\(newUser.email) 已存在").encode(for: req)
            }
            
            if newUser.validation().0 == false {
                return try ResponseJSON<AccessContainer>(state: .error, message: newUser.validation().1).encode(for: req)
            }
            return try newUser.user(with: req.make(BCryptDigest.self)).save(on: req).flatMap { user in
                
                let logger = try req.make(Logger.self)
                logger.warning("New user creatd: \(user.email)")
                
                return try self.authController.authContainer(for: user, on: req).flatMap({ (container) in
                    
                    var access = AccessContainer(accessToken: container.accessToken)
                    if !req.environment.isRelease {
                        access.userID = user.userID
                    }
                    
                    return try ResponseJSON<AccessContainer>(state: .ok, message: "注册成功", data: access).encode(for: req)
                })
            }
        }
    }
    
    //TODO: 修改密码
    func changePassword(_ req: Request,inputContent: ChangePasswordContainer) throws -> Future<Response> {
        return LoginUser.query(on: req).filter(\.email == inputContent.email).first().flatMap({ (existUser) in
            
            guard let existUser = existUser else {
                return try ResponseJSON<TokenContainer>(state: .error, message: "账号不存在").encode(for: req)
            }
            let digest = try req.make(BCryptDigest.self)
            guard try digest.verify(inputContent.password, created: existUser.password) else {
                return try ResponseJSON<TokenContainer>(state: .error, message: "密码不正确").encode(for: req)
            }
            
            if inputContent.newPassword.isPassword().0 == false {
                return try ResponseJSON<TokenContainer>(state: .error, message: inputContent.newPassword.isPassword().1).encode(for: req)
            }
            
            var user = existUser
            user.password = try req.make(BCryptDigest.self).hash(inputContent.newPassword)
            
            return user.save(on: req).flatMap { newUser in
                
                let logger = try req.make(Logger.self)
                logger.info("Password Changed Success: \(newUser.email)")
                
                return try self.authController.authContainer(for: newUser, on: req).flatMap({ (container) in
                    
                    let token = TokenContainer(token: container.accessToken)
       
                    return try ResponseJSON<TokenContainer>(state: .ok, message: "修改成功", data: token).encode(for: req)
                })
            }
            
        })
    }
    
}



struct TokenContainer: Content {
    var token: String?
}

struct ChangePasswordContainer: Content {
    var email: String
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


