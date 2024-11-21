import Foundation

final class JoinRoomRequestModel: Sendable {
    let userId: UUID
    let invitationCode: String
    let nickname: String
    
    init(userId: UUID, invitationCode: String, nickname: String) {
        self.userId = userId
        self.invitationCode = invitationCode
        self.nickname = nickname
    }
}
