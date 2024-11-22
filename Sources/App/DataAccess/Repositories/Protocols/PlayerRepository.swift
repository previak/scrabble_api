import Vapor

protocol PlayerRepository: Sendable {
    func find(id: UUID, on req: Request) -> EventLoopFuture<Player?>
    func findByUserId(userId: UUID, on req: Request) -> EventLoopFuture<Player?>
    func findByRoomId(roomId: UUID, on req: Request) -> EventLoopFuture<[Player]>
    func create(createRequest: CreatePlayerRequest, on req: Request) -> EventLoopFuture<Player>
    func update(player: Player, on req: Request) -> EventLoopFuture<Player>
    func delete(id: UUID, on req: Request) -> EventLoopFuture<Void>
}
