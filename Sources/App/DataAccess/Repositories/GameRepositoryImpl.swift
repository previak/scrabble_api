import Vapor
import Fluent

final class GameRepositoryImpl: GameRepository {
    func find(id: UUID, on req: Request) -> EventLoopFuture<Game?> {
        return Game.find(id, on: req.db)
    }
    
    func findByRoomId(roomId: UUID, on req: Request) -> EventLoopFuture<Game?> {
        return Game.query(on: req.db)
            .filter(\.$room.$id == roomId)
            .first()
    }
    
    func create(game: Game, on req: Request) -> EventLoopFuture<Game> {
        return game.save(on: req.db).map { game }
    }
    
    func update(game: Game, on req: Request) -> EventLoopFuture<Game> {
        return game.update(on: req.db).map { game }
    }
    
    func delete(id: UUID, on req: Request) -> EventLoopFuture<Void> {
        return Game.find(id, on: req.db).flatMap { game in
            guard let game = game else {
                return req.eventLoop.makeFailedFuture(Abort(.notFound))
            }
            return game.delete(on: req.db)
        }
    }
    
    func deleteByRoomId(roomId: UUID, on req: Request) -> EventLoopFuture<Void> {
        return Game.query(on: req.db)
            .filter(\.$room.$id == roomId)
            .all()
            .flatMap { games in
                let deleteFutures = games.map { game in
                    return game.delete(on: req.db)
                }
                
                return deleteFutures.flatten(on: req.eventLoop)
            }
    }
}
