import Foundation

final class CreateRoomRequestModel: Sendable {
    let userId: UUID
    let isOpen: Bool
    let isPublic: Bool
    let adminNickname: String
    
    init(userId: UUID, isOpen: Bool, isPublic: Bool, adminNickname: String) {
        self.userId = userId
        self.isOpen = isOpen
        self.isPublic = isPublic
        self.adminNickname = adminNickname
    }
}
