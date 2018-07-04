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
        group.post(ChangePasswordContainer.self, at: "changePassword", use: changePasswordHandler)
        group.post(UserInfoContainer.self, at: "updateInfo", use: updateUserInfoHandler)
        
        group.get("getUserInfo", use: getUserInfoHandler)
        
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
        
        let first = LoginUser.query(on: req).filter(\.account == user.account).first()
        return first.flatMap({ (existingUser) in
            guard let existingUser = existingUser else {
                return try ResponseJSON<Empty>(status: .userNotExist).encode(for: req)
            }
            
            let digest = try req.make(BCryptDigest.self)
            guard try digest.verify(user.password, created: existingUser.password) else {
                return try ResponseJSON<Empty>(status: .passwordError).encode(for: req)
            }
            
            return try self.authController.authContainer(for: existingUser, on: req).flatMap({ (container) in
                
                var access = AccessContainer(accessToken: container.accessToken)
                if !req.environment.isRelease {
                    access.userID = existingUser.userID
                }
                return try ResponseJSON<AccessContainer>(status: .ok,
                                                         message: "登录成功",
                                                         data: access).encode(for: req)
            })
        })
    }
    
    //TODO: 注册
    func registerUserHandler(_ req: Request, newUser: LoginUser) throws -> Future<Response> {
        
        let futureFirst = LoginUser.query(on: req).filter(\.account == newUser.account).first()
        return futureFirst.flatMap { existingUser in
            guard existingUser == nil else {
                return try ResponseJSON<Empty>(status: .userExist).encode(for: req)
            }
            
            if newUser.validation().0 == false {
                return try ResponseJSON<Empty>(status: .error,
                                              message: newUser.validation().1).encode(for: req)
            }
            return try newUser.user(with: req.make(BCryptDigest.self)).save(on: req).flatMap { user in
                
                let logger = try req.make(Logger.self)
                logger.warning("New user creatd: \(user.account)")
                
                return try self.authController.authContainer(for: user, on: req).flatMap({ (container) in
                    
                    var access = AccessContainer(accessToken: container.accessToken)
                    if !req.environment.isRelease {
                        access.userID = user.userID
                    }
                    
                    return try ResponseJSON<AccessContainer>(status: .ok,
                                                             message: "注册成功",
                                                             data: access).encode(for: req)
                })
            }
        }
    }
    
    func exitUserHandler(_ req: Request) throws -> Future<Response> {
        
        return try req.content.decode(TokenContainer.self).flatMap({ container in
            let token = BearerAuthorization(token: container.token)
            return AccessToken.authenticate(using: token, on: req).flatMap({ (existToken) in
                guard let existToken = existToken else {
                    return try ResponseJSON<Empty>(status: .token).encode(for: req)
                }
                
                return try self.authController.remokeTokens(userID: existToken.userID, on: req).flatMap({ _ in
                    return try ResponseJSON<Empty>(status: .ok,
                                                  message: "退出成功").encode(for: req)
                })
            })
        })
    }
    
    //TODO: 修改密码
    func changePasswordHandler(_ req: Request,inputContent: ChangePasswordContainer) throws -> Future<Response> {
        return LoginUser.query(on: req).filter(\.account == inputContent.account).first().flatMap({ (existUser) in
            
            guard let existUser = existUser else {
                return try ResponseJSON<Empty>(status: .userNotExist).encode(for: req)
            }
            let digest = try req.make(BCryptDigest.self)
            guard try digest.verify(inputContent.password, created: existUser.password) else {
                return try ResponseJSON<Empty>(status: .passwordError).encode(for: req)
            }
            
            if inputContent.newPassword.isPassword().0 == false {
                return try ResponseJSON<Empty>(status: .error,
                                              message: inputContent.newPassword.isPassword().1).encode(for: req)
            }
            
            var user = existUser
            user.password = try req.make(BCryptDigest.self).hash(inputContent.newPassword)
            
            return user.save(on: req).flatMap { newUser in
                
                let logger = try req.make(Logger.self)
                logger.info("Password Changed Success: \(newUser.account)")
                return try ResponseJSON<Empty>(status: .ok,
                                              message: "修改成功，请重新登录！").encode(for: req)
            }
        })
    }
    
    func getUserInfoHandler(_ req: Request) throws -> Future<Response> {
        
        guard let token = req.query[String.self, at: "token"] else {
            return try ResponseJSON<Empty>(status: .error, message: "缺少 token 参数").encode(for: req)
        }
        
        let bearToken = BearerAuthorization(token: token)
        return AccessToken.authenticate(using: bearToken, on: req).flatMap({ (existToken) in
            
            guard let existToken = existToken else {
                return try ResponseJSON<Empty>(status: .token).encode(for: req)
            }
            
            let first = UserInfo.query(on: req).filter(\.userID == existToken.userID).first()
            
            return first.flatMap({ (existInfo) in
                guard let existInfo = existInfo else {
                    return try ResponseJSON<Empty>(status: .error,
                                                  message: "用户信息为空").encode(for: req)
                }
                return try ResponseJSON<UserInfo>(data: existInfo).encode(for: req)
            })
        })
    }
    
    //TODO: 更新用户信息
    func updateUserInfoHandler(_ req: Request,container: UserInfoContainer) throws -> Future<Response> {
        
        let bearToken = BearerAuthorization(token: container.token)
        return AccessToken.authenticate(using: bearToken, on: req).flatMap({ (existToken) in
            guard let existToken = existToken else {
                return try ResponseJSON<Empty>(status: .token).encode(for: req)
            }
            
            return UserInfo.query(on: req).filter(\.userID == existToken.userID).first().flatMap({ (existInfo) in
                var imgName: String?
                if let file = container.picImage { //如果上传了图片，就判断下大小，否则就揭过这一茬。
                    guard file.data.count < ImageMaxByteSize else {
                        return try ResponseJSON<Empty>(status: .error,
                                                      message: "图片过大，得压缩！").encode(for: req)
                    }
                    imgName = try VaporUtils.imageName()
                    let path = try VaporUtils.localRootDir(at: ImagePath.userPic, req: req) + "/" + imgName!
                    
                    try Data(file.data).write(to: URL(fileURLWithPath: path))
                }
                
                let userInfo: UserInfo?
                if var existInfo = existInfo { //存在则更新。
                    userInfo = existInfo.update(with: container)
                    
                    if let existPicName = existInfo.picName,let _ = imgName { //移除原来的照片
                        let path = try VaporUtils.localRootDir(at: ImagePath.userPic, req: req) + "/" + existPicName
                        try FileManager.default.removeItem(at: URL.init(fileURLWithPath: path))
                    }
                    userInfo?.picName = imgName
                }else {
                    userInfo = UserInfo(id: nil, userID: existToken.userID, age: container.age,
                                        sex: container.sex, nickName: container.nickName,
                                        phone: container.phone, birthday: container.birthday,
                                        location: container.location, picName: imgName)
                }
                
                return (userInfo!.save(on: req).flatMap({ (info) in
                    return try ResponseJSON<Empty>(status: .ok, message: "更新成功").encode(for: req)
                }))
            })
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

struct UserInfoContainer: Content {
    
    var token:String
    
    var age: Int?
    var sex: Int?
    var nickName: String?
    var phone: String?
    var birthday: String?
    var location: String?
    var picImage: File?
    
}










