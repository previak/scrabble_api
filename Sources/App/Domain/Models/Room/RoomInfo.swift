import Foundation

final class RoomInfoModel: Sendable {
    let invitationCode: String
    let players: Int
    
    init(invitationCode: String, players: Int) {
        self.players = players
        self.invitationCode = invitationCode
    }
}
