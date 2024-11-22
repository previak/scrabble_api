import Foundation

final class DrawPlayerTilesRequestModel : Sendable {
    let playerId: UUID
    let gameId: UUID
    let letterCount: Int
    
    init (gameId: UUID, playerId: UUID, letterCount: Int) {
        self.gameId = gameId
        self.playerId = playerId
        self.letterCount = letterCount
    }
}

