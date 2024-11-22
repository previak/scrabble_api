import Foundation

final class KickPlayerRequestModel: Sendable {
    let adminId: UUID
    let nickname: String
    
    init(adminId: UUID, nickname: String) {
        self.adminId = adminId
        self.nickname = nickname
    }
}
