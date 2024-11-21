import Fluent
import Vapor

public struct GetBoardRequestDTO: Content, Codable, Sendable {
    var boardId: UUID
}

