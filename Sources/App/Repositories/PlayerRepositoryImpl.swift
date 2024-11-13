import Vapor

final class PlayerRepositoryImpl: PlayerRepository {
    func find(id: UUID, on req: Request) -> EventLoopFuture<Player?> {
        return Player.find(id, on: req.db)
    }
    
    func create(player: Player, on req: Request) -> EventLoopFuture<Player> {
        return player.save(on: req.db).map { player }
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
