import Fluent
import Vapor

public struct DrawPlayerTilesRequestDTO: Content, Codable, Sendable {
    let letterCount: Int
}

