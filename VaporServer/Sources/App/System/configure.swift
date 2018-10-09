import Vapor
import APIErrorMiddleware
import Leaf
import Authentication
import FluentPostgreSQL

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    
    // Leaf
    try services.register(LeafProvider())
    config.prefer(LeafRenderer.self, for: ViewRenderer.self)
    
    var commands = CommandConfig.default()
    commands.useFluentCommands()
    services.register(commands)
    
    // 认证
    services.register(DirectoryConfig.detect())
    try services.register(AuthenticationProvider())
    
    /// Register routes to the router
    
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    /* * ** ** ** ** *** ** ** ** Middleware ** ** ** ** ** ** ** ** ** */
    var middlewares = MiddlewareConfig()
    
    middlewares.use(LocalHostMiddleware())
    
    middlewares.use(APIErrorMiddleware.init(environment: env, specializations: [
        ModelNotFound()
    ]))
    
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
    
    /* * ** ** ** ** *** ** ** ** SQL ** ** ** ** ** ** ** ** ** */
    try services.register(FluentPostgreSQLProvider())
    let pgSQL = PostgreSQLDatabaseConfig.loadSQLConfig(env)
    services.register(pgSQL)
    
    /* * ** ** ** ** *** ** ** ** 𝐌odels ** ** ** ** ** ** ** ** ** */
    var migrations = MigrationConfig()
    
    migrations.setupModels()
    
    services.register(migrations)
    

}









