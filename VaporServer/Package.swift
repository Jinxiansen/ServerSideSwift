// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "VaporServer",
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.0"),
        .package(url: "https://github.com/vapor/leaf.git", from: "3.0.0-rc"),
        .package(url: "https://github.com/vapor/fluent-mysql.git", from: "3.0.0-rc"),
        .package(url: "https://github.com/skelpo/APIErrorMiddleware.git", from: "0.1.0"),
        .package(url: "https://github.com/IBM-Swift/Swift-SMTP.git", from: "4.0.1"),
        
        // JWT Middleware to authenticate
        .package(url: "https://github.com/vapor/jwt.git", from: "3.0.0-rc"),
        .package(url: "https://github.com/skelpo/JWTMiddleware.git", from: "0.6.1"),
        
        .package(url: "https://github.com/vapor/multipart.git", from: "3.0.0"),
        
        .package(url: "https://github.com/vapor/auth.git", from: "2.0.0-rc"),
        .package(url: "https://github.com/vapor/crypto.git", from: "3.0.0"),
        .package(url: "https://github.com/vapor/console.git", from: "3.0.0"),
        
        .package(url: "https://github.com/vapor/redis.git", from: "3.0.0-rc"),
        ],
    targets: [
        .target(name: "App", dependencies: ["SwiftSMTP",
                                            "Leaf",
                                            "FluentMySQL",
                                            "Vapor",
                                            "JWTMiddleware",
                                            "JWT",
                                            "Multipart",
                                            "Authentication",
                                            "Crypto",
                                            "Logging",
                                            "Redis",
                                            "APIErrorMiddleware"
            ]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"])
    ]
)

