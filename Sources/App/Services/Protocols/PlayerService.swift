import Vapor

protocol PlayerService {
    func getPlayer(id: UUID, on req: Request) -> EventLoopFuture<PlayerDTO>
    func createPlayer(player: PlayerDTO, on req: Request) -> EventLoopFuture<PlayerDTO>
    func updatePlayer(player: PlayerDTO, on req: Request) -> EventLoopFuture<PlayerDTO>
    func deletePlayer(id: UUID, on req: Request) -> EventLoopFuture<Void>
}
