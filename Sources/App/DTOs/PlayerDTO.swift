import Fluent
import Vapor

public struct PlayerDTO: Codable {
    var id: UUID?
    var userId: UUID?
    var gameId: UUID?
    var nickname: String
    var score: Int;
    var turnOrder: Int;
    var availableTiles: String;
    
    func toModel() -> Player {
        let model = Player()
        
        if let id = id {
            model.id = id
        }
        
        if let userId = userId {
            model.$user.id = userId
        }
        
        if let gameId = gameId {
            model.$game.id = gameId
        }
        
        model.nickname = nickname
        model.score = score
        model.turnOrder = turnOrder
        model.availableTiles = availableTiles
        
        return model
    }
}
