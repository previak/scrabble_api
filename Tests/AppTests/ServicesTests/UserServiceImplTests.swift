import XCTest
import Vapor
@testable import App


struct LoginCredentials: Content {
    let username: String
    let password: String
}
struct RegisterRequestModel: Content {
    let username: String
    let password: String
}


// MARK: - Mock UserService
final class MockUserService: UserService {
    func register(registerRequest: App.RegisterRequestModel, on req: Vapor.Request) -> NIOCore.EventLoopFuture<App.RegisterResponseModel> {
        return register(registerRequest: registerRequest, on: req)
    }
    
    func login(loginRequest: App.LoginRequestModel, on req: Vapor.Request) -> NIOCore.EventLoopFuture<App.LoginResponseModel> {
        return login(loginRequest: loginRequest, on: req)
    }
    
    var registerClosure: ((RegisterRequestModel, Request) -> EventLoopFuture<RegisterResponseDTO>)?
    var loginClosure: ((String, String, Request) -> EventLoopFuture<LoginResponseDTO>)?

    func register(registerRequest: RegisterRequestModel, on req: Request) -> EventLoopFuture<RegisterResponseDTO> {
        return registerClosure!(registerRequest, req)
    }

    func login(username: String, password: String, on req: Request) -> EventLoopFuture<LoginResponseDTO> {
        return loginClosure!(username, password, req)
    }

    var getUserClosure: ((UUID, Request) -> EventLoopFuture<UserDTO>)?
    var createUserClosure: ((UserDTO, Request) -> EventLoopFuture<UserDTO>)?
    var updateUserClosure: ((UserDTO, Request) -> EventLoopFuture<UserDTO>)?
    var deleteUserClosure: ((UUID, Request) -> EventLoopFuture<Void>)?
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

    func authenticate(jwt: String, on req: Request) -> EventLoopFuture<UserDTO> {
        return authenticateClosure!(jwt, req)
    }
}

// MARK: - UserControllerTests
/*final class UserServiceTests: XCTestCase {
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

    /// Тест успешной регистрации
    func testRegisterUserSuccess() throws {
        let registerRequest = RegisterRequestModel(username: "newuser", password: "securePassword123")
        let expectedResponse = RegisterResponseDTO(accessToken: "sample_access_token", apiKey: "sample_api_key")

        mockUserService.registerClosure = { request, req in
            XCTAssertEqual(request.username, "newuser")
            XCTAssertEqual(request.password, "securePassword123")
            return req.eventLoop.future(expectedResponse)
        }

        let req = Request(application: app, method: .POST, url: URI(string: "/auth/register"), on: app.eventLoopGroup.next())
        try req.content.encode(registerRequest, as: .json)

        let futureResponse = try userController.register(req: req)
        let response = try futureResponse.wait()

        XCTAssertEqual(response.accessToken, expectedResponse.accessToken)
        XCTAssertEqual(response.apiKey, expectedResponse.apiKey)
    }

    /// Тест успешного входа (логин)
    /*func testLoginUserSuccess() throws {
        let loginCredentials = LoginCredentials(username: "loginuser", password: "correct_password")
        let expectedResponse = LoginResponseDTO(accessToken: "valid_access_token")

        mockUserService.loginClosure = { username, password, req in
            XCTAssertEqual(username, "loginuser")
            XCTAssertEqual(password, "correct_password")
            return req.eventLoop.future(expectedResponse)
        }

        let req = Request(application: app, method: .POST, url: URI(string: "/auth/login"), on: app.eventLoopGroup.next())
        try req.content.encode(loginCredentials, as: .json)

        // Вызываем метод контроллера
        let futureResponse = try userController.login(req: req)
        let response = try futureResponse.wait()

        // Проверяем результат
        XCTAssertEqual(response.accessToken, expectedResponse.accessToken)
    }*/

    /// Тест неудачного входа (логин)
    /*func testLoginUserFailure_InvalidCredentials() throws {
        let loginCredentials = LoginCredentials(username: "loginuser", password: "wrong_password")

        mockUserService.loginClosure = { username, password, req in
            return req.eventLoop.future(error: Abort(.unauthorized))
        }

        let req = Request(application: app, method: .POST, url: URI(string: "/auth/login"), on: app.eventLoopGroup.next())
        try req.content.encode(loginCredentials, as: .json)

        XCTAssertThrowsError(try userController.login(req: req).wait()) { error in
            XCTAssertTrue(error is Abort)
            XCTAssertEqual((error as? Abort)?.status, .unauthorized)
        }
    }*/

    /// Тест неудачной регистрации (пользователь уже существует)
    func testRegisterUserFailure_UserAlreadyExists() throws {
        let registerRequest = RegisterRequestModel(username: "existinguser", password: "securePassword123")

        mockUserService.registerClosure = { request, req in
            guard request.username != "existinguser" else {
                return req.eventLoop.future(error: Abort(.conflict, reason: "User already exists"))
            }
            return req.eventLoop.future(RegisterResponseDTO(accessToken: "sample_access_token", apiKey: "sample_api_key"))
        }

        let req = Request(application: app, method: .POST, url: URI(string: "/auth/register"), on: app.eventLoopGroup.next())
        try req.content.encode(registerRequest, as: .json)

        XCTAssertThrowsError(try userController.register(req: req).wait()) { error in
            XCTAssertTrue(error is Abort)
            XCTAssertEqual((error as? Abort)?.status, .conflict)
        }
    }
}

*/
