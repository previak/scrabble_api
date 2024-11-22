import Fluent
import Vapor

public struct JoinRoomRequestDTO: Content, Codable, Sendable {
    var invitationCode: String
    var nickname: String
}
