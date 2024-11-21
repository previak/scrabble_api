import Vapor


final class RoomRepositoryImpl: RoomRepository {
    func find(id: UUID, on req: Request) -> EventLoopFuture<Room?> {
        return Room.find(id, on: req.db)
    }
    
    func find(invitationCode: String, on req: Request) -> EventLoopFuture<Room?> {
        
        let res = Room.query(on: req.db).all()
        
        return res.map { rooms in
            rooms.first { $0.invitationCode == invitationCode }
        }
    }
    

    func create(createRequest: CreateRoomRequest, on req: Request) -> EventLoopFuture<Room> {
        return User.find(createRequest.adminUserId, on: req.db).flatMap { adminOptional -> EventLoopFuture<Room> in

            guard adminOptional != nil else {
                return req.eventLoop.makeFailedFuture(
                    Abort(.notFound, reason: "Admin user not found")
                )
            }


            let invitationCode = UUID().uuidString.prefix(6).uppercased()

            let room = Room(
                id: UUID(),
                isOpen: createRequest.isOpen,
                isPublic: createRequest.isPublic,
                invitationCode: String(invitationCode),
                gameState: .forming,
                adminId: createRequest.adminUserId
            )

            return room.save(on: req.db).map { room }
        }
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
