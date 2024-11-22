import Foundation

final class GetLeftTilesNumberRequestModel : Sendable {
    let userId: UUID
    
    init (userId: UUID) {
        self.userId = userId
    }
}

