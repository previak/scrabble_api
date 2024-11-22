import Fluent
import Vapor

public struct LeaveGameResponseDTO: Content, Codable, Sendable {
    var playerCount: Int
}

