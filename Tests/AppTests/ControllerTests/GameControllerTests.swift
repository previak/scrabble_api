import XCTest
import Vapor
import Fluent
@testable import App

// Моковый объект сервиса для тестирования запросов контроллера
final class MockGameService: GameService {
    var getGameClosure: ((UUID, Request) -> EventLoopFuture<GameDTO>)?
    var createGameClosure: ((GameDTO, Request) -> EventLoopFuture<GameDTO>)?
    var updateGameClosure: ((GameDTO, Request) -> EventLoopFuture<GameDTO>)?
    var deleteGameClosure: ((UUID, Request) -> EventLoopFuture<Void>)?

    func getGame(id: UUID, on req: Request) -> EventLoopFuture<GameDTO> {
        return getGameClosure!(id, req)
    }

    func createGame(game: GameDTO, on req: Request) -> EventLoopFuture<GameDTO> {
        return createGameClosure!(game, req)
    }

    func updateGame(game: GameDTO, on req: Request) -> EventLoopFuture<GameDTO> {
        return updateGameClosure!(game, req)
    }

    func deleteGame(id: UUID, on req: Request) -> EventLoopFuture<Void> {
        return deleteGameClosure!(id, req)
    }
}

final class GameControllerTests: XCTestCase {
    var app: Application!
    var mockGameService: MockGameService!
    var gameController: GameController!
    
    override func setUp() {
        super.setUp()
        app = Application(.testing)
        mockGameService = MockGameService()
        gameController = GameController(gameService: mockGameService)
    }
    
    override func tearDown() {
        app.shutdown()
        super.tearDown()
    }

    /// Тест для получения игры по ID
    func testGetGame() throws {
        let testGameID = UUID()
        let testRoomID = UUID()
        let testRoom = RoomDTO(id: testRoomID, isOpen: true, isPublic: true, invitationCode: "ABC123", gameState: .forming, admin: User(id: UUID(), username: "adminUser", passwordHash: "asd", apiKey: "sd"))
        let testGame = GameDTO(id: testGameID, room: testRoom, isPaused: false)
        
        mockGameService.getGameClosure = { id, _ in
            guard id == testGameID else { return self.app.eventLoopGroup.future(error: Abort(.notFound)) }
            return self.app.eventLoopGroup.future(testGame)
        }

        let req = Request(application: app, on: app.eventLoopGroup.next())
        req.parameters.set("id", to: testGameID.uuidString)
        
        let futureGame = try gameController.getGame(req: req)
        let game = try futureGame.wait()

        XCTAssertEqual(game.id, testGameID)
        XCTAssertEqual(game.room.id, testRoomID)
        XCTAssertEqual(game.room.invitationCode, "ABC123")
        XCTAssertEqual(game.isPaused, false)
    }

    /// Тест для создания новой игры
    func testCreateGame() throws {
        let testRoom = RoomDTO(id: UUID(), isOpen: true, isPublic: true, invitationCode: "XYZ456", gameState: .forming, admin: User(id: UUID(), username: "adminUser", passwordHash: "asd", apiKey: "sd"))
        let createGameRequest = GameDTO(id: nil, room: testRoom, isPaused: false)
        
        let createdGame = GameDTO(id: UUID(), room: testRoom, isPaused: false)

        mockGameService.createGameClosure = { game, _ in
            return self.app.eventLoopGroup.future(createdGame)
        }

        let req = Request(application: app, method: .POST, url: URI(path: "/games"), on: app.eventLoopGroup.next())
        try req.content.encode(createGameRequest, as: .json)

        let futureGame = try gameController.createGame(req: req)
        let game = try futureGame.wait()

        XCTAssertNotNil(game.id)
        XCTAssertEqual(game.room.invitationCode, "XYZ456")
        XCTAssertEqual(game.isPaused, false)
    }
    
    /// Тест для обновления существующей игры
    func testUpdateGame() throws {
        let testGameID = UUID()
        let testRoom = RoomDTO(id: UUID(), isOpen: false, isPublic: false, invitationCode: "NEW456", gameState: .playing, admin: User(id: UUID(), username: "adminUser", passwordHash: "asd", apiKey: "sd"))
        let updateGameRequest = GameDTO(id: testGameID, room: testRoom, isPaused: true)
  
        mockGameService.updateGameClosure = { game, _ in
            return self.app.eventLoopGroup.future(updateGameRequest)
        }

        let req = Request(application: app, method: .PUT, url: URI(path: "/games/\(testGameID.uuidString)"), on: app.eventLoopGroup.next())
        try req.content.encode(updateGameRequest, as: .json)
        req.parameters.set("id", to: testGameID.uuidString)

        let futureGame = try gameController.updateGame(req: req)
        let game = try futureGame.wait()

        XCTAssertEqual(game.id, testGameID)
        XCTAssertEqual(game.room.invitationCode, "NEW456")
        XCTAssertEqual(game.isPaused, true)
    }

    /// Тест для удаления игры по ID
    func testDeleteGame() throws {
        let testGameID = UUID()

        mockGameService.deleteGameClosure = { id, _ in
            guard id == testGameID else { return self.app.eventLoopGroup.future(error: Abort(.notFound)) }
            return self.app.eventLoopGroup.future()
        }

        let req = Request(application: app, on: app.eventLoopGroup.next())
        req.parameters.set("id", to: testGameID.uuidString)
        
        let futureResponse = try gameController.deleteGame(req: req)
        let response = try futureResponse.wait()

        XCTAssertEqual(response, .noContent)
    }
}
