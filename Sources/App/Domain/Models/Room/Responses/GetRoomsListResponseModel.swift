import Foundation

final class GetRoomsListResponseModel: Sendable {
    let rooms: [RoomInfoModel]
    
    init(rooms: [RoomInfoModel]) {
        self.rooms = rooms
    }
}
