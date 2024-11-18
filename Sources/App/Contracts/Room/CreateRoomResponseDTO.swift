import Fluent
import Vapor

public struct CreateRoomResponseDTO: Content, Codable, Sendable {
    var adminUserId: UUID
    var invitationCode: String
}
