import Fluent
import Vapor

public struct GameDTO: Content, Sendable, Codable {
    var id: UUID?
    var room: RoomDTO
    var isPaused: Bool
    let remainingLetters: String
    
    func toModel() -> Game {
        let model = Game()
        
        if let id {
            model.id = id
        }
        
        model.room = room.toModel()
        model.isPaused = isPaused
        model.remainingLetters = remainingLetters
        
        return model
    }
}
