import Fluent
import Vapor

public struct LoginRequestDTO: Content, Codable, Sendable {
    let username: String
    let password: String
}
