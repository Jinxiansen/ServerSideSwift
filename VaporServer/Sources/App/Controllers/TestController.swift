//
//  TestController.swift
//  App
//
//  Created by Jinxiansen on 2018/6/8.
//

import Foundation
import Vapor
import Fluent
import FluentMySQL

struct TestController: RouteCollection {
    
    func boot(router: Router) throws {
        
        router.group("test") { (group) in
            group.post("upload", use: uploadImage)
            
        }
    }
}

extension TestController {
    
    func uploadImage(_ req: Request) throws -> Future<Response> {
        
        return try req.content.decode(ImageContainer.self).flatMap({ (receive) in
            
            print(receive.imgName ?? "")

            let path = try VaporUtils.localRootDir(at: ImagePath.record, req: req) + "/" + VaporUtils.imageName()
            
            if let image = receive.image {
                
                guard image.count < 2048000 else {
                    return try ResponseJSON<Void>(status: .error, message: "有点大，得压缩！").encode(for: req)
                }
                
                try Data(image).write(to: URL(fileURLWithPath: path))
            }
 
            return try ResponseJSON<ImageContainer>(data: receive).encode(for: req)
        })
        
    }
    
}




