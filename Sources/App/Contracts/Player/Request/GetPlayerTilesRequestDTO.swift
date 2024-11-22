import Fluent
import Vapor

public struct GetPlayerTilesRequestDTO: Content, Codable, Sendable {
    var playerId: UUID
}
