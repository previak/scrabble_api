import Fluent
import Vapor

public struct RegisterRequestDTO: Content, Codable, Sendable {
    let username: String
    let password: String
}
