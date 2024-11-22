import Fluent
import Vapor

public struct GetPlayerTilesResponseDTO: Content, Codable, Sendable {
    let availableLetters: String
}
