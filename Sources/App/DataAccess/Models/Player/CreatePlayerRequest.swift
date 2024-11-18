import Foundation

final class CreatePlayerRequest: Sendable {
    let userId: UUID
    let roomId: UUID
    let nickname: String
    
    init(userId: UUID, roomId: UUID, nickname: String) {
        self.userId = userId
        self.roomId = roomId
        self.nickname = nickname
    }
}
