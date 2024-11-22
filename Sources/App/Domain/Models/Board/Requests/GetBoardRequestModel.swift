import Foundation

final class GetBoardRequestModel {
    var userId: UUID
    
    init (userId: UUID) {
        self.userId = userId
    }
}

