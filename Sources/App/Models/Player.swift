import Fluent
import struct Foundation.UUID

final class Player: Model, @unchecked Sendable {
    static let schema = "players"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "user_id")
    var userId: UUID?

    @Field(key: "game_id")
    var gameId: UUID?
    
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
        userId: UUID? = nil,
        gameId: UUID? = nil,
        nickname: String,
        score: Int,
        turnOrder: Int,
        availabeTiles: String
    ) {
        self.id = id
        self.userId = userId
        self.gameId = gameId
        self.nickname = nickname
        self.score = score
        self.turnOrder = turnOrder
        self.availableTiles = availabeTiles
    }
    
    func toDTO() -> PlayerDTO {
        .init(id: self.id,
              userId: self.id,
              gameId: self.gameId,
              nickname: self.nickname,
              score: self.score,
              turnOrder: self.turnOrder,
              availableTiles: self.availableTiles
        )
    }
}
