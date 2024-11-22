import Foundation

final class StartGameRequestModel: Sendable {
    let roomId: UUID
    
    init (roomId: UUID) {
        self.roomId = roomId
    }
}
