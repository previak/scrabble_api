import XCTVapor
@testable import App
import Vapor

// MARK: - Mock Test Player Repository
final class MockTestPlayerRepository: PlayerRepository {
    func findByNicknameAndRoomId(nickname: String, roomId: UUID, on req: Vapor.Request) -> NIOCore.EventLoopFuture<App.Player?> {
        return findByNicknameAndRoomId(nickname: nickname, roomId: UUID(), on: req)
    }
    
    func findByUserId(userId: UUID, on req: Vapor.Request) -> NIOCore.EventLoopFuture<App.Player?> {
        return findByUserId(userId: UUID(), on: req)
    }
    
    func findByRoomId(roomId: UUID, on req: Vapor.Request) -> NIOCore.EventLoopFuture<[App.Player]> {
        return findByRoomId(roomId: UUID(), on: req)
    }
    
    var players: [UUID: Player] = [:]

    func find(id: UUID, on req: Request) -> EventLoopFuture<Player?> {
        return req.eventLoop.future(players[id])
    }

    func create(createRequest: CreatePlayerRequest, on req: Request) -> EventLoopFuture<Player> {
        let player = Player(
            id: UUID(),
            userID: createRequest.userId,
            roomID: createRequest.roomId,
            nickname: createRequest.nickname,
            score: 0,
            turnOrder: 1,
            availableLetters: "A,B,C"
        )
        players[player.id!] = player
        return req.eventLoop.future(player)
    }

    func update(player: Player, on req: Request) -> EventLoopFuture<Player> {
        players[player.id!] = player
        return req.eventLoop.future(player)
    }

    func delete(id: UUID, on req: Request) -> EventLoopFuture<Void> {
        players.removeValue(forKey: id)
        return req.eventLoop.future()
    }
}

// MARK: - Test Class
final class PlayerServiceImplTests: XCTestCase {
    private var app: Application!
    private var mockPlayerRepository: MockTestPlayerRepository!
    private var playerService: PlayerServiceImpl!

    override func setUp() {
        super.setUp()
        app = Application(.testing)
        mockPlayerRepository = MockTestPlayerRepository()
        playerService = PlayerServiceImpl(playerRepository: mockPlayerRepository)
    }

    override func tearDown() {
        mockPlayerRepository = nil 
        playerService = nil
        app.shutdown()
        super.tearDown()
    }

    // Успешное получение игрока
    /*func testGetPlayer_Success() throws {
        let playerId = UUID()
        let player = Player(
            id: playerId,
            userID: UUID(),
            roomID: UUID(),
            nickname: "TestPlayer",
            score: 100,
            turnOrder: 1,
            availableLetters: "A,B,C"
        )
        mockPlayerRepository.players[playerId] = player

        let req = Request(application: app, on: app.eventLoopGroup.next())
        let futureResult = playerService.getPlayer(id: playerId, on: req)
        let result = try futureResult.wait()

        XCTAssertEqual(result.id, playerId)
        XCTAssertEqual(result.nickname, "TestPlayer")
        XCTAssertEqual(result.score, 100)
        XCTAssertEqual(result.availableLetters, "A,B,C")
    }*/

    // Ошибка: игрок не найден
    func testGetPlayer_NotFound() throws {
        let playerId = UUID()
        let req = Request(application: app, on: app.eventLoopGroup.next())
        let futureResult = playerService.getPlayer(id: playerId, on: req)
        XCTAssertThrowsError(try futureResult.wait()) { error in
            XCTAssertTrue(error is Abort)
            XCTAssertEqual((error as? Abort)?.status, .notFound)
        }
    }

    // Успешное удаление игрока
    func testDeletePlayer_Success() throws {
        let playerId = UUID()
        let player = Player(
            id: playerId,
            userID: UUID(),
            roomID: UUID(),
            nickname: "DeleteMe",
            score: 0,
            turnOrder: 2,
            availableLetters: "D,E,F"
        )
        mockPlayerRepository.players[playerId] = player

        let req = Request(application: app, on: app.eventLoopGroup.next())

        let futureResult = playerService.deletePlayer(id: playerId, on: req)
        try futureResult.wait()

        XCTAssertNil(mockPlayerRepository.players[playerId])
    }
}
