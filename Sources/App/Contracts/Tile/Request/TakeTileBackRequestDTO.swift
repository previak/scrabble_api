import Fluent
import Vapor

public struct TakeTileBackRequestDTO: Content, Codable, Sendable {
    var boardId: UUID
    var verticalCoord: Int
    var horizontalCoord: Int
}
