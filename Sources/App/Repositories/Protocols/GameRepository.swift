import Vapor

protocol GameRepository {
    func find(id: UUID, on req: Request) -> EventLoopFuture<Game?>
    func create(game: Game, on req: Request) -> EventLoopFuture<Game>
    func update(game: Game, on req: Request) -> EventLoopFuture<Game>
    func delete(id: UUID, on req: Request) -> EventLoopFuture<Void>
}
