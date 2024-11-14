import Vapor
import VaporToOpenAPI

struct BoardController: RouteCollection, Sendable {
    private let boardService: BoardService
    
    init(boardService: BoardService) {
        self.boardService = boardService
    }
    
    func boot(routes: RoutesBuilder) throws {
        let boards = routes.grouped("boards")
        
        boards.get(":id", use: getBoard)
        boards.post(use: createBoard)
        boards.put(":id", use: updateBoard)
        boards.delete(":id", use: deleteBoard)
    }
    
    @Sendable
    func getBoard(req: Request) throws -> EventLoopFuture<BoardDTO> {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Missing or invalid board ID.")
        }
        return boardService.getBoard(id: id, on: req)
    }
    
    @Sendable
    func createBoard(req: Request) throws -> EventLoopFuture<BoardDTO> {
        let board = try req.content.decode(BoardDTO.self)
        return boardService.createBoard(board: board, on: req)
    }
    
    @Sendable
    func updateBoard(req: Request) throws -> EventLoopFuture<BoardDTO> {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Missing or invalid board ID.")
        }
        var board = try req.content.decode(BoardDTO.self)
        board.id = id
        return boardService.updateBoard(board: board, on: req)
    }
    
    @Sendable
    func deleteBoard(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Missing or invalid board ID.")
        }
        return boardService.deleteBoard(id: id, on: req).transform(to: .noContent)
    }
}
