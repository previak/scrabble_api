import Fluent
import Vapor

public struct CreateRoomRequestDTO: Content, Codable, Sendable {
    var isOpen: Bool
    var isPublic: Bool
    var adminNickname: String
}
