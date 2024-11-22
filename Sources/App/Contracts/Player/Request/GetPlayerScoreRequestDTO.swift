import Fluent
import Vapor

public struct GetPlayerScoreRequestDTO: Content, Codable, Sendable {
    var playerId: UUID
}
