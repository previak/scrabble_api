import XCTVapor
@testable import App
import Vapor


// MARK: - Mock GameRepository
final class MockGameRepository: GameRepository {
    func findByRoomId(roomId: UUID, on req: Vapor.Request) -> NIOCore.EventLoopFuture<App.Game?> {
        return findByRoomId(roomId: UUID(), on: req)
    }
    
    func deleteByRoomId(roomId: UUID, on req: Vapor.Request) -> NIOCore.EventLoopFuture<Void> {
        return delete(id: UUID(), on: req)
    }
    
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
    private var mockBoardRepository: MockBoardRepository!
    private var mockRoomRepository: MockRoomRepository!
    private var mockGameRepository: MockGameRepository!
    private var mockPlayerRepository: MockPlayerRepository!
    private var gameService: GameServiceImpl!
    private var boardService: BoardService!

    override func setUp() {
        super.setUp()
        app = Application(.testing)
        mockRoomRepository = MockRoomRepository()
        mockGameRepository = MockGameRepository()
        mockPlayerRepository = MockPlayerRepository()
        mockBoardRepository = MockBoardRepository()
        gameService = GameServiceImpl(gameRepository: mockGameRepository, playerRepository: mockPlayerRepository, roomRepository: mockRoomRepository, boardService: boardService, boardRepository: mockBoardRepository)
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
    /*func testGetGame_Success() throws {
        let roomId = UUID()
        let room = Room()
        mockRoomRepository.rooms[roomId] = room

        let gameId = UUID()
        let game = Game(id: gameId, roomID: roomId, isPaused: false, remainingLetters: "sdf")
        mockGameRepository.games[gameId] = game

        let req = Request(application: app, on: app.eventLoopGroup.next())

        let futureResult = gameService.getGame(id: gameId, on: req)
        let result = try futureResult.wait()

        XCTAssertEqual(result.id, gameId)
        XCTAssertEqual(result.room.id, roomId)
        XCTAssertEqual(result.isPaused, false)
    }*/

    /// Ошибка: игра не найдена
    /*func testGetGame_NotFound() throws {
        let gameId = UUID()
        let req = Request(application: app, on: app.eventLoopGroup.next())

        let futureResult = gameService.getGame(id: gameId, on: req)

        XCTAssertThrowsError(try futureResult.wait()) { error in
            XCTAssertTrue(error is Abort)
            XCTAssertEqual((error as? Abort)?.status, .notFound)
        }
    }*/

    /// Успешное создание игры
    /*func testCreateGame_Success() throws {
        let roomId = UUID()
        let room = Room()
        mockRoomRepository.rooms[roomId] = room

        let gameDTO = GameDTO(id: nil, room: room.toDTO(), isPaused: false, remainingLetters: "asd")
        let req = Request(application: app, on: app.eventLoopGroup.next())

        let futureResult = gameService.createGame(game: gameDTO, on: req)
        let result = try futureResult.wait()

        XCTAssertNotNil(result.id)
        XCTAssertEqual(result.room.id, roomId)
        XCTAssertEqual(result.isPaused, false)

        let createdGame = mockGameRepository.games[result.id!]
        XCTAssertNotNil(createdGame)
        XCTAssertEqual(createdGame?.$room.id, roomId)
        XCTAssertEqual(createdGame?.isPaused, false)
    }*/

    /// Успешное обновление игры
    /*func testUpdateGame_Success() throws {
        let roomId = UUID()
        let room = Room()
        mockRoomRepository.rooms[roomId] = room

        let gameId = UUID()
        let originalGame = Game(id: gameId, roomID: roomId, isPaused: false, remainingLetters: "sdf")
        originalGame.$room.id = roomId
        mockGameRepository.games[gameId] = originalGame

        let updatedGameDTO = GameDTO(id: gameId, room: room.toDTO(), isPaused: true, remainingLetters: "sdf")
        let req = Request(application: app, on: app.eventLoopGroup.next())

        let futureResult = gameService.updateGame(game: updatedGameDTO, on: req)
        let result = try futureResult.wait()

        XCTAssertEqual(result.id, gameId)
        XCTAssertEqual(result.room.id, roomId)
        XCTAssertEqual(result.isPaused, true)

        let updatedGame = mockGameRepository.games[gameId]
        XCTAssertNotNil(updatedGame)
        XCTAssertEqual(updatedGame?.isPaused, true)
    }*/
    
    /// Успешный выход из игры
    /*func testLeaveGame_Success() throws {
        let userId = UUID()
        let gameId = UUID()

        let room = Room()
        let game = Game(id: gameId, roomID: room.id!, isPaused: false, remainingLetters: "lwko")
        mockGameRepository.games[gameId] = game

        let leaveGameRequest = LeaveGameRequestModel(userId: userId)
        let req = Request(application: app, on: app.eventLoopGroup.next())

        let futureResult = gameService.leaveGame(leaveGameRequest: leaveGameRequest, on: req)
        let result = try futureResult.wait()

        XCTAssertNil(mockGameRepository.games[gameId])
        XCTAssertEqual(result.playerCount, 0)
    }*/

    /// Ошибка: Игра не найдена
    /*func testLeaveGame_GameNotFound() throws {
        let userId = UUID()

        let leaveGameRequest = LeaveGameRequestModel(userId: userId)
        let req = Request(application: app, on: app.eventLoopGroup.next())

        let futureResult = gameService.leaveGame(leaveGameRequest: leaveGameRequest, on: req)

        XCTAssertThrowsError(try futureResult.wait()) { error in
            XCTAssertTrue(error is Abort)
            XCTAssertEqual((error as? Abort)?.status, .notFound)
        }
    }*/
}
