import Foundation

final class CreateRoomRequest: Sendable {
    let adminUserId: UUID
    let isOpen: Bool
    let isPublic: Bool
    
    init(adminUserId: UUID, isOpen: Bool, isPublic: Bool) {
        self.adminUserId = adminUserId
        self.isOpen = isOpen
        self.isPublic = isPublic
    }
}
