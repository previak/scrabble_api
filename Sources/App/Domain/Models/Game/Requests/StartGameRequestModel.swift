import Foundation

final class StartGameRequestModel: Sendable {
    let userId: UUID
    
    init (userId: UUID) {
        self.userId = userId
    }
}
