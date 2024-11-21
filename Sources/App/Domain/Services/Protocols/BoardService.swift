import Vapor
import Fluent

protocol BoardService: Sendable {
    func placeTile(placeTileRequest: PlaceTileRequestModel, on req: Request) -> EventLoopFuture<BoardDTO>
    func takeTileBack(takeTileBackRequest: TakeTileBackRequestModel, on req: Request) ->
    EventLoopFuture<BoardDTO>
    func getStartingBoard(on req: Request) -> EventLoopFuture<BoardDTO>
    func getBoard(getBoardRequest: GetBoardRequestModel, on req: Request) -> EventLoopFuture<BoardDTO>
    func updateBoard(board: BoardDTO, on req: Request) -> EventLoopFuture<BoardDTO>
}
