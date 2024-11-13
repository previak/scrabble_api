import Fluent
import Vapor

public struct WordDTO: Content, Codable {
    var id: UUID?
    var game: GameDTO
    var player: PlayerDTO
    var word: String
    var startRow: Int
    var startColumn: Int
    var direction: WordDirectionDTO
    
    func toModel() -> Word {
        let model = Word()
        
        if let id = id {
            model.id = id
        }
        
        model.game = game.toModel()
        model.player = player.toModel()
        model.word = word
        model.startRow = startRow
        model.startColumn = startColumn
        model.direction = direction.toModel()
        
        return model
    }
}

