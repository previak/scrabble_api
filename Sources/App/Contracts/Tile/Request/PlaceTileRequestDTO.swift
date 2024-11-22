import Fluent
import Vapor

public struct PlaceTileRequestDTO: Content, Codable, Sendable {
    var boardId: UUID
    var letter: String
    var verticalCoord: Int
    var horizontalCoord: Int
}
