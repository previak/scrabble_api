import NIOSSL
import Fluent
import FluentPostgresDriver
import Vapor
import JWT


public func configure(_ app: Application) async throws {
    app.databases.use(DatabaseConfigurationFactory.postgres(configuration: .init(
        hostname: Environment.get("DATABASE_HOST") ?? "localhost",
        port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? SQLPostgresConfiguration.ianaPortNumber,
        username: Environment.get("DATABASE_USERNAME") ?? "vapor_username",
        password: Environment.get("DATABASE_PASSWORD") ?? "vapor_password",
        database: Environment.get("DATABASE_NAME") ?? "vapor_database",
        tls: .prefer(try .init(configuration: .clientDefault)))
    ), as: .psql)
    
    app.middleware.use(
        FileMiddleware(
            publicDirectory: app.directory.publicDirectory,
            defaultFile: "index.html"
        )
    )
    
    app.middleware.use(APIKeyMiddleware())
    app.middleware.use(JWTMiddleware())

    // TODO: key should be in a config file that doesnt go to git
    app.jwt.signers.use(.hs256(key: "8f93f7cdeb5cde828a37deb140ca1a3da0a470222599e7efbe9b5f4f5c1fe782"))
    
    app.migrations.add(AddRoomTable())
    app.migrations.add(AddGameTable())
    app.migrations.add(AddBoardTable())
    app.migrations.add(AddUserTable())
    app.migrations.add(AddPlayerTable())
    app.migrations.add(AddWordTable())
        
    try app.autoMigrate().wait()
    
    let boardRepository = BoardRepositoryImpl()
    let gameRepository = GameRepositoryImpl()
    let playerRepository = PlayerRepositoryImpl()
    let roomRepository = RoomRepositoryImpl()
    let userRepository = UserRepositoryImpl()
    let wordRepository = WordRepositoryImpl()
    
    let boardService = BoardServiceImpl(boardRepository: boardRepository)
    let gameService = GameServiceImpl(gameRepository: gameRepository)
    let playerService = PlayerServiceImpl(playerRepository: playerRepository)
    let roomService = RoomServiceImpl(roomRepository: roomRepository, playerRepository: playerRepository)
    let userService = UserServiceImpl(userRepository: userRepository)
    let wordService = WordServiceImpl(wordRepository: wordRepository)
    
    try app.register(collection: BoardController(boardService: boardService))
    try app.register(collection: GameController(gameService: gameService))
    try app.register(collection: PlayerController(playerService: playerService))
    try app.register(collection: RoomController(roomService: roomService))
    try app.register(collection: UserController(userService: userService))
    try app.register(collection: WordController(wordService: wordService))
    
    // register routes
    try routes(app)
}
