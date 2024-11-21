import Fluent
import Vapor

public struct GetPlayerScoreResponseDTO: Content, Codable, Sendable {
    var score: Int
}
