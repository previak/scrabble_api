import Fluent
import Vapor

public struct TakeTileBackRequestDTO: Content, Codable, Sendable {
    var verticalCoord: Int
    var horizontalCoord: Int
}
