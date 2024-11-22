import Foundation

final class DrawPlayerTilesRequestModel : Sendable {
    let userId: UUID
    let letterCount: Int
    
    init (userId: UUID, letterCount: Int) {
        self.userId = userId
        self.letterCount = letterCount
    }
}

