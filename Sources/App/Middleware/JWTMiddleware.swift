import Vapor
import JWT

struct JWTMiddleware: AsyncMiddleware {
    func respond(to request: Vapor.Request, chainingTo next: any Vapor.AsyncResponder) async throws -> Vapor.Response {
        guard let bearerToken = request.headers.bearerAuthorization else {
            return await request.errorResponse(
                status: .unauthorized,
                message: "Missing authorization header."
            )
        }

        do {
            let payload = try request.jwt.verify(as: UserJWTPayload.self)
            request.auth.login(payload)
        } catch {
            return await request.errorResponse(
                status: .unauthorized,
                message: "Invalid token."
            )
        }

        return try await next.respond(to: request)
    }
}
