import Fluent
import Vapor

public struct GetLeftTilesNumberResponseDTO: Content, Codable, Sendable {
    let tilesNumber: Int
}

