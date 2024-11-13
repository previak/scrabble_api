import NIOSSL
import Fluent
import FluentPostgresDriver
import Vapor


public func configure(_ app: Application) async throws {
    app.databases.use(DatabaseConfigurationFactory.postgres(configuration: .init(
        hostname: Environment.get("DATABASE_HOST") ?? "localhost",
        port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? SQLPostgresConfiguration.ianaPortNumber,
        username: Environment.get("DATABASE_USERNAME") ?? "vapor_username",
        password: Environment.get("DATABASE_PASSWORD") ?? "vapor_password",
        database: Environment.get("DATABASE_NAME") ?? "vapor_database",
        tls: .prefer(try .init(configuration: .clientDefault)))
    ), as: .psql)
    
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
    let roomService = RoomServiceImpl(roomRepository: roomRepository)
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
