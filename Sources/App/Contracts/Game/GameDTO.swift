import Fluent
import Vapor

public struct GameDTO: Content, Sendable {
    var id: UUID?
    var room: RoomDTO
    var isPaused: Bool
    
    func toModel() -> Game {
        let model = Game()
        
        if let id {
            model.id = id
        }
        
        model.room = room.toModel()
        model.isPaused = isPaused
        
        return model
    }
}
