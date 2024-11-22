import Vapor
import Fluent

final class PlayerRepositoryImpl: PlayerRepository {
    func find(id: UUID, on req: Request) -> EventLoopFuture<Player?> {
        return Player.find(id, on: req.db)
    }
    
    func findByUserId(userId: UUID, on req: Request) -> EventLoopFuture<Player?> {
        return Player.query(on: req.db)
            .filter(\.$user.$id, .equal, userId)
            .first()
    }
    
    func findByRoomId(roomId: UUID, on req: Request) -> EventLoopFuture<[Player]> {
        return Player.query(on: req.db)
            .filter(\.$room.$id, .equal, roomId)
            .all()
    }
    
    func findByNicknameAndRoomId(nickname: String, roomId: UUID, on req: Request) -> EventLoopFuture<Player?> {
            return Player.query(on: req.db)
                .filter(\.$nickname == nickname)
                .filter(\.$room.$id == roomId)
                .first()
        }
    
    func create(createRequest: CreatePlayerRequest, on req: Request) -> EventLoopFuture<Player>{
        return req.db.transaction { transaction in
            let userFuture = User.find(createRequest.userId, on: transaction)
            let roomFuture = Room.find(createRequest.roomId, on: transaction)

            return userFuture.and(roomFuture).flatMap { user, room in
                guard let user = user else {
                    return req.db.eventLoop.makeFailedFuture(Abort(.notFound, reason: "User not found"))
                }
                guard let room = room else {
                    return req.db.eventLoop.makeFailedFuture(Abort(.notFound, reason: "Room not found"))
                }


                let player = Player(
                    userID: user.id!,
                    roomID: room.id!,
                    nickname: createRequest.nickname,
                    score: 0,
                    turnOrder: 0,
                    availableLetters: ""
                )

                return player.save(on: transaction).map { player }
            }
        }
    }

    
    func update(player: Player, on req: Request) -> EventLoopFuture<Player> {
        return player.update(on: req.db).map { player }
    }
    
    func delete(id: UUID, on req: Request) -> EventLoopFuture<Void> {
        return Player.find(id, on: req.db).flatMap { player in
            guard let player = player else {
                return req.eventLoop.makeFailedFuture(Abort(.notFound))
            }
            return player.delete(on: req.db)
        }
    }
}
