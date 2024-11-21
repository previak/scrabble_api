import Vapor

struct APIKeyMiddleware: AsyncMiddleware {
    private let validApiKey = "your-valid-api-key"

    func respond(to request: Vapor.Request, chainingTo next: any Vapor.AsyncResponder) async throws -> Vapor.Response {
        let apiKeyHeader = "x-api-key"
        guard let apiKey = request.headers[apiKeyHeader].first, apiKey == validApiKey else {
            return await request.errorResponse(
                status: .unauthorized,
                message: "Invalid or missing API Key."
            )
        }

        return try await next.respond(to: request)
    }
}

extension Request {
    func errorResponse(status: HTTPResponseStatus, message: String?) async -> Vapor.Response {
        let errorPayload = Response(statusCode: status, message: message)
        let response = Vapor.Response(status: status)
        do {
            response.body = try .init(data: JSONEncoder().encode(errorPayload))
        } catch {
            response.body = .init(string: "{\"statusCode\": \(status.code), \"message\": \"\(message ?? "An error occurred")\"}")
        }
        response.headers.contentType = .json
        return response
    }
}

