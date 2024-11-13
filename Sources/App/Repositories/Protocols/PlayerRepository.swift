import Vapor

protocol PlayerRepository {
    func find(id: UUID, on req: Request) -> EventLoopFuture<Player?>
    func create(player: Player, on req: Request) -> EventLoopFuture<Player>
    func update(player: Player, on req: Request) -> EventLoopFuture<Player>
    func delete(id: UUID, on req: Request) -> EventLoopFuture<Void>
}
