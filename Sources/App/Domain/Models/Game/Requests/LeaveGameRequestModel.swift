import Foundation

final class LeaveGameRequestModel {
    var userId: UUID
    
    init (userId: UUID) {
        self.userId = userId
    }
}
