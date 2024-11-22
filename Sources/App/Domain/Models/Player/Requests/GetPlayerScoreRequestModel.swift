import Foundation

final class GetPlayerScoreRequestModel {
    let userId: UUID
    
    init(userId: UUID) {
        self.userId = userId
    }
}
