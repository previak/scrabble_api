import Fluent
import Vapor

public struct RegisterResponseDTO: Content, Codable, Sendable {
    let accessToken: String
    let apiKey: String
}
