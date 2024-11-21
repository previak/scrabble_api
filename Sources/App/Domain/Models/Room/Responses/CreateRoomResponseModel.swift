import Foundation

final class CreateRoomResponseModel: Sendable {
    let adminUserId: UUID
    let roomId: UUID
    let invitationCode: String
    
    init(adminUserId: UUID, roomId: UUID, invitationCode: String) {
        self.adminUserId = adminUserId
        self.roomId = roomId
        self.invitationCode = invitationCode
    }
}
