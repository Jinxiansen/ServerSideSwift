//
//  UserController.swift
//  App
//
//  Created by 晋先森 on 2018/5/26.
//
import Vapor

import Crypto
import Authentication


final class UserController: RouteCollection {
    
    private let authController = AuthController()
    
    func boot(router: Router) throws {
        
        let group = router.grouped("users")
        
        group.post(User.self, at: "login", use: loginUserHandler)
        group.post(User.self, at: "register", use: registerUserHandler)
        group.post(PasswordContainer.self, at: "changePassword", use: changePasswordHandler)
        group.post(UserInfoContainer.self, at: "updateInfo", use: updateUserInfoHandler)
        
        group.get("getUserInfo", use: getUserInfoHandler)
        group.get("avatar",String.parameter, use: getUserAvatarHandler)
        
        group.post("exit", use: exitUserHandler)
        
    }
    
}


private extension User {
    
    func user(with digest: BCryptDigest) throws -> User {
        
        return try User(userID: UUID().uuidString,
                        account: account,
                        password: digest.hash(password))
    }
}

extension UserController {
    
    //MARK: 登录
    func loginUserHandler(_ req: Request,user: User) throws -> Future<Response> {
        
        let futureFirst = User.query(on: req).filter(\.account == user.account).first()
        
        return futureFirst.flatMap({ (existingUser) in
            guard let existingUser = existingUser else {
                return try ResponseJSON<Empty>(status: .userNotExist).encode(for: req)
            }
            
            let digest = try req.make(BCryptDigest.self)
            guard try digest.verify(user.password,
                                    created: existingUser.password) else {
                return try ResponseJSON<Empty>(status: .passwordError).encode(for: req)
            }
            
            return try self.authController
                .authContainer(for: existingUser, on: req)
                .flatMap({ (container) in
                
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
    
    //MARK: 注册
    func registerUserHandler(_ req: Request, newUser: User) throws -> Future<Response> {
        
        let futureFirst = User.query(on: req).filter(\.account == newUser.account).first()
        return futureFirst.flatMap { existingUser in
            guard existingUser == nil else {
                return try ResponseJSON<Empty>(status: .userExist).encode(for: req)
            }
            
            if newUser.account.isAccount().0 == false {
                return try ResponseJSON<Empty>(status: .error,
                                              message: newUser.account.isAccount().1).encode(for: req)
            }
            
            if newUser.password.isPassword().0 == false {
                return try ResponseJSON<Empty>(status: .error,
                                               message: newUser.password.isPassword().1).encode(for: req)
            }
            
            
            return try newUser
                .user(with: req.make(BCryptDigest.self))
                .save(on: req)
                .flatMap { user in
                
                let logger = try req.make(Logger.self)
                logger.warning("New user creatd: \(user.account)")
                
                return try self.authController
                    .authContainer(for: user, on: req)
                    .flatMap({ (container) in
                    
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
            return AccessToken.authenticate(using: token,
                                            on: req).flatMap({ (existToken) in
                                                
                guard let existToken = existToken else {
                    return try ResponseJSON<Empty>(status: .token).encode(for: req)
                }
                
                return try self.authController.remokeTokens(userID: existToken.userID,
                                                            on: req).flatMap({ _ in
                    return try ResponseJSON<Empty>(status: .ok,
                                                  message: "退出成功").encode(for: req)
                })
            })
        })
    }
    
    //MARK: 修改密码
    private func changePasswordHandler(_ req: Request,inputContent: PasswordContainer) throws -> Future<Response> {
        
        return User.query(on: req).filter(\.account == inputContent.account).first().flatMap({ (existUser) in
            
            guard let existUser = existUser else {
                return try ResponseJSON<Empty>(status: .userNotExist).encode(for: req)
            }
            let digest = try req.make(BCryptDigest.self)
            guard try digest.verify(inputContent.password,
                                    created: existUser.password) else {
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
        
        guard let token = req.query[String.self,
                                    at: "token"] else {
            return try ResponseJSON<Empty>(status: .error,
                                           message: "缺少 token 参数").encode(for: req)
        }
        
        let bearToken = BearerAuthorization(token: token)
        return AccessToken
            .authenticate(using: bearToken, on: req)
            .flatMap({ (existToken) in
            
            guard let existToken = existToken else {
                return try ResponseJSON<Empty>(status: .token).encode(for: req)
            }
            
            let futureFirst = UserInfo.query(on: req).filter(\.userID == existToken.userID).first()
            
            return futureFirst.flatMap({ (existInfo) in
                guard let existInfo = existInfo else {
                    return try ResponseJSON<Empty>(status: .error,
                                                  message: "用户信息为空").encode(for: req)
                }
                return try ResponseJSON<UserInfo>(data: existInfo).encode(for: req)
            })
        })
    }
    
    func getUserAvatarHandler(_ req: Request) throws -> Future<Response> {
        
        let name = try req.parameters.next(String.self)
        let path = try VaporUtils.localRootDir(at: ImagePath.userPic, req: req) + "/" + name
        if !FileManager.default.fileExists(atPath: path) {
            let json = ResponseJSON<Empty>(status: .error,
                                           message: "图片不存在")
            return try json.encode(for: req)
        }
        return try req.streamFile(at: path)
    }
    
    //MARK: 更新用户信息
    func updateUserInfoHandler(_ req: Request,container: UserInfoContainer) throws -> Future<Response> {
        
        let bearToken = BearerAuthorization(token: container.token)
        return AccessToken
            .authenticate(using: bearToken, on: req)
            .flatMap({ (existToken) in
            guard let existToken = existToken else {
                return try ResponseJSON<Empty>(status: .token).encode(for: req)
            }
            
            let futureFirst = UserInfo.query(on: req).filter(\.userID == existToken.userID).first()
                
            return futureFirst.flatMap({ (existInfo) in
                    
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
                    
                    if let existPicName = existInfo.picName,let imgName = imgName { //移除原来的照片
                        let path = try VaporUtils.localRootDir(at: ImagePath.userPic, req: req) + "/" + existPicName
                        try FileManager.default.removeItem(at: URL.init(fileURLWithPath: path))
                        userInfo?.picName = imgName
                    }
                    
                }else {
                    userInfo = UserInfo(id: nil,
                                        userID: existToken.userID,
                                        age: container.age,
                                        sex: container.sex,
                                        nickName: container.nickName,
                                        phone: container.phone,
                                        birthday: container.birthday,
                                        location: container.location,
                                        picName: imgName)
                }
                
                return (userInfo!.save(on: req).flatMap({ (info) in
                    return try ResponseJSON<Empty>(status: .ok,
                                                   message: "更新成功").encode(for: req)
                }))
            })
        })
    }
    
}



fileprivate struct TokenContainer: Content {
    var token: String
}

fileprivate struct PasswordContainer: Content {
    var account: String
    var password: String
    var newPassword: String
    
}

fileprivate struct AccessContainer: Content {
    
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










