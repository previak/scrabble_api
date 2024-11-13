import Vapor
import Fluent

protocol BoardService {
    func getStartingBoard(on req: Request) -> EventLoopFuture<BoardDTO>
}
