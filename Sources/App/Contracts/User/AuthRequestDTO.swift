import Fluent
import Vapor

public struct AuthRequestDTO: Content, Codable, Sendable {
    let accessToken: String
}
