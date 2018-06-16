import FluentMySQL
import Vapor
import APIErrorMiddleware
import Leaf
import Authentication


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
    middlewares.use(APIErrorMiddleware.init(environment: env, specializations: [
        ModelNotFound()
    ]))
    
    middlewares.use(ExceptionMiddleware(closure: { (req) -> (EventLoopFuture<Response>?) in
        
        return try req.view().render("leaf/loader").encode(for: req)
    }))
    
    middlewares.use(ErrorMiddleware.self)
    // Serves files from `Public/` directory
    middlewares.use(FileMiddleware.self)
    
    //
    middlewares.use(PageViewMeddleware())
    
    middlewares.use(GuardianMiddleware(rate: Rate(limit: 25, interval: .minute), closure: { (req) -> EventLoopFuture<Response>? in
        let view = try req.view().render("leaf/loader")
        return try view.encode(for: req)
    }))
    
    services.register(middlewares)
    
    let db = env.isRelease ? "vaporDB":"vaporDebugDB"
    let sqlite = MySQLDatabaseConfig.init(hostname: "localhost",
                                          port: 3306,
                                          username: "sqluser",
                                          password: "qwer1234",
                                          database: db)
    services.register(sqlite)
    
    PrintLogger().info("启动数据库：\(db) \n")
    
    var migrations = MigrationConfig()
    
    /* * ** ** ** ** *** ** ** ** Models ** ** ** ** ** ** ** ** ** */
    migrations.add(model: LoginUser.self, database:.mysql)
    migrations.add(model: EmailSendResult.self, database: .mysql)
    
    migrations.add(model: PageView.self, database: .mysql)
    migrations.add(model: AccessToken.self, database: .mysql)
    migrations.add(model: RefreshToken.self, database: .mysql)
    migrations.add(model: UserRecord.self, database: .mysql)
    
    migrations.add(model: Word.self, database: .mysql)
    migrations.add(model: Idiom.self, database: .mysql)
    migrations.add(model: XieHouIdiom.self, database: .mysql)
    migrations.add(model: Report.self, database: .mysql)
    
    services.register(migrations)
    

}









