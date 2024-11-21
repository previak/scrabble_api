
import Vapor
import XCTest
@testable import App

// Mock UserService для тестов
final class MockUserServiceCon: UserService {
    func getUser(id: UUID, on req: Vapor.Request) -> NIOCore.EventLoopFuture<App.UserDTO> {
        return getUser(id: id, on: req)
    }
    
    func createUser(user: App.UserDTO, on req: Vapor.Request) -> NIOCore.EventLoopFuture<App.UserDTO> {
        return createUser(user: user, on: req)
    }
    
    func updateUser(user: App.UserDTO, on req: Vapor.Request) -> NIOCore.EventLoopFuture<App.UserDTO> {
        return updateUser(user: user, on: req)
    }
    
    func deleteUser(id: UUID, on req: Vapor.Request) -> NIOCore.EventLoopFuture<Void> {
        return deleteUser(id: id, on: req)
    }
    
    func register(registerRequest: App.RegisterRequestModel, on req: Vapor.Request) -> NIOCore.EventLoopFuture<App.RegisterResponseModel> {
        return register(registerRequest: registerRequest, on: req)
    }
    
    var registerCalled = false
    var loginCalled = false
    var authenticateCalled = false
    
    var registerResponse: RegisterResponseModel?
    var loginResponse: LoginResponseModel?
    var authenticateResponse: UserDTO?
    var error: Error?

    func register(registerRequest: RegisterRequestModel, on req: Request) -> EventLoopFuture<RegisterResponseModel> {
        registerCalled = true
        if let error = self.error {
            return req.eventLoop.makeFailedFuture(error)
        }
        if let response = registerResponse {
            return req.eventLoop.makeSucceededFuture(response)
        } else {
            return req.eventLoop.makeFailedFuture(Abort(.internalServerError, reason: "Mock registerResponse not provided"))
        }
    }

    func login(loginRequest: LoginRequestModel, on req: Request) -> EventLoopFuture<LoginResponseModel> {
        loginCalled = true
        if let error = self.error {
            return req.eventLoop.makeFailedFuture(error)
        }
        if let response = loginResponse {
            return req.eventLoop.makeSucceededFuture(response)
        } else {
            return req.eventLoop.makeFailedFuture(Abort(.internalServerError, reason: "Mock loginResponse not provided"))
        }
    }

    func authenticate(jwt: String, on req: Request) -> EventLoopFuture<UserDTO> {
        authenticateCalled = true
        if let error = self.error {
            return req.eventLoop.makeFailedFuture(error)
        }
        if let response = authenticateResponse {
            return req.eventLoop.makeSucceededFuture(response)
        } else {
            return req.eventLoop.makeFailedFuture(Abort(.unauthorized, reason: "Mock authenticateResponse not provided"))
        }
    }
}

// Тесты для UserController
final class UserControllerTests: XCTestCase {
    func testRegister() throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        
        let mockUserService = MockUserServiceCon()
        let expectedResponse = RegisterResponseModel(
            accessToken: "testAccessToken",
            apiKey: "testApiKey"
        )
        mockUserService.registerResponse = expectedResponse
        
        let userController = UserController(userService: mockUserService)
        try userController.boot(routes: app.routes)
        
        let requestBody = RegisterRequestDTO(
            username: "testUser",
            password: "testPassword"
        )
        
        try app.test(.POST, "/auth/register", beforeRequest: { req in
            req.headers.contentType = .json
            try req.content.encode(requestBody)
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .ok, "Response status should be 200 OK")
            XCTAssertTrue(mockUserService.registerCalled, "register should be called")
            
            let response = try res.content.decode(RegisterResponseDTO.self)
            XCTAssertEqual(response.accessToken, expectedResponse.accessToken)
            XCTAssertEqual(response.apiKey, expectedResponse.apiKey)
        })
    }
}
