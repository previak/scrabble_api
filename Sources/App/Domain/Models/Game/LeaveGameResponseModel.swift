import Foundation

final class LeaveGameResponseModel: Sendable {
    let playerCount: Int
    
    init (playerCount: Int) {
        self.playerCount = playerCount
    }
}


