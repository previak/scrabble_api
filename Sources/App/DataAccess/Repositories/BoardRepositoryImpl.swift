import Vapor

final class BoardRepositoryImpl: BoardRepository {
    func find(id: UUID, on req: Request) -> EventLoopFuture<Board?> {
        return Board.find(id, on: req.db)
    }
    
    func create(board: Board, on req: Request) -> EventLoopFuture<Board> {
        return board.save(on: req.db).map { board }
    }
    
    func update(board: Board, on req: Request) -> EventLoopFuture<Board> {
        return board.update(on: req.db).map { board }
    }
    
    func delete(id: UUID, on req: Request) -> EventLoopFuture<Void> {
        return Board.find(id, on: req.db).flatMap { board in
            guard let board = board else {
                return req.eventLoop.makeFailedFuture(Abort(.notFound))
            }
            return board.delete(on: req.db)
        }
    }
}
