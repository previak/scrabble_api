import Fluent
import Vapor

public struct CreateRoomRequestDTO: Content, Codable, Sendable {
    var userId: UUID
    var isOpen: Bool
    var isPublic: Bool
    var adminNickname: String
}
