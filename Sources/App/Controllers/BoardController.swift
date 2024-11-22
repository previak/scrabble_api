import Vapor
import VaporToOpenAPI

struct BoardController: RouteCollection, Sendable {
    private let boardService: BoardService
    
    init(boardService: BoardService) {
        self.boardService = boardService
    }
    
    func boot(routes: RoutesBuilder) throws {
        let boards = routes.grouped("boards")
        
        boards.post("tile", "place", use: placeTile)
            .openAPI(
                summary: "Place tile",
                description: "Place tile on a board",
                body: .type(PlaceTileRequestDTO.self),
                response: .type(BoardDTO.self),
                auth: .apiKey(), .bearer()
            )
        boards.post("tile", "take-back", use: takeTileBack)
            .openAPI(
                summary: "Take tile back",
                description: "Take tile from the board back",
                body: .type(TakeTileBackRequestDTO.self),
                response: .type(BoardDTO.self),
                auth: .apiKey(), .bearer()
            )
        boards.post(use: getBoard)
            .openAPI(
                summary: "Get board",
                description: "Get board by it's Id",
                body: .type(GetBoardRequestDTO.self),
                response: .type(BoardDTO.self),
                auth: .apiKey(), .bearer()
            )
    }
    
    @Sendable
    func placeTile(req: Request) throws -> EventLoopFuture<BoardDTO> {
        let request = try req.content.decode(PlaceTileRequestDTO.self)
        
        let placeTileRequest = PlaceTileRequestModel(
            boardId: request.boardId,
            letter: request.letter,
            verticalCoord: request.verticalCoord,
            horizontalCoord: request.horizontalCoord
        )
        
        return boardService.placeTile(placeTileRequest: placeTileRequest, on: req)
    }
    
    @Sendable
    func takeTileBack(req: Request) throws -> EventLoopFuture<BoardDTO> {
        let request = try req.content.decode(TakeTileBackRequestDTO.self)
        
        let takeTileBackRequest = TakeTileBackRequestModel(
            boardId: request.boardId,
            verticalCoord: request.verticalCoord,
            horizontalCoord: request.horizontalCoord
        )
        
        return boardService.takeTileBack(takeTileBackRequest: takeTileBackRequest, on: req)
    }
    
    @Sendable
    func getBoard(req: Request) throws -> EventLoopFuture<BoardDTO> {
        let request = try req.content.decode(GetBoardRequestDTO.self)
        
        let getBoardRequest = GetBoardRequestModel(
            boardId: request.boardId
        )
        
        return boardService.getBoard(getBoardRequest: getBoardRequest, on: req)
    }
    
    @Sendable
    func getStartingBoard(req: Request) throws -> EventLoopFuture<BoardDTO> {
        return boardService.getStartingBoard(on: req)
    }
}
