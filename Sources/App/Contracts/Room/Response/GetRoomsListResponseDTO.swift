import Fluent
import Vapor

public struct GetRoomsListResponseDTO: Content, Codable, Sendable {
    let rooms: [RoomInfoDTO]
}
