import Vapor
import JWT

struct JWTMiddleware: AsyncMiddleware {

    
    func respond(to request: Vapor.Request, chainingTo next: any Vapor.AsyncResponder) async
    throws -> Vapor.Response {
        guard let authHeader = request.headers.bearerAuthorization else {
            throw Abort(.unauthorized, reason: "Missing authorization header")
        }
        
        do {
            let payload = try request.jwt.verify(as: UserJWTPayload.self)
            request.auth.login(payload)
        } catch {
            throw Abort(.unauthorized, reason: "Invalid token")
        }
        
        return try await next.respond(to: request)
    }
}
