import Fluent
import Vapor

public struct DrawPlayerTilesResponseDTO: Content, Codable, Sendable {
    let tiles: String
}

