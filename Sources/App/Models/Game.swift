import Vapor
import Fluent
import struct Foundation.UUID


final class Game: Model, @unchecked Sendable {
    static let schema = "games"
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: "room_id")
    var room: Room
    
    @Field(key: "is_paused")
    var isPaused: Bool
    
    init() {}
    
    init(id: UUID, roomID: UUID, isPaused: Bool) {
        self.id = id
        self.$room.id = roomID
        self.isPaused = isPaused
    }
    
    func toDTO() -> GameDTO {
        .init(
            id: self.id,
            room: self.room.toDTO(),
            isPaused: self.isPaused
        )
    }
}
