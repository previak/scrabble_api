import XCTest
import XCTVapor
@testable import App
import Vapor

final class PlayerControllerTests: XCTestCase {
    var app: Application!
    var mockPlayerService: MockPlayerService!
    var playerController: PlayerController!

    override func setUp() {
        super.setUp()
        app = Application(.testing)
        mockPlayerService = MockPlayerService()
        playerController = PlayerController(playerService: mockPlayerService)

        // Регистрируем маршруты
        let routes = app.routes
        try? playerController.boot(routes: routes)
    }

    override func tearDown() {
        app.shutdown()
        super.tearDown()
    }

    // MARK: - Тест для получения очков игрока
    func testGetPlayerScoreSuccess() throws {
        // Arrange
        let playerId = UUID()
        let requestDTO = GetPlayerScoreRequestDTO(playerId: playerId)
        let expectedResponseDTO = GetPlayerScoreResponseDTO(score: 100)

        mockPlayerService.getPlayerScoreClosure = { request, req in
            XCTAssertEqual(request.playerId, playerId)
            return req.eventLoop.future(GetPlayerScoreResponseModel(score: 100))
        }

        let req = Request(application: app, method: .GET, url: URI(path: "/players/score"), on: app.eventLoopGroup.next())
        try req.content.encode(requestDTO, as: .json)

        // Act
        let futureResponse = try playerController.getPlayerScore(req: req)
        let response = try futureResponse.wait()

        // Assert
        XCTAssertEqual(response.score, expectedResponseDTO.score, "Баллы игрока должны совпадать")
    }

    func testGetPlayerScoreNotFound() throws {
        // Arrange
        let playerId = UUID()
        let requestDTO = GetPlayerScoreRequestDTO(playerId: playerId)

        mockPlayerService.getPlayerScoreClosure = { _, req in
            return req.eventLoop.future(error: Abort(.notFound, reason: "Player not found"))
        }

        let req = Request(application: app, method: .GET, url: URI(path: "/players/score"), on: app.eventLoopGroup.next())
        try req.content.encode(requestDTO, as: .json)

        // Act & Assert
        XCTAssertThrowsError(try playerController.getPlayerScore(req: req).wait()) { error in
            XCTAssertTrue(error is Abort)
            XCTAssertEqual((error as? Abort)?.status, .notFound, "Ошибка должна быть 404 Not Found")
        }
    }
}

// MARK: - MockPlayerService
final class MockPlayerService: PlayerService {
    func getPlayerTiles(getPlayerTilesRequest: App.GetPlayerTilesRequestModel, on req: Vapor.Request) -> NIOCore.EventLoopFuture<App.GetPlayerTilesResponseModel> {
        return getPlayerTiles(getPlayerTilesRequest: getPlayerTilesRequest, on: req)
    }
    
    func getPlayerTiles(id: UUID, on req: Vapor.Request) -> NIOCore.EventLoopFuture<String> {
        return getPlayerTiles(id: id, on: req)
    }
    
    func getPlayer(id: UUID, on req: Vapor.Request) -> NIOCore.EventLoopFuture<App.PlayerDTO> {
        return getPlayer(id: id, on: req)
    }
    
    func createPlayer(createRequest: App.CreatePlayerRequestModel, on req: Vapor.Request) -> NIOCore.EventLoopFuture<App.PlayerDTO> {
        return createPlayer(createRequest: createRequest, on: req)
    }
    
    func updatePlayer(player: App.PlayerDTO, on req: Vapor.Request) -> NIOCore.EventLoopFuture<App.PlayerDTO> {
        return updatePlayer(player: player, on: req)
    }
    
    func deletePlayer(id: UUID, on req: Vapor.Request) -> NIOCore.EventLoopFuture<Void> {
        return deletePlayer(id: id, on: req)
    }
    
    var getPlayerScoreClosure: ((GetPlayerScoreRequestModel, Request) -> EventLoopFuture<GetPlayerScoreResponseModel>)?

    func getPlayerScore(getPlayerScoreRequest: GetPlayerScoreRequestModel, on req: Request) -> EventLoopFuture<GetPlayerScoreResponseModel> {
        return getPlayerScoreClosure!(getPlayerScoreRequest, req)
    }
}
