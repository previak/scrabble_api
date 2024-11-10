import Fluent
import struct Foundation.UUID

final class Player: Model, @unchecked Sendable {
    static let schema = "players"
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: "user_id")
    var user: User

    @Parent(key: "game_id")
    var game: Game
    
    @Field(key: "nickname")
    var nickname: String
    
    @Field(key: "score")
    var score: Int;
    
    @Field(key: "turn_order")
    var turnOrder: Int;
    
    @Field(key: "available_tiles")
    var availableTiles: String;
    
    init() {}
    
    init(
        id: UUID? = nil,
        userID: UUID,
        gameID: UUID,
        nickname: String,
        score: Int,
        turnOrder: Int,
        availabeTiles: String
    ) {
        self.id = id
        self.$user.id = userID
        self.$game.id = gameID
        self.nickname = nickname
        self.score = score
        self.turnOrder = turnOrder
        self.availableTiles = availabeTiles
    }
    
    func toDTO() -> PlayerDTO {
        .init(id: self.id,
              userId: self.$user.id,
              gameId: self.$game.id,
              nickname: self.nickname,
              score: self.score,
              turnOrder: self.turnOrder,
              availableTiles: self.availableTiles
            
        )
    }
}
