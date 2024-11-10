import Vapor
import Fluent
import struct Foundation.UUID

enum GameState: String, Codable {
    case forming
    case playing
    case finished
}

final class Room: Model, @unchecked Sendable {
    static let schema = "rooms"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "is_open")
    var isOpen: Bool
    
    @Field(key: "is_public")
    var isPublic: Bool
    
    @Field(key: "invitation_code")
    var invitationCode: String
    
    @Enum(key: "game_state")
    var gameState: GameState
    
    @Parent(key: "admin_id")
    var admin: User
    
    init() {}
    
    init(
        id: UUID? = nil,
        isOpen: Bool,
        isPublic: Bool,
        invitationCode: String,
        gameState: GameState,
        adminID: UUID
    ) {
        self.id = id
        self.isOpen = isOpen
        self.isPublic = isPublic
        self.invitationCode = invitationCode
        self.gameState = gameState
        self.$admin.id = adminID
    }
    
    func toDTO() -> RoomDTO {
        .init(
            id: self.id,
            isOpen: self.isOpen,
            isPublic: self.isPublic,
            invitationCode: self.invitationCode,
            gameState: self.gameState,
            admin: self.admin
        )
    }
}
