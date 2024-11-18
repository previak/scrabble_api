import Vapor

protocol RoomRepository: Sendable {
    func find(id: UUID, on req: Request) -> EventLoopFuture<Room?>
    func create(createRequest: CreateRoomRequest, on req: Request) -> EventLoopFuture<Room>
    func update(room: Room, on req: Request) -> EventLoopFuture<Room>
    func delete(id: UUID, on req: Request) -> EventLoopFuture<Void>
}
