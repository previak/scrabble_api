import Vapor
import Fluent

struct GameController: RouteCollection {
    private let boardService: BoardService
    
    init(boardService: BoardService) {
        self.boardService = boardService
    }
    
    func boot(routes: RoutesBuilder) throws {
        let games = routes.grouped("games")
        games.get("board", use: getBoard)
    }
    
    @Sendable
    func getBoard(req: Request) throws -> EventLoopFuture<BoardDTO> {
//        guard let boardID = req.parameters.get("boardID", as: UUID.self) else {
//            throw Abort(.badRequest, reason: "Missing or invalid board ID.")
//        }
        
        return boardService.getStartingBoard(on: req)
    }
}
