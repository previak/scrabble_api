import Vapor
import XCTVapor
@testable import App


final class MockRoomService: RoomService {
    func getPublicRooms(on req: Vapor.Request) -> NIOCore.EventLoopFuture<App.GetRoomsListResponseModel> {
        return getPublicRooms(on: req)
    }
    
    func getRoom(id: UUID, on req: Vapor.Request) -> NIOCore.EventLoopFuture<App.RoomDTO> {
        return getRoom(id: id, on: req)
    }
    
    func updateRoom(room: App.RoomDTO, on req: Vapor.Request) -> NIOCore.EventLoopFuture<App.RoomDTO> {
        return updateRoom(room: room, on: req)
    }
    
    func deleteRoom(id: UUID, on req: Vapor.Request) -> NIOCore.EventLoopFuture<Void> {
        return deleteRoom(id: id, on: req)
    }
    
    var createRoomCalled = false
    var joinRoomCalled = false
    
    var createRoomResponse: CreateRoomResponseModel?
    var expectedError: Error?

    func createRoom(createRequest: CreateRoomRequestModel, on req: Request) -> EventLoopFuture<CreateRoomResponseModel> {
        createRoomCalled = true
        if let error = expectedError {
            return req.eventLoop.makeFailedFuture(error)
        }
        if let response = createRoomResponse {
            return req.eventLoop.makeSucceededFuture(response)
        } else {
            return req.eventLoop.makeFailedFuture(Abort(.internalServerError, reason: "No mock createRoomResponse provided"))
        }
    }

    func joinRoom(joinRequest: JoinRoomRequestModel, on req: Request) -> EventLoopFuture<Void> {
        joinRoomCalled = true
        if let error = expectedError {
            return req.eventLoop.makeFailedFuture(error)
        } else {
            return req.eventLoop.makeSucceededFuture(())
        }
    }
}


final class RoomControllerTests: XCTestCase {
    
    func testCreateRoom() throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        
        let mockRoomService = MockRoomService()
        let expectedResponse = CreateRoomResponseModel(
            adminUserId: UUID(), roomId: UUID(),
            invitationCode: "TEST_CODE"
        )
        mockRoomService.createRoomResponse = expectedResponse
        
        let roomController = RoomController(roomService: mockRoomService)
        try roomController.boot(routes: app.routes)

        let requestBody = CreateRoomRequestDTO(
            userId: UUID(),
            isOpen: true,
            isPublic: false,
            adminNickname: "TestAdmin"
        )

        try app.test(.POST, "/rooms/create", beforeRequest: { req in
            req.headers.contentType = .json
            try req.content.encode(requestBody)
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .ok, "Response status should be 200 OK")
            XCTAssertTrue(mockRoomService.createRoomCalled, "createRoom should be called")

            let response = try res.content.decode(CreateRoomResponseDTO.self)
            XCTAssertEqual(response.adminUserId, expectedResponse.adminUserId)
            XCTAssertEqual(response.invitationCode, expectedResponse.invitationCode)
        })
    }
    
    func testJoinRoom() throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        
        let mockRoomService = MockRoomService()
        let roomController = RoomController(roomService: mockRoomService)
        try roomController.boot(routes: app.routes)
        
        let requestBody = JoinRoomRequestDTO(
            userId: UUID(),
            invitationCode: "TEST_CODE",
            nickname: "TestUser"
        )

        try app.test(.POST, "/rooms/join", beforeRequest: { req in
            req.headers.contentType = .json
            try req.content.encode(requestBody)
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .ok, "Response status should be 200 OK")
            XCTAssertTrue(mockRoomService.joinRoomCalled, "joinRoom should be called")
        })
    }
    
    func testCreateRoomErrorHandling() throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        
        let mockRoomService = MockRoomService()
        mockRoomService.expectedError = Abort(.badRequest, reason: "Invalid room configuration")
        
        let roomController = RoomController(roomService: mockRoomService)
        try roomController.boot(routes: app.routes)

        let requestBody = CreateRoomRequestDTO(
            userId: UUID(),
            isOpen: true,
            isPublic: false,
            adminNickname: "TestAdmin"
        )

        try app.test(.POST, "/rooms/create", beforeRequest: { req in
            req.headers.contentType = .json
            try req.content.encode(requestBody)
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .badRequest, "Response status should be 400 Bad Request")
        })
    }

    func testJoinRoomErrorHandling() throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        
        let mockRoomService = MockRoomService()
        mockRoomService.expectedError = Abort(.notFound, reason: "Room not found")
        
        let roomController = RoomController(roomService: mockRoomService)
        try roomController.boot(routes: app.routes)

        let requestBody = JoinRoomRequestDTO(
            userId: UUID(),
            invitationCode: "INVALID_CODE",
            nickname: "TestUser"
        )

        try app.test(.POST, "/rooms/join", beforeRequest: { req in
            req.headers.contentType = .json
            try req.content.encode(requestBody)
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .notFound, "Response status should be 404 Not Found")
        })
    }
}
