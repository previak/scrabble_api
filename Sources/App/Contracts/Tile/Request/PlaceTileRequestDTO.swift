import Fluent
import Vapor

public struct PlaceTileRequestDTO: Content, Codable, Sendable {
    var letter: String
    var verticalCoord: Int
    var horizontalCoord: Int
}
