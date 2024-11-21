import XCTest
import Vapor
import Foundation
@testable import App


final class MockPlayerService: PlayerService {
    var getPlayerClosure: ((UUID, Request) -> EventLoopFuture<PlayerDTO>)?
    var createPlayerClosure: ((CreatePlayerRequestModel, Request) -> EventLoopFuture<PlayerDTO>)?
    var updatePlayerClosure: ((PlayerDTO, Request) -> EventLoopFuture<PlayerDTO>)?
    var deletePlayerClosure: ((UUID, Request) -> EventLoopFuture<Void>)?

    func getPlayer(id: UUID, on req: Request) -> EventLoopFuture<PlayerDTO> {
        return getPlayerClosure!(id, req)
    }

    func createPlayer(createRequest: CreatePlayerRequestModel, on req: Request) -> EventLoopFuture<PlayerDTO> {
        return createPlayerClosure!(createRequest, req)
    }

    func updatePlayer(player: PlayerDTO, on req: Request) -> EventLoopFuture<PlayerDTO> {
        return updatePlayerClosure!(player, req)
    }

    func deletePlayer(id: UUID, on req: Request) -> EventLoopFuture<Void> {
        return deletePlayerClosure!(id, req)
    }
}

final class PlayerControllerTests: XCTestCase {
    var app: Application!
    var mockPlayerService: MockPlayerService!
    var playerController: PlayerController!
    
    override func setUp() {
        super.setUp()
        app = Application(.testing)
        mockPlayerService = MockPlayerService()
        playerController = PlayerController(playerService: mockPlayerService)
    }
    
    override func tearDown() {
        app.shutdown()
        super.tearDown()
    }

    // Тест получения игрока по ID
    func testGetPlayerSuccess() throws {
        let testPlayerID = UUID()

        let testAdmin = UserDTO(id: UUID(), username: "testAdmin", passwordHash: "hashed_password", apiKey: "test_api_key")
        
        let testRoom = RoomDTO(id: UUID(), isOpen: true, isPublic: true, invitationCode: "ABC123", gameState: .forming, admin: testAdmin.toModel())
        
        let testUser = UserDTO(id: UUID(), username: "testUser", passwordHash: "hash123", apiKey: "apiKey")
        
        let testPlayerDTO = PlayerDTO(
            id: testPlayerID,
            user: testUser,
            room: testRoom,
            nickname: "Player1",
            score: 100,
            turnOrder: 1,
            availableLetters: "ABCDE"
        )
        
        mockPlayerService.getPlayerClosure = { id, _ in
            guard id == testPlayerID else { return self.app.eventLoopGroup.future(error: Abort(.notFound)) }
            return self.app.eventLoopGroup.future(testPlayerDTO)
        }

        let req = Request(application: app, on: app.eventLoopGroup.next())
        req.parameters.set("id", to: testPlayerID.uuidString)
 
        let futurePlayer = try playerController.getPlayer(req: req)
        let player = try futurePlayer.wait()

        XCTAssertEqual(player.id, testPlayerID)
        XCTAssertEqual(player.nickname, "Player1")
        XCTAssertEqual(player.score, 100)
        XCTAssertEqual(player.turnOrder, 1)
        XCTAssertEqual(player.availableLetters, "ABCDE")
        XCTAssertEqual(player.user.username, "testUser")
        XCTAssertEqual(player.room.invitationCode, "ABC123")
        XCTAssertEqual(player.room.admin.username, "testAdmin")
    }

    // Тест обновления игрока
    func testUpdatePlayerSuccess() throws {
        let testPlayerID = UUID()

        let updatedAdmin = UserDTO(id: UUID(), username: "adminUpdated", passwordHash: "new_hashed_password", apiKey: "new_api_key")
        let updatedRoom = RoomDTO(id: UUID(), isOpen: false, isPublic: false, invitationCode: "XYZ789", gameState: .playing, admin: updatedAdmin.toModel())
        let updatedUser = UserDTO(id: UUID(), username: "updatedUser", passwordHash: "new_hash", apiKey: "newApiKey")
        
        let updatedPlayerDTO = PlayerDTO(
            id: testPlayerID,
            user: updatedUser,
            room: updatedRoom,
            nickname: "UpdatedPlayer",
            score: 200,
            turnOrder: 2,
            availableLetters: "XYZ"
        )
        
        mockPlayerService.updatePlayerClosure = { player, _ in
            return self.app.eventLoopGroup.future(updatedPlayerDTO)
        }

        let req = Request(application: app, method: .PUT, url: URI(path: "/players/\(testPlayerID.uuidString)"), on: app.eventLoopGroup.next())
        try req.content.encode(updatedPlayerDTO, as: .json)
        req.parameters.set("id", to: testPlayerID.uuidString)
        
        let futurePlayer = try playerController.updatePlayer(req: req)
        let player = try futurePlayer.wait()

        XCTAssertEqual(player.id, testPlayerID)
        XCTAssertEqual(player.nickname, "UpdatedPlayer")
        XCTAssertEqual(player.score, 200)
        XCTAssertEqual(player.turnOrder, 2)
        XCTAssertEqual(player.availableLetters, "XYZ")
        XCTAssertEqual(player.user.username, "updatedUser")
        XCTAssertEqual(player.room.invitationCode, "XYZ789")
        XCTAssertEqual(player.room.admin.username, "adminUpdated")
    }
    
    // Тест удаления игрока
    func testDeletePlayerSuccess() throws {
        let testPlayerID = UUID()

        mockPlayerService.deletePlayerClosure = { id, _ in
            guard id == testPlayerID else { return self.app.eventLoopGroup.future(error: Abort(.notFound)) }
            return self.app.eventLoopGroup.future()
        }

        let req = Request(application: app, on: app.eventLoopGroup.next())
        req.parameters.set("id", to: testPlayerID.uuidString)

        let futureResponse = try playerController.deletePlayer(req: req)
        let response = try futureResponse.wait()

        XCTAssertEqual(response, .noContent)
    }

    // Тест получения игрока с ошибкой (404)
    func testGetPlayerNotFound() throws {
        let testPlayerID = UUID()

        mockPlayerService.getPlayerClosure = { id, _ in
            return self.app.eventLoopGroup.future(error: Abort(.notFound))
        }

        let req = Request(application: app, on: app.eventLoopGroup.next())
        req.parameters.set("id", to: testPlayerID.uuidString)

        // Then: Ожидаем 404 ошибку
        XCTAssertThrowsError(try playerController.getPlayer(req: req).wait()) { error in
            XCTAssertEqual((error as? Abort)?.status, .notFound)
        }
    }

    // Тест удаления несуществующего игрока
    func testDeletePlayerNotFound() throws {
        let testPlayerID = UUID()

        mockPlayerService.deletePlayerClosure = { id, _ in
            return self.app.eventLoopGroup.future(error: Abort(.notFound))
        }

        let req = Request(application: app, on: app.eventLoopGroup.next())
        req.parameters.set("id", to: testPlayerID.uuidString)

        XCTAssertThrowsError(try playerController.deletePlayer(req: req).wait()) { error in
            XCTAssertEqual((error as? Abort)?.status, .notFound)
        }
    }
}
