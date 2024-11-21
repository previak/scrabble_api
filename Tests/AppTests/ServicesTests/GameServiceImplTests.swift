import XCTVapor
@testable import App // Замените YourModuleName на имя вашего модуля
import Vapor

// MARK: - Mock RoomRepository
/*final class MockRoomRepository: RoomRepository {
    func create(createRequest: App.CreateRoomRequest, on req: Vapor.Request) -> NIOCore.EventLoopFuture<App.Room> {
        <#code#>
    }
    
    func update(room: App.Room, on req: Vapor.Request) -> NIOCore.EventLoopFuture<App.Room> {
        <#code#>
    }
    
    func delete(id: UUID, on req: Vapor.Request) -> NIOCore.EventLoopFuture<Void> {
        <#code#>
    }
    
    var rooms: [UUID: Room] = [:]
    var findByInvitationCodeHandler: ((String) -> Room?)?

    func find(id: UUID, on req: Request) -> EventLoopFuture<Room?> {
        return req.eventLoop.makeSucceededFuture(rooms[id])
    }

    func find(invitationCode: String, on req: Request) -> EventLoopFuture<Room?> {
        let room = findByInvitationCodeHandler?(invitationCode)
        return req.eventLoop.makeSucceededFuture(room)
    }
}*/

// MARK: - Mock GameRepository
final class MockGameRepository: GameRepository {
    func delete(id: UUID, on req: Vapor.Request) -> NIOCore.EventLoopFuture<Void> {
        return delete(id: id, on: req)
    }
    
    var games: [UUID: Game] = [:]

    func find(id: UUID, on req: Request) -> EventLoopFuture<Game?> {
        return req.eventLoop.makeSucceededFuture(games[id])
    }

    func create(game: Game, on req: Request) -> EventLoopFuture<Game> {
        games[game.id!] = game
        return req.eventLoop.makeSucceededFuture(game)
    }

    func update(game: Game, on req: Request) -> EventLoopFuture<Game> {
        games[game.id!] = game
        return req.eventLoop.makeSucceededFuture(game)
    }
}

// MARK: - Test Class
final class GameServiceImplTests: XCTestCase {
    private var app: Application!
    private var mockRoomRepository: MockRoomRepository!
    private var mockGameRepository: MockGameRepository!
    private var gameService: GameServiceImpl!

    override func setUp() {
        super.setUp()
        app = Application(.testing)
        mockRoomRepository = MockRoomRepository()
        mockGameRepository = MockGameRepository()
        gameService = GameServiceImpl(gameRepository: mockGameRepository)
    }

    override func tearDown() {
        mockRoomRepository = nil
        mockGameRepository = nil
        gameService = nil
        app.shutdown()
        super.tearDown()
    }

    // MARK: - Test Cases

    /// Успешное получение игры
    func testGetGame_Success() throws {
        let roomId = UUID()
        let room = Room() // Используем конструктор
        mockRoomRepository.rooms[roomId] = room

        let gameId = UUID()
        let game = Game(id: gameId, roomID: roomId, isPaused: false)
        mockGameRepository.games[gameId] = game

        let req = Request(application: app, on: app.eventLoopGroup.next())

        let futureResult = gameService.getGame(id: gameId, on: req)
        let result = try futureResult.wait()

        XCTAssertEqual(result.id, gameId)
        XCTAssertEqual(result.room.id, roomId)
        XCTAssertEqual(result.isPaused, false)
    }

    /// Ошибка: игра не найдена
    func testGetGame_NotFound() throws {
        let gameId = UUID()
        let req = Request(application: app, on: app.eventLoopGroup.next())

        let futureResult = gameService.getGame(id: gameId, on: req)

        XCTAssertThrowsError(try futureResult.wait()) { error in
            XCTAssertTrue(error is Abort)
            XCTAssertEqual((error as? Abort)?.status, .notFound)
        }
    }

    /// Успешное создание игры
    func testCreateGame_Success() throws {
        let roomId = UUID()
        let room = Room()
        mockRoomRepository.rooms[roomId] = room

        let gameDTO = GameDTO(id: nil, room: room.toDTO(), isPaused: false)
        let req = Request(application: app, on: app.eventLoopGroup.next())

        let futureResult = gameService.createGame(game: gameDTO, on: req)
        let result = try futureResult.wait()

        XCTAssertNotNil(result.id)
        XCTAssertEqual(result.room.id, roomId)
        XCTAssertEqual(result.isPaused, false)

        let createdGame = mockGameRepository.games[result.id!]
        XCTAssertNotNil(createdGame)
        XCTAssertEqual(createdGame?.room.id, roomId)
        XCTAssertEqual(createdGame?.isPaused, false)
    }

    /// Успешное обновление игры
    func testUpdateGame_Success() throws {
        let roomId = UUID()
        let room = Room()
        mockRoomRepository.rooms[roomId] = room

        let gameId = UUID()
        let originalGame = Game(id: gameId, roomID: roomId, isPaused: false)
        mockGameRepository.games[gameId] = originalGame

        let updatedGameDTO = GameDTO(id: gameId, room: room.toDTO(), isPaused: true)
        let req = Request(application: app, on: app.eventLoopGroup.next())

        let futureResult = gameService.updateGame(game: updatedGameDTO, on: req)
        let result = try futureResult.wait()

        XCTAssertEqual(result.id, gameId)
        XCTAssertEqual(result.room.id, roomId)
        XCTAssertEqual(result.isPaused, true)

        let updatedGame = mockGameRepository.games[gameId]
        XCTAssertNotNil(updatedGame)
        XCTAssertEqual(updatedGame?.isPaused, true)
    }
}
