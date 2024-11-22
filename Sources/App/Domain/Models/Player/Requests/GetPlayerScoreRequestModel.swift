import Foundation

final class GetPlayerScoreRequestModel {
    let playerId: UUID
    
    init(playerId: UUID) {
        self.playerId = playerId
    }
}
