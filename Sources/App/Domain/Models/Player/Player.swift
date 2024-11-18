import Fluent
import struct Foundation.UUID

final class Player: Model, @unchecked Sendable {
    static let schema = "players"
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: "user_id")
    var user: User
    
    @Parent(key: "room_id")
    var room: Room
    
    @Field(key: "nickname")
    var nickname: String
    
    @Field(key: "score")
    var score: Int
    
    @Field(key: "turn_order")
    var turnOrder: Int
    
    @Field(key: "available_letters")
    var availableLetters: String
    
    init() {}
    
    init(
        id: UUID? = nil,
        userID: UUID,
        roomID: UUID,  // Changed from gameID to roomID
        nickname: String,
        score: Int,
        turnOrder: Int,
        availableLetters: String
    ) {
        self.id = id
        self.$user.id = userID
        self.$room.id = roomID  // Use roomID instead of gameID
        self.nickname = nickname
        self.score = score
        self.turnOrder = turnOrder
        self.availableLetters = availableLetters
    }
    

    func toDTO() -> PlayerDTO {
        .init(id: self.id,
              user: self.user.toDTO(),
              room: self.room.toDTO(),  // Use room instead of game
              nickname: self.nickname,
              score: self.score,
              turnOrder: self.turnOrder,
              availableLetters: self.availableLetters
        )
    }
}
