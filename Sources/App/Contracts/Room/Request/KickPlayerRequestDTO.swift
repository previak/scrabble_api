import Fluent
import Vapor

public struct KickPlayerRequestDTO: Content, Codable, Sendable {
    let nickname: String
}
