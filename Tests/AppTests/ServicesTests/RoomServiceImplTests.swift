import XCTest
@testable import App // Подставьте имя вашего модуля
import Vapor

// MARK: - Mock RoomRepository
final class MockRoomRepository: RoomRepository {
    var rooms: [UUID: Room] = [:]
    var findByInvitationCodeHandler: ((String) -> Room?)?

    func find(id: UUID, on req: Request) -> EventLoopFuture<Room?> {
        return req.eventLoop.makeSucceededFuture(rooms[id])
    }

    func find(invitationCode: String, on req: Request) -> EventLoopFuture<Room?> {
        let room = findByInvitationCodeHandler?(invitationCode)
        return req.eventLoop.makeSucceededFuture(room)
    }

    func create(createRequest: CreateRoomRequest, on req: Request) -> EventLoopFuture<Room> {
        let room = Room(
            id: UUID(),
            isOpen: createRequest.isOpen,
            isPublic: createRequest.isPublic,
            invitationCode: UUID().uuidString, // Уникальный код приглашения
            gameState: .forming,
            adminId: createRequest.adminUserId
        )
        rooms[room.id!] = room
        return req.eventLoop.makeSucceededFuture(room)
    }

    func update(room: Room, on req: Request) -> EventLoopFuture<Room> {
        rooms[room.id!] = room
        return req.eventLoop.makeSucceededFuture(room)
    }

    func delete(id: UUID, on req: Request) -> EventLoopFuture<Void> {
        rooms.removeValue(forKey: id)
        return req.eventLoop.makeSucceededFuture(())
    }
}

// MARK: - Mock PlayerRepository
final class MockPlayerRepository: PlayerRepository {
    var players: [UUID: Player] = [:]
    
    func find(id: UUID, on req: Request) -> EventLoopFuture<Player?> {
        return req.eventLoop.makeSucceededFuture(players[id])
    }

    func create(createRequest: CreatePlayerRequest, on req: Request) -> EventLoopFuture<Player> {
        let player = Player(
            id: UUID(),
            userID: createRequest.userId,
            roomID: createRequest.roomId,
            nickname: createRequest.nickname,
            score: 0,                                     // Начальный счёт
            turnOrder: 1,                                 // Порядок хода
            availableLetters: ["A", "B", "C"].joined(separator: ",") // Начальные буквы
        )
        players[player.id!] = player
        return req.eventLoop.makeSucceededFuture(player)
    }

    func update(player: Player, on req: Request) -> EventLoopFuture<Player> {
        players[player.id!] = player
        return req.eventLoop.makeSucceededFuture(player)
    }

    func delete(id: UUID, on req: Request) -> EventLoopFuture<Void> {
        players.removeValue(forKey: id)
        return req.eventLoop.makeSucceededFuture(())
    }
}

// MARK: - Test Class
final class RoomServiceImplTests: XCTestCase {
    private var app: Application!
    private var mockRoomRepository: MockRoomRepository!
    private var mockPlayerRepository: MockPlayerRepository!
    private var roomService: RoomServiceImpl!

    override func setUp() {
        super.setUp()
        app = Application(.testing)
        mockRoomRepository = MockRoomRepository()
        mockPlayerRepository = MockPlayerRepository()
        roomService = RoomServiceImpl(
            roomRepository: mockRoomRepository,
            playerRepository: mockPlayerRepository
        )
    }

    override func tearDown() {
        mockRoomRepository = nil
        mockPlayerRepository = nil
        roomService = nil
        app.shutdown()
        super.tearDown()
    }

    // MARK: - Test Cases

    /// Успешное создание игрока
    func testCreatePlayer_Success() throws {
        let playerRequest = CreatePlayerRequest(
            userId: UUID(),
            roomId: UUID(),
            nickname: "Player1"
        )
        let req = Request(application: app, on: app.eventLoopGroup.next())

        let futurePlayer = mockPlayerRepository.create(createRequest: playerRequest, on: req)
        let player = try futurePlayer.wait()

        XCTAssertNotNil(player.id)
        XCTAssertEqual(player.nickname, "Player1")
        XCTAssertEqual(player.availableLetters, "A,B,C")
        XCTAssertEqual(player.score, 0)
        XCTAssertEqual(player.turnOrder, 1)
    }

    /// Успешное присоединение к комнате
    func testJoinRoom_Success() throws {
        let roomId = UUID()
        let adminUserId = UUID()
        let invitationCode = "12345"
        
        // Создаём комнату
        let room = Room(
            id: roomId,
            isOpen: true,
            isPublic: true,
            invitationCode: invitationCode,
            gameState: .forming,
            adminId: adminUserId
        )
        mockRoomRepository.rooms[roomId] = room

        // Настраиваем обработчик для поиска по коду приглашения
        mockRoomRepository.findByInvitationCodeHandler = { code in
            return code == invitationCode ? room : nil
        }

        let joinRequest = JoinRoomRequestModel(
            userId: UUID(), invitationCode: invitationCode,
            nickname: "Player1"
        )

        let req = Request(application: app, on: app.eventLoopGroup.next())

        let futureResult = roomService.joinRoom(joinRequest: joinRequest, on: req)
        try futureResult.wait()

        XCTAssertTrue(
            mockPlayerRepository.players.values.contains { $0.nickname == "Player1" }
        )
    }

    /// Ошибка: комната не найдена
    func testJoinRoom_RoomNotFound() throws {
        let invitationCode = "12345"
        mockRoomRepository.findByInvitationCodeHandler = { _ in
            return nil
        }

        let joinRequest = JoinRoomRequestModel(
            userId: UUID(), invitationCode: invitationCode,
            nickname: "Player1"
        )

        let req = Request(application: app, on: app.eventLoopGroup.next())

        let futureResult = roomService.joinRoom(joinRequest: joinRequest, on: req)

        XCTAssertThrowsError(try futureResult.wait()) { error in
            XCTAssertTrue(error is Abort)
            XCTAssertEqual((error as? Abort)?.status, .notFound)
        }
    }

    /// Успешное создание комнаты
    func testCreateRoom_Success() throws {
        let req = Request(application: app, on: app.eventLoopGroup.next())

        let createRoomRequest = CreateRoomRequestModel(
            userId: UUID(),
            isOpen: true,
            isPublic: false,
            adminNickname: "Admin"
        )

        let futureResult = roomService.createRoom(createRequest: createRoomRequest, on: req)
        let result = try futureResult.wait()

        XCTAssertNotNil(result.roomId)
        XCTAssertFalse(result.invitationCode.isEmpty)
        XCTAssertTrue(
            mockPlayerRepository.players.values.contains { $0.nickname == "Admin" }
        )
    }

    /// Успешное удаление игрока
    func testDeletePlayer_Success() throws {
        let playerId = UUID()
        let player = Player(
            id: playerId,
            userID: UUID(),
            roomID: UUID(),
            nickname: "Player1",
            score: 100,
            turnOrder: 1,
            availableLetters: "A,B,C"
        )
        mockPlayerRepository.players[playerId] = player
        
        let req = Request(application: app, on: app.eventLoopGroup.next())

        let futureResult = mockPlayerRepository.delete(id: playerId, on: req)
        try futureResult.wait()

        XCTAssertNil(mockPlayerRepository.players[playerId])
    }

    /// Успешное удаление комнаты
    func testDeleteRoom_Success() throws {
        let roomId = UUID()
        let room = Room(
            id: roomId,
            isOpen: true,
            isPublic: true,
            invitationCode: "12345",
            gameState: .forming,
            adminId: UUID()
        )
        mockRoomRepository.rooms[roomId] = room

        let req = Request(application: app, on: app.eventLoopGroup.next())

        let futureResult = roomService.deleteRoom(id: roomId, on: req)
        try futureResult.wait()

        XCTAssertNil(mockRoomRepository.rooms[roomId])
    }
}
