import Fluent
import Vapor

public struct DrawPlayerTilesRequestDTO: Content, Codable, Sendable {
    let playerId: UUID
    let gameId: UUID
    let letterCount: Int
}

