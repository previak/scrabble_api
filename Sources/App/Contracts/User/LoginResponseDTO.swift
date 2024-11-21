import Fluent
import Vapor

public struct LoginResponseDTO: Content, Codable, Sendable {
    let accessToken: String
}
