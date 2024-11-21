import Fluent
import Vapor

public struct JoinRoomRequestDTO: Content, Codable, Sendable {
    var userId: UUID
    var invitationCode: String
    var nickname: String
}
