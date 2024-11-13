import Vapor

protocol RoomRepository {
    func find(id: UUID, on req: Request) -> EventLoopFuture<Room?>
    func create(room: Room, on req: Request) -> EventLoopFuture<Room>
    func update(room: Room, on req: Request) -> EventLoopFuture<Room>
    func delete(id: UUID, on req: Request) -> EventLoopFuture<Void>
}
