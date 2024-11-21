// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "ScrabbleAPI",
    platforms: [
       .macOS(.v13)
    ],
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "4.70.0"),
        // 🗄 An ORM for SQL and NoSQL databases.
        .package(url: "https://github.com/vapor/fluent.git", from: "4.5.0"),
        // 🐘 Fluent driver for Postgres.
        .package(url: "https://github.com/vapor/fluent-postgres-driver.git", from: "2.6.0"),
        // 🔵 Non-blocking, event-driven networking for Swift.
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.42.0"),
        // 🔒 JWT for authorization.
        .package(url: "https://github.com/vapor/jwt.git", from: "4.2.0"),
        // 📄 Generate OpenAPI documentation for Vapor applications.
        .package(url: "https://github.com/dankinsoid/VaporToOpenAPI.git", from: "4.4.0")
    ],

    targets: [
        .executableTarget(
            name: "App",
            dependencies: [
                .product(name: "Fluent", package: "fluent"),
                .product(name: "FluentPostgresDriver", package: "fluent-postgres-driver"),
                .product(name: "Vapor", package: "vapor"),
                .product(name: "NIOCore", package: "swift-nio"),
                .product(name: "NIOPosix", package: "swift-nio"),
                .product(name: "JWT", package: "jwt"),
                .product(name: "VaporToOpenAPI", package: "VaporToOpenAPI")
            ],
            resources: [
                .copy("Resources/StartingBoard.json"),
                .copy("Resources/Swagger")
            ],
            swiftSettings: swiftSettings
        ),
        .testTarget(
            name: "AppTests",
            dependencies: [
                .target(name: "App"),
                .product(name: "XCTVapor", package: "vapor"),
            ],
            swiftSettings: swiftSettings
        )
    ],
    swiftLanguageModes: [.v5]
)

var swiftSettings: [SwiftSetting] { [
    .enableUpcomingFeature("DisableOutwardActorInference"),
    .enableExperimentalFeature("StrictConcurrency"),
] }
