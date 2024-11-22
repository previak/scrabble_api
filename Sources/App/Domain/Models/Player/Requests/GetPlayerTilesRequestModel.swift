import Foundation

final class GetPlayerTilesRequestModel {
    let userId: UUID
    
    init(userId: UUID) {
        self.userId = userId
    }
}
