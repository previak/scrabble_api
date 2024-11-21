import XCTest
@testable import App
import Vapor
import Crypto

// MARK: - Mock UserRepository
final class MockUserRepository: UserRepository {
    var users: [UUID: User] = [:]
    var usersByUsername: [String: User] = [:]

    func findById(id: UUID, on req: Request) -> EventLoopFuture<User?> {
        return req.eventLoop.makeSucceededFuture(users[id])
    }

    func findByUsername(username: String, on req: Request) -> EventLoopFuture<User?> {
        return req.eventLoop.makeSucceededFuture(usersByUsername[username])
    }

    func create(user: User, on req: Request) -> EventLoopFuture<User> {
        users[user.id!] = user
        usersByUsername[user.username] = user
        return req.eventLoop.makeSucceededFuture(user)
    }

    func update(user: User, on req: Request) -> EventLoopFuture<User> {
        users[user.id!] = user
        return req.eventLoop.makeSucceededFuture(user)
    }

    func delete(id: UUID, on req: Request) -> EventLoopFuture<Void> {
        if let user = users[id] {
            users.removeValue(forKey: id)
            usersByUsername.removeValue(forKey: user.username)
        }
        return req.eventLoop.makeSucceededFuture(())
    }
}

// MARK: - Test Class
final class UserServiceImplTests: XCTestCase {
    private var app: Application!
    private var mockUserRepository: MockUserRepository!
    private var userService: UserServiceImpl!

    override func setUp() {
        super.setUp()
        app = Application(.testing)
        mockUserRepository = MockUserRepository()
        userService = UserServiceImpl(userRepository: mockUserRepository)
    }

    override func tearDown() {
        mockUserRepository = nil
        userService = nil
        app.shutdown()
        super.tearDown()
    }

    // MARK: - Test Cases

    /// Успешная регистрация пользователя
    func testRegisterUser_Success() throws {
        let req = Request(application: app, on: app.eventLoopGroup.next())

        // Генерируем хэш пароля
        let hashedPassword = try Bcrypt.hash("password")

        let futureResult = userService.register(username: "testuser", password: hashedPassword, on: req)
        let token = try futureResult.wait()

        XCTAssertNotNil(token)
        XCTAssertEqual(mockUserRepository.usersByUsername["testuser"]?.username, "testuser")
    }

    /// Ошибка регистрации: пользователь уже существует
    func testRegisterUser_UsernameAlreadyExists() throws {
        let req = Request(application: app, on: app.eventLoopGroup.next())

        let existingUser = User(id: UUID(), username: "testuser", passwordHash: try Bcrypt.hash("oldpassword"), apiKey: "apiKey")
        mockUserRepository.usersByUsername["testuser"] = existingUser

        let futureResult = userService.register(username: "testuser", password: "password", on: req)

        XCTAssertThrowsError(try futureResult.wait()) { error in
            XCTAssertTrue(error is Abort)
            XCTAssertEqual((error as? Abort)?.status, .conflict)
        }
    }

    /// Успешный вход (логин)
    func testLogin_Success() throws {
        let req = Request(application: app, on: app.eventLoopGroup.next())

        let passwordHash = try Bcrypt.hash("password")
        let user = User(id: UUID(), username: "testuser", passwordHash: passwordHash, apiKey: "apiKey")
        mockUserRepository.usersByUsername["testuser"] = user

        let futureResult = userService.login(username: "testuser", password: "password", on: req)
        let token = try futureResult.wait()

        XCTAssertNotNil(token)
    }

    /// Ошибка входа: неправильный пароль
    func testLogin_InvalidPassword() throws {
        let req = Request(application: app, on: app.eventLoopGroup.next())

        let passwordHash = try Bcrypt.hash("password")
        let user = User(id: UUID(), username: "testuser", passwordHash: passwordHash, apiKey: "apiKey")
        mockUserRepository.usersByUsername["testuser"] = user

        let futureResult = userService.login(username: "testuser", password: "wrongpassword", on: req)

        XCTAssertThrowsError(try futureResult.wait()) { error in
            XCTAssertTrue(error is Abort)
            XCTAssertEqual((error as? Abort)?.status, .unauthorized)
        }
    }

    /// Ошибка входа: пользователь не найден
    func testLogin_UserNotFound() throws {
        let req = Request(application: app, on: app.eventLoopGroup.next())

        let futureResult = userService.login(username: "unknownuser", password: "password", on: req)

        XCTAssertThrowsError(try futureResult.wait()) { error in
            XCTAssertTrue(error is Abort)
            XCTAssertEqual((error as? Abort)?.status, .unauthorized)
        }
    }
}
