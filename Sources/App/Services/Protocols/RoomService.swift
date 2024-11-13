import Vapor

protocol RoomService {
    func getRoom(id: UUID, on req: Request) -> EventLoopFuture<RoomDTO>
    func createRoom(room: RoomDTO, on req: Request) -> EventLoopFuture<RoomDTO>
    func updateRoom(room: RoomDTO, on req: Request) -> EventLoopFuture<RoomDTO>
    func deleteRoom(id: UUID, on req: Request) -> EventLoopFuture<Void>
}
