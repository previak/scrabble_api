import Foundation

final class LeaveGameResponseModel: Sendable {
    var playerCount: Int
    
    init (playerCount: Int) {
        self.playerCount = playerCount
    }
}


