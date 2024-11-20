import Vapor

protocol BoardRepository: Sendable {
    func find(id: UUID, on req: Request) -> EventLoopFuture<Board?>
    func create(board: Board, on req: Request) -> EventLoopFuture<Board>
    func update(board: Board, on req: Request) -> EventLoopFuture<Board>
    func delete(id: UUID, on req: Request) -> EventLoopFuture<Void>
}
