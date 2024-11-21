/*import XCTest
import Fluent
import Vapor
import Foundation

@testable import App

final class RoomControllerTests: XCTestCase {
    var app: Application!
    var mockRoomService: MockRoomService!
    var roomController: RoomController!
    
    override func setUp() {
        super.setUp()
        app = Application(.testing)
        mockRoomService = MockRoomService()
        roomController = RoomController(roomService: mockRoomService)
    }
    
    override func tearDown() {
        app.shutdown()
        super.tearDown()
    }
    
    func testGetRoom() throws {
        // Given: Создаем тестовые данные для комнаты и администратора
        let testRoomID = UUID()
        let testAdminID = UUID()
        let testAdmin = User(id: testAdminID, username: "adminUser", passwordHash: "hashed_password", apiKey: "test_api_key")
        let roomDTO = RoomDTO(
            id: testRoomID,
            isOpen: true,
            isPublic: true,
            invitationCode: "XYZ123",
            gameState: .forming,
            admin: testAdmin
        )
        
        // Настройка мокового сервиса для имитации возврата данных
        mockRoomService.getRoomClosure = { id, _ in
            guard id == testRoomID else { return self.app.eventLoopGroup.future(error: Abort(.notFound)) }
            return self.app.eventLoopGroup.future(roomDTO)
        }
        
        // Создаем запрос с параметром ID комнаты (строка)
        let req = Request(application: app, on: app.eventLoopGroup.next())
        req.parameters.set("id", to: testRoomID.uuidString)

        // When: Выполняем запрос к контроллеру
        let futureRoom = try roomController.getRoom(req: req)
        let room = try futureRoom.wait()

        // Then: Проверяем, правильно ли возвращены данные
        XCTAssertEqual(room.id, testRoomID)
        XCTAssertEqual(room.isOpen, true)
        XCTAssertEqual(room.isPublic, true)
        XCTAssertEqual(room.invitationCode, "XYZ123")
        XCTAssertEqual(room.gameState, .forming)
        XCTAssertEqual(room.admin.id, testAdminID)
        XCTAssertEqual(room.admin.username, "adminUser")
    }
    
    func testCreateRoom() throws {
        // Given: Данные для создания комнаты
        let createRoomRequest = CreateRoomRequestDTO(userId: UUID(), isOpen: true, isPublic: true, adminNickname: "AdminUser")
        let createRoomResponse = CreateRoomResponseModel(adminUserId: UUID(), roomId: UUID(), invitationCode: "ABC123")
        
        // Настройка мокового сервиса для создания комнаты
        mockRoomService.createRoomClosure = { createRequest, _ in
            return self.app.eventLoopGroup.future(createRoomResponse)
        }
        
        // Создание запросного объекта и тела запроса
        let req = Request(
            application: app,
            method: .POST,
            url: URI(path: "/rooms"),
            on: app.eventLoopGroup.next()
        )
        
        // Кодировку данных в тело запроса лучше всего делать через `req.content.encode`
        try req.content.encode(createRoomRequest, as: .json)

        // When: Выполняем запрос к контроллеру
        let futureResponse = try roomController.createRoom(req: req)
        let response = try futureResponse.wait()

        // Then: Проверяем, правильно ли возвращен ответ
        XCTAssertEqual(response.invitationCode, "ABC123")
        XCTAssertEqual(response.adminUserId, createRoomResponse.adminUserId)
    }
    
    /*func testUpdateRoom() throws {
        // Given: Данные для тестовой комнаты и администратора
        let testRoomID = UUID()
        let testAdminID = UUID()
        let testAdmin = User(id: testAdminID, username: "updatedAdmin", passwordHash: "hashed_password", apiKey: "test_api_key")
        let roomDTO = RoomDTO(
            id: testRoomID,
            isOpen: true,
            isPublic: true,
            invitationCode: "XYZ123",
            gameState: .playing,
            admin: testAdmin
        )
        
        // Настройка мокового сервиса для обновления комнаты
        mockRoomService.updateRoomClosure = { room, _ in
            return self.app.eventLoopGroup.future(room)
        }

        // Создание запроса с телом
        let req = Request(
            application: app,
            method: .PUT,
            url: URI(path: "/rooms/\(testRoomID.uuidString)"), // Используем UUID как строку для URI
            on: app.eventLoopGroup.next()
        )

        // Кодируем содержимое тела запроса
        try req.content.encode(roomDTO, as: .json)

        // When: Выполняем запрос к контроллеру
        let futureResponse = try roomController.updateRoom(req: req)
        let response = try futureResponse.wait()

        // Then: Проверяем, что комната вернулась с правильными данными
        XCTAssertEqual(response.id, testRoomID)
        XCTAssertEqual(response.invitationCode, "XYZ123")
        XCTAssertEqual(response.gameState, .playing)
        XCTAssertEqual(response.admin.username, "updatedAdmin")
        XCTAssertEqual(response.admin.id, testAdminID)
    }*/

    func testDeleteRoom() throws {
        // Given: Идентификатор комнаты для удаления
        let testRoomID = UUID()
        
        // Настройка мокового сервиса для удаления комнаты
        mockRoomService.deleteRoomClosure = { id, _ in
            guard id == testRoomID else { return self.app.eventLoopGroup.future(error: Abort(.notFound)) }
            return self.app.eventLoopGroup.future()
        }
        
        // Создание запроса с параметром ID (строка)
        let req = Request(application: app, on: app.eventLoopGroup.next())
        req.parameters.set("id", to: testRoomID.uuidString)

        // When: Выполняем запрос на удаление
        let futureResult = try roomController.deleteRoom(req: req)
        let result = try futureResult.wait()

        // Then: Проверяем успешное удаление (код 204)
        XCTAssertEqual(result, .noContent)
    }
}

// Мок-сервис для RoomService

final class MockRoomService: RoomService {
    func joinRoom(joinRequest: JoinRoomRequestModel, on req: Request) -> NIOCore.EventLoopFuture<Void> {
        return joinRoom(joinRequest: joinRequest, on: req)
    }
    
    // Closure для getRoom
    var getRoomClosure: ((UUID, Request) -> EventLoopFuture<RoomDTO>)?
    
    // Closure для createRoom
    var createRoomClosure: ((CreateRoomRequestModel, Request) -> EventLoopFuture<CreateRoomResponseModel>)?
    
    // Closure для updateRoom
    var updateRoomClosure: ((RoomDTO, Request) -> EventLoopFuture<RoomDTO>)?
    
    // Closure для deleteRoom
    var deleteRoomClosure: ((UUID, Request) -> EventLoopFuture<Void>)?
    
    // Реализация сервиса getRoom
    func getRoom(id: UUID, on req: Request) -> EventLoopFuture<RoomDTO> {
        return getRoomClosure!(id, req)
    }
    
    // Реализация сервиса createRoom
    func createRoom(createRequest: CreateRoomRequestModel, on req: Request) -> EventLoopFuture<CreateRoomResponseModel> {
        return createRoomClosure!(createRequest, req)
    }
    
    // Реализация сервиса updateRoom
    func updateRoom(room: RoomDTO, on req: Request) -> EventLoopFuture<RoomDTO> {
        return updateRoomClosure!(room, req)
    }
    
    // Реализация сервиса deleteRoom
    func deleteRoom(id: UUID, on req: Request) -> EventLoopFuture<Void> {
        return deleteRoomClosure!(id, req)
    }
}

*/
