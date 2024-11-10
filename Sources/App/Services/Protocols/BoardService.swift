import Vapor
import Fluent

protocol BoardService {
    func getBoard(by id: UUID, on db: Database) -> EventLoopFuture<BoardDTO>
}
