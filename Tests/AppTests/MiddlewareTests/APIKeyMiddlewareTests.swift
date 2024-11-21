import XCTest
import XCTVapor
@testable import App

final class APIKeyMiddlewareTests: XCTestCase {
    private var app: Application!
    private let validApiKey = "your-valid-api-key"
    private let headerName = "x-api-key"

    override func setUp() async throws {
        app = Application(.testing)
        app.middleware.use(APIKeyMiddleware()) // Подключаем наш middleware

        // Регистрируем тестовый маршрут
        app.get("test") { req in
            return "Success"
        }
    }

    override func tearDown() async throws {
        app.shutdown()
    }

    /// Тест на выполнение запроса с валидным API-ключом
    func testRequestWithValidApiKey() async throws {
        // Отправляем запрос с валидным API-ключом
        try app.test(.GET, "/test", headers: [headerName: validApiKey]) { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertEqual(res.body.string, "Success") // Убедимся, что получили "Success"
        }
    }

    /// Тест выполнения запроса с отсутствием API-ключа
    func testRequestWithoutApiKey() async throws {
        // Отправляем запрос без API-ключа
        try app.test(.GET, "/test") { res in
            XCTAssertEqual(res.status, .unauthorized) // Убедимся, что статус 401
            let responseBody = try JSONDecoder().decode(ErrorResponse.self, from: res.body)
            XCTAssertEqual(responseBody.statusCode, 401)
            XCTAssertEqual(responseBody.message, "Invalid or missing API Key.")
        }
    }

    /// Тест выполнения запроса с невалидным API-ключом
    func testRequestWithInvalidApiKey() async throws {
        // Отправляем запрос с невалидным API-ключом
        try app.test(.GET, "/test", headers: [headerName: "invalid-api-key"]) { res in
            XCTAssertEqual(res.status, .unauthorized) // Убедимся, что статус 401
            let responseBody = try JSONDecoder().decode(ErrorResponse.self, from: res.body)
            XCTAssertEqual(responseBody.statusCode, 401)
            XCTAssertEqual(responseBody.message, "Invalid or missing API Key.")
        }
    }
}

// MARK: - Вспомогательная структура для парсинга ответа ошибки
private struct ErrorResponse: Content {
    let statusCode: Int
    let message: String
}

