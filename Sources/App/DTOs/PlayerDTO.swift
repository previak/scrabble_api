import Fluent
import Vapor

public struct PlayerDTO: Content, Codable, Sendable {
    var id: UUID?
    var user: UserDTO
    var game: GameDTO
    var nickname: String
    var score: Int;
    var turnOrder: Int;
    var availableLetters: String;
    
    func toModel() -> Player {
        let model = Player()
        
        if let id = id {
            model.id = id
        }
        
        model.user = user.toModel()
        model.game = game.toModel()
        
        model.nickname = nickname
        model.score = score
        model.turnOrder = turnOrder
        model.availableLetters = availableLetters
        
        return model
    }
}
