import Fluent
import Vapor

public struct RoomInfoDTO: Content, Codable, Sendable {
    let invitationCode: String
    let players: Int
}
