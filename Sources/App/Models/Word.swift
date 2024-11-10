import Fluent
import struct Foundation.UUID

final class Word: Model, @unchecked Sendable {
    static let schema = "words"
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: "game_id")
    var game: Game
    
    @Parent(key: "player_id")
    var player: Player
    
    @Field(key: "word")
    var word: String

    @Field(key: "start_row")
    var startRow: Int
    
    @Field(key: "start_column")
    var startColumn: Int
    
    @Field(key: "direction")
    var direction: WordDirection
    
    init() {}
    
    init(
        id: UUID? = nil,
        gameId: UUID,
        playerId: UUID,
        word: String,
        startRow: Int,
        startColumn: Int,
        direction: WordDirection
    ) {
        self.id = id
        self.$game.id = gameId
        self.$player.id = playerId
        self.word = word
        self.startRow = startRow
        self.startColumn = startColumn
        self.direction = direction
    
    }
    
    func toDTO() -> WordDTO {
        .init(id: self.id,
              game: self.game.toDTO(),
              player: self.player.toDTO(),
              word: self.word,
              startRow: self.startRow,
              startColumn: self.startColumn,
              direction: self.direction.toDTO()
        )
    }
}
