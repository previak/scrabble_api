import XCTest
import Vapor
import Foundation
@testable import App


final class MockUserService: UserService {
    var getUserClosure: ((UUID, Request) -> EventLoopFuture<UserDTO>)?
    var createUserClosure: ((UserDTO, Request) -> EventLoopFuture<UserDTO>)?
    var updateUserClosure: ((UserDTO, Request) -> EventLoopFuture<UserDTO>)?
    var deleteUserClosure: ((UUID, Request) -> EventLoopFuture<Void>)?
    var loginClosure: ((String, String, Request) -> EventLoopFuture<String>)?
    var authenticateClosure: ((String, Request) -> EventLoopFuture<UserDTO>)?

    func getUser(id: UUID, on req: Request) -> EventLoopFuture<UserDTO> {
        return getUserClosure!(id, req)
    }

    func createUser(user: UserDTO, on req: Request) -> EventLoopFuture<UserDTO> {
        return createUserClosure!(user, req)
    }

    func updateUser(user: UserDTO, on req: Request) -> EventLoopFuture<UserDTO> {
        return updateUserClosure!(user, req)
    }

    func deleteUser(id: UUID, on req: Request) -> EventLoopFuture<Void> {
        return deleteUserClosure!(id, req)
    }

    func login(username: String, password: String, on req: Request) -> EventLoopFuture<String> {
        return loginClosure!(username, password, req)
    }

    func authenticate(jwt: String, on req: Request) -> EventLoopFuture<UserDTO> {
        return authenticateClosure!(jwt, req)
    }
}

final class UserControllerTests: XCTestCase {
    var app: Application!
    var mockUserService: MockUserService!
    var userController: UserController!

    override func setUp() {
        super.setUp()
        app = Application(.testing)
        mockUserService = MockUserService()
        userController = UserController(userService: mockUserService)
    }

    override func tearDown() {
        app.shutdown()
        super.tearDown()
    }

    /// Тест успешного получения пользователя
    func testGetUserSuccess() throws {
        let testUserID = UUID()
        let testUserDTO = UserDTO(id: testUserID, username: "testuser", passwordHash: "hashed_password", apiKey: "test_api_key")

        mockUserService.getUserClosure = { id, _ in
            guard id == testUserID else { return self.app.eventLoopGroup.future(error: Abort(.notFound)) }
            return self.app.eventLoopGroup.future(testUserDTO)
        }

        let req = Request(application: app, on: app.eventLoopGroup.next())
        req.parameters.set("id", to: testUserID.uuidString)

        let futureUser = try userController.getUser(req: req)
        let user = try futureUser.wait()

        XCTAssertEqual(user.id, testUserID)
        XCTAssertEqual(user.username, "testuser")
        XCTAssertEqual(user.passwordHash, "hashed_password")
        XCTAssertEqual(user.apiKey, "test_api_key")
    }

    /// Тест успеха создания пользователя
    func testCreateUserSuccess() throws {
        let requestUserDTO = UserDTO(id: nil, username: "newuser", passwordHash: "hash123", apiKey: "apikey123")
        let createdUserDTO = UserDTO(id: UUID(), username: "newuser", passwordHash: "hash123", apiKey: "apikey123")

        mockUserService.createUserClosure = { userDTO, _ in
            return self.app.eventLoopGroup.future(createdUserDTO)
        }

        let req = Request(application: app, method: .POST, url: .init(string: "/users"), on: app.eventLoopGroup.next())
        try req.content.encode(requestUserDTO, as: .json)

        let futureUser = try userController.createUser(req: req)
        let user = try futureUser.wait()

        XCTAssertNotNil(user.id)
        XCTAssertEqual(user.username, "newuser")
        XCTAssertEqual(user.passwordHash, "hash123")
        XCTAssertEqual(user.apiKey, "apikey123")
    }

    /// Тест успешного обновления пользователя
    func testUpdateUserSuccess() throws {
        let testUserID = UUID()
        let updatedUserDTO = UserDTO(id: testUserID, username: "updateduser", passwordHash: "newhashedpassword", apiKey: "newapikey")

        mockUserService.updateUserClosure = { userDTO, _ in
            return self.app.eventLoopGroup.future(updatedUserDTO)
        }

        let req = Request(application: app, method: .PUT, url: .init(string: "/users/\(testUserID.uuidString)"), on: app.eventLoopGroup.next())
        try req.content.encode(updatedUserDTO, as: .json)
        req.parameters.set("id", to: testUserID.uuidString)

        let futureUser = try userController.updateUser(req: req)
        let user = try futureUser.wait()

        XCTAssertEqual(user.id, testUserID)
        XCTAssertEqual(user.username, "updateduser")
        XCTAssertEqual(user.passwordHash, "newhashedpassword")
        XCTAssertEqual(user.apiKey, "newapikey")
    }

    /// Тест успешного удаления пользователя
    func testDeleteUserSuccess() throws {
        let testUserID = UUID()

        mockUserService.deleteUserClosure = { id, _ in
            guard id == testUserID else { return self.app.eventLoopGroup.future(error: Abort(.notFound)) }
            return self.app.eventLoopGroup.future()
        }

        let req = Request(application: app, on: app.eventLoopGroup.next())
        req.parameters.set("id", to: testUserID.uuidString)

        let futureResponse = try userController.deleteUser(req: req)
        let response = try futureResponse.wait()

        XCTAssertEqual(response, .noContent)
    }

    /// Тест успешной аутентификации пользователя по JWT
    func testAuthenticateSuccess() throws {
        let testUserDTO = UserDTO(id: UUID(), username: "authuser", passwordHash: "hashedauth", apiKey: "authapikey")
        let testAuthRequest = AuthRequest(token: "validAuthToken")

        mockUserService.authenticateClosure = { token, _ in
            guard token == testAuthRequest.token else { return self.app.eventLoopGroup.future(error: Abort(.unauthorized)) }
            return self.app.eventLoopGroup.future(testUserDTO)
        }

        let req = Request(application: app, method: .POST, url: .init(string: "/auth/authenticate"), on: app.eventLoopGroup.next())
        try req.content.encode(testAuthRequest, as: .json)

        let futureUser = try userController.authenticate(req: req)
        let user = try futureUser.wait()

        XCTAssertEqual(user.username, "authuser")
        XCTAssertEqual(user.apiKey, "authapikey")
    }

    /// Тест успешного входа пользователя (login)
    func testLoginSuccess() throws {
        let testLoginCredentials = LoginCredentials(username: "loginuser", password: "correct_password")
        let returnedJWT = "valid_jwt_token"

        mockUserService.loginClosure = { username, password, _ in
            guard username == testLoginCredentials.username && password == testLoginCredentials.password else {
                return self.app.eventLoopGroup.future(error: Abort(.unauthorized))
            }
            return self.app.eventLoopGroup.future(returnedJWT)
        }

        let req = Request(application: app, method: .POST, url: .init(string: "/auth/login"), on: app.eventLoopGroup.next())
        try req.content.encode(testLoginCredentials, as: .json)

        let futureJWT = try userController.login(req: req)
        let jwt = try futureJWT.wait()

        XCTAssertEqual(jwt, returnedJWT)
    }

    /// Тест аутентификации с неверным JWT (ошибка 401 Unauthorized)
    func testAuthenticateFailure() throws {
        let testAuthRequest = AuthRequest(token: "invalidAuthToken")

        mockUserService.authenticateClosure = { token, _ in
            return self.app.eventLoopGroup.future(error: Abort(.unauthorized))
        }

        let req = Request(application: app, method: .POST, url: .init(string: "/auth/authenticate"), on: app.eventLoopGroup.next())
        try req.content.encode(testAuthRequest, as: .json)

        XCTAssertThrowsError(try userController.authenticate(req: req).wait()) { error in
            XCTAssertEqual((error as? Abort)?.status, .unauthorized)
        }
    }

    /// Тест логина с неверными данными (ошибка 401 Unauthorized)
    func testLoginFailure() throws {
        let invalidLoginCredentials = LoginCredentials(username: "loginuser", password: "incorrect_password")

        mockUserService.loginClosure = { username, password, _ in
            return self.app.eventLoopGroup.future(error: Abort(.unauthorized))
        }

        let req = Request(application: app, method: .POST, url: .init(string: "/auth/login"), on: app.eventLoopGroup.next())
        try req.content.encode(invalidLoginCredentials, as: .json)

        XCTAssertThrowsError(try userController.login(req: req).wait()) { error in
            XCTAssertEqual((error as? Abort)?.status, .unauthorized)
        }
    }
}
