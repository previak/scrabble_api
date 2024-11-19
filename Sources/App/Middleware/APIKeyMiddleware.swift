import Vapor

struct APIKeyMiddleware: Middleware {
    private let validApiKey = "your-valid-api-key"

    func respond(to request: Request, chainingTo next: Responder) -> EventLoopFuture<Response> {
        let apiKeyHeader = "x-api-key"
        guard let apiKey = request.headers[apiKeyHeader].first, apiKey == validApiKey else {
            return request.eventLoop.makeFailedFuture(Abort(.unauthorized, reason: "Invalid or missing API Key."))
        }

        return next.respond(to: request)
    }
}
