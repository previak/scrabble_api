import Vapor

final class RoomRepositoryImpl: RoomRepository {
    func find(id: UUID, on req: Request) -> EventLoopFuture<Room?> {
        return Room.find(id, on: req.db)
    }
    
    func create(room: Room, on req: Request) -> EventLoopFuture<Room> {
        return room.save(on: req.db).map { room }
    }
    
    func update(room: Room, on req: Request) -> EventLoopFuture<Room> {
        return room.update(on: req.db).map { room }
    }
    
    func delete(id: UUID, on req: Request) -> EventLoopFuture<Void> {
        return Room.find(id, on: req.db).flatMap { room in
            guard let room = room else {
                return req.eventLoop.makeFailedFuture(Abort(.notFound))
            }
            return room.delete(on: req.db)
        }
    }
}
