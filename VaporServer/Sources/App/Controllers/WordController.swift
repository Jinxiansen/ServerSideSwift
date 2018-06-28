//
//  WordController.swift
//  App
//
//  Created by 晋先森 on 2018/6/10.
//


import Vapor
import Fluent
import FluentMySQL


struct WordController: RouteCollection {
    
    func boot(router: Router) throws {
        
        router.group("words") { (router) in
            
            // words/word?str= ""
            router.get("word", use: filterWordData)
            
            router.get("idiom", use: filterIdiom)
            
            router.get("xxidiom", use: filterXieHouIdiom)
            
        }
    }
}


extension WordController {
    
    //TODO: 查询单字
    func filterWordData(_ req: Request) throws -> Future<Response> {
        
        guard let input = req.query[String.self, at: "str"],input.count > 0 else {
            return try ResponseJSON<Void>(status: .error, message: "请输入要查询的单词").encode(for: req)
        }

        // ~~ 模糊匹配。
        return Word.query(on: req).filter(\.word ~~ input).all().flatMap({ (words) in
            
            let futureWords = words.compactMap({ word -> Word in
                var w = word;w.id = nil;return w
            })
            return try ResponseJSON<[Word]>(data: futureWords).encode(for: req)
        })
    }
    
    //TODO: 成语查询
    func filterIdiom(_ req: Request) throws -> Future<Response> {
        
        guard let input = req.query[String.self, at: "str"],input.count > 0 else {
            return try ResponseJSON<Void>(status: .error, message: "请输入要查询的成语").encode(for: req)
        }
            
        return Idiom.query(on: req).filter(\.word ~~ input).all().flatMap({ (words) in
            
            let fultueWords = words.compactMap({ idiom -> Idiom in
                var w = idiom;w.id = nil;return w
            })
            return try ResponseJSON<[Idiom]>(data: fultueWords).encode(for: req)
        })
    }
    
    //TODO: 歇后语查询
    func filterXieHouIdiom(_ req: Request) throws -> Future<Response> {
        
        guard let input = req.query[String.self, at: "str"],input.count > 0 else {
            return try ResponseJSON<Void>(status: .error, message: "请输入要查询的歇后语").encode(for: req)
        }
        return XieHouIdiom.query(on: req).filter(\.riddle ~~ input).all().flatMap({ (oms) in
            
            let results = oms.compactMap({ idiom -> XieHouIdiom in
                var w = idiom;w.id = nil;return w
            })
            return try ResponseJSON<[XieHouIdiom]>(data: results).encode(for: req)
        })
    }
 
    
}
