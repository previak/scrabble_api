import NIOSSL
import Fluent
import FluentPostgresDriver
import Vapor


public func configure(_ app: Application) async throws {
    // register services
    let boardService: BoardService = BoardServiceImpl()
    try app.register(collection: GameController(boardService: boardService))

    app.databases.use(DatabaseConfigurationFactory.postgres(configuration: .init(
        hostname: Environment.get("DATABASE_HOST") ?? "localhost",
        port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? SQLPostgresConfiguration.ianaPortNumber,
        username: Environment.get("DATABASE_USERNAME") ?? "vapor_username",
        password: Environment.get("DATABASE_PASSWORD") ?? "vapor_password",
        database: Environment.get("DATABASE_NAME") ?? "vapor_database",
        tls: .prefer(try .init(configuration: .clientDefault)))
    ), as: .psql)

    app.migrations.add(CreateTodo())
    // register routes
    try routes(app)
}
