import Vapor
import Fluent

protocol BoardService: Sendable {
    func placeTile(placeTileRequest: PlaceTileRequestModel, on req: Request) -> EventLoopFuture<BoardDTO>
    func takeTileBack(takeTileBackRequest: TakeTileBackRequestModel, on req: Request) ->
    EventLoopFuture<BoardDTO>
    func getStartingBoard(on req: Request) -> EventLoopFuture<BoardDTO>
    func getBoard(id: UUID, on req: Request) -> EventLoopFuture<BoardDTO>
    func createBoard(board: BoardDTO, on req: Request) -> EventLoopFuture<BoardDTO>
    func updateBoard(board: BoardDTO, on req: Request) -> EventLoopFuture<BoardDTO>
    func deleteBoard(id: UUID, on req: Request) -> EventLoopFuture<Void>
}
