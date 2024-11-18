import Vapor

final class GameRepositoryImpl: GameRepository {
    func find(id: UUID, on req: Request) -> EventLoopFuture<Game?> {
        return Game.find(id, on: req.db)
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
}
