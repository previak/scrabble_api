import Foundation

final class GetPlayerTilesRequestModel {
    let playerId: UUID
    
    init(playerId: UUID) {
        self.playerId = playerId
    }
}
