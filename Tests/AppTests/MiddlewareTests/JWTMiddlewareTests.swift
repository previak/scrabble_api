import XCTVapor
import JWT
@testable import App

final class JWTMiddlewareTests: XCTestCase {
    private var app: Application!

    override func setUp() async throws {
        app = Application(.testing)

        // Регистрация JWT-секретного ключа
        app.jwt.signers.use(.hs256(key: "secret"))

        // Подключаем middleware
        app.middleware.use(JWTMiddleware())

        // Регистрация маршрута
        app.get("protected") { req in
            return "Access granted"
        }
    }

    override func tearDown() async throws {
        app.shutdown()
    }

    /// Тест: валидный токен -> успешный доступ
    /*func testValidToken() async throws {
        // Генерация валидного токена
        let payload = UserJWTPayload(id: UUID(), username: "testuser", expiration: Date().addingTimeInterval(60 * 60)) // +1 час от текущего времени
        let token = try app.jwt.signers.sign(payload)

        // Отправляем запрос с валидным токеном
        try app.test(.GET, "/protected", headers: ["Authorization": "Bearer \(token)"]) { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertEqual(res.body.string, "Access granted")
        }
    }*/

    /// Тест: отсутствует заголовок авторизации -> ошибка 401
    func testMissingAuthorizationHeader() async throws {
        // Отправляем запрос без токена
        try app.test(.GET, "/protected") { res in
            XCTAssertEqual(res.status, .unauthorized) // Статус 401
            let responseBody = try JSONDecoder().decode(ErrorResponse.self, from: res.body)
            XCTAssertEqual(responseBody.statusCode, 401)
            XCTAssertEqual(responseBody.message, "Missing authorization header.")
        }
    }

    /// Тест: невалидный токен -> ошибка 401
    func testInvalidToken() async throws {
        // Отправляем запрос с некорректным токеном
        try app.test(.GET, "/protected", headers: ["Authorization": "Bearer invalid_token"]) { res in
            XCTAssertEqual(res.status, .unauthorized) // Статус 401
            let responseBody = try JSONDecoder().decode(ErrorResponse.self, from: res.body)
            XCTAssertEqual(responseBody.statusCode, 401)
            XCTAssertEqual(responseBody.message, "Invalid token.")
        }
    }
}

// MARK: - Структура для парсинга ошибок
private struct ErrorResponse: Content {
    let statusCode: Int
    let message: String
}

// MARK: - Пользовательский JWT Payload для тестов
struct UserJWTPayload: JWTPayload, Authenticatable {
    var id: UUID
    var username: String
    var expiration: Date

    func verify(using signer: JWTSigner) throws {
        // Проверяем, что токен еще действителен по времени
        guard expiration > Date() else {
            throw JWTError.claimVerificationFailure(name: "exp", reason: "Token has expired.")
        }
    }
}
