import Fluent
import Vapor

public struct RoomDTO: Codable, Sendable {
    var id: UUID?
    var isOpen: Bool
    var isPublic: Bool
    var invitationCode: String
    var gameState: GameState
    var admin: User
    
    func toModel() -> Room {
        let model = Room()
        
        if let id {
            model.id = id
        }
        
        model.isOpen = isOpen
        model.isPublic = isPublic
        model.invitationCode = invitationCode
        model.gameState = gameState
        model.admin = admin
        
        return model
    }
}
