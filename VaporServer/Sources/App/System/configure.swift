import FluentMySQL
import Vapor
import APIErrorMiddleware
import Leaf
import Authentication
import Fluent

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    /// Register providers first
    try services.register(FluentMySQLProvider())
    
    // Leaf
    try services.register(LeafProvider())
    config.prefer(LeafRenderer.self, for: ViewRenderer.self)
    
    // 认证
    services.register(DirectoryConfig.detect())
    try services.register(AuthenticationProvider())

    /// Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    /* * ** ** ** ** *** ** ** ** Middleware ** ** ** ** ** ** ** ** ** */
    var middlewares = MiddlewareConfig()
    
    middlewares.use(ExceptionMiddleware(closure: { (req) -> (EventLoopFuture<Response>?) in
        let dict = ["status":"404","message":"访问路径不存在"]
        return try dict.encode(for: req)
//        return try req.view().render("leaf/loader").encode(for: req)
    }))
    
    middlewares.use(ErrorMiddleware.self)
    // Serves files from `Public/` directory
    middlewares.use(FileMiddleware.self)
    
    //
    middlewares.use(PageViewMeddleware())
    
    middlewares.use(GuardianMiddleware(rate: Rate(limit: 20, interval: .minute), closure: { (req) -> EventLoopFuture<Response>? in
        let dict = ["status":"429","message":"访问太频繁"]
        return try dict.encode(for: req)
    }))
    
    services.register(middlewares)
    
    let dbConfig = MySQLConfig.sqlData(env)
    let sqlite = MySQLDatabaseConfig.init(hostname: dbConfig.hostname,
                                          port: dbConfig.port,
                                          username: dbConfig.username,
                                          password: dbConfig.password,
                                          database: dbConfig.database)
    services.register(sqlite)
    
    var migrations = MigrationConfig()
    
    /* * ** ** ** ** *** ** ** ** Models ** ** ** ** ** ** ** ** ** */
    migrations.add(model: LoginUser.self, database:.mysql)
    migrations.add(model: EmailSendResult.self, database: .mysql)
    
    migrations.add(model: PageView.self, database: .mysql)
    migrations.add(model: AccessToken.self, database: .mysql)
    migrations.add(model: RefreshToken.self, database: .mysql)
    migrations.add(model: Record.self, database: .mysql)
    
    migrations.add(model: Word.self, database: .mysql)
    migrations.add(model: Idiom.self, database: .mysql)
    migrations.add(model: XieHouIdiom.self, database: .mysql)
    migrations.add(model: Report.self, database: .mysql)
    
    
    services.register(migrations)
    

}









