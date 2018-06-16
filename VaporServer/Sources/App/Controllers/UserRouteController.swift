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
        
        //        let tokenAuthMiddleware = MyUser.guardAuthMiddleware()
        let group = router.grouped("users")
        //        let group = router.grouped(AuthUserMiddleware.self)
        
        group.post(MyUser.self, at: "login", use: loginUserHandler)
        group.post(MyUser.self, at: "register", use: registerUserHandler)
        
        group.post(ChangePasswordContainer.self, at: "changePassword", use: changePassword)
    }
    
}


private extension MyUser {
    
    func user(with digest: BCryptDigest) throws -> MyUser {
        return try MyUser(id: nil, userID: UUID().uuidString, email: email, password: digest.hash(password))
    }
}

extension UserRouteController {
    
    //TODO: 登录
    func loginUserHandler(_ req: Request,user: MyUser) throws -> Future<Response> {
        return try MyUser.query(on: req).filter(\.email == user.email).first().flatMap({ (existingUser) in
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
    func registerUserHandler(_ req: Request, newUser: MyUser) throws -> Future<Response> {
        
        let futureFirst = try MyUser.query(on: req).filter(\.email == newUser.email).first()
        
        return futureFirst.flatMap { existingUser in
            guard existingUser == nil else {
                return try ResponseJSON<AccessContainer>(state: .error, message: "\(newUser.email) 已存在").encode(for: req)
            }
            
            try newUser.validate()
            
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
        return try MyUser.query(on: req).filter(\.email == inputContent.email).first().flatMap({ (existUser) in
            
            guard let existUser = existUser else {
                return try ResponseJSON<TokenContainer>(state: .error, message: "账号不存在").encode(for: req)
            }
            let digest = try req.make(BCryptDigest.self)
            
            guard try digest.verify(inputContent.password, created: existUser.password) else {
                return try ResponseJSON<TokenContainer>(state: .error, message: "密码不正确").encode(for: req)
            }
            
            if inputContent.newPassword.count < 8 {
                return try ResponseJSON<TokenContainer>(state: .error, message: "新密码长度不足8位").encode(for: req)
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
    
    /*
     func getAllUsers(_ req: Request) throws -> Future<ResponseJSON<[User]> > {
     return User.query(on: req).all().map({ (users) in
     return ResponseJSON<[User]>(data: users)
     })
     }
     
     func deleteEmpty(_ req: Request) throws -> Future<ResponseJSON<User>> {
     return try User.query(on: req).filter(\User.email == "").delete().map({ _ in
     return ResponseJSON(data: nil)
     })
     
     }
     
     func creatUser(_ req: Request) throws -> Future<ResponseJSON<User>> {
     
     return try req.content.decode(User.self).flatMap { user in
     return try User.query(on: req).filter(\User.email == user.email).first().flatMap({
     
     if $0 != nil {
     let promise = req.eventLoop.newPromise(ResponseJSON<User>.self)
     promise.succeed(result: ResponseJSON<User>(state: 0, message: "\(user.email)已存在", data: nil))
     return promise.futureResult
     }else {
     return user.save(on: req).map({ (new)  in
     //                        let resultUser = User(new.name, email: new.email, sex: new.sex, age: new.age)
     return ResponseJSON(state: 0, message: "创建成功", data: new)
     })
     }
     })
     }
     }
     
     
     
     func login(_ request: Request) throws  -> Future<PublicUser> { // 1
     return try request.content.decode(User.self).flatMap(to: PublicUser.self) { user in // 2
     return user.save(on: request).map(to: PublicUser.self) { savedUser in // 3
     let publicUser = try PublicUser(email: savedUser.email, id: savedUser.requireID()) // 4
     return publicUser
     }
     }
     }
     
     */
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


