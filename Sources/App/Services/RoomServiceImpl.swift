import Vapor

final class RoomServiceImpl: RoomService {
    private let roomRepository: RoomRepository
    
    init(roomRepository: RoomRepository) {
        self.roomRepository = roomRepository
    }
    
    func getRoom(id: UUID, on req: Request) -> EventLoopFuture<RoomDTO> {
        return roomRepository.find(id: id, on: req).flatMapThrowing { room in
            guard let room = room else {
                throw Abort(.notFound)
            }
            return room.toDTO()
        }
    }
    
    func createRoom(room: RoomDTO, on req: Request) -> EventLoopFuture<RoomDTO> {
        let model = room.toModel()
        return roomRepository.create(room: model, on: req).map { $0.toDTO() }
    }
    
    func updateRoom(room: RoomDTO, on req: Request) -> EventLoopFuture<RoomDTO> {
        let model = room.toModel()
        return roomRepository.update(room: model, on: req).map { $0.toDTO() }
    }
    
    func deleteRoom(id: UUID, on req: Request) -> EventLoopFuture<Void> {
        return roomRepository.delete(id: id, on: req)
    }
}
