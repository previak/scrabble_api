import Vapor
import VaporToOpenAPI

struct BoardController: RouteCollection, Sendable {
    private let boardService: BoardService
    private let userService: UserService
    
    init(boardService: BoardService, userService: UserService) {
        self.boardService = boardService
        self.userService = userService
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
                response: .type(BoardDTO.self),
                auth: .apiKey(), .bearer()
            )
    }
    
    @Sendable
    func placeTile(req: Request) throws -> EventLoopFuture<BoardDTO> {
        let request = try req.content.decode(PlaceTileRequestDTO.self)
        
        let authHeader = req.headers.bearerAuthorization!
        let token = authHeader.token
        
        return userService.authenticate(jwt: token, on: req).flatMap { user in
            let placeTileRequest = PlaceTileRequestModel(
                userId: user.id!,
                letter: request.letter,
                verticalCoord: request.verticalCoord,
                horizontalCoord: request.horizontalCoord
            )
            
            return boardService.placeTile(placeTileRequest: placeTileRequest, on: req)
        }
    }
    
    @Sendable
    func takeTileBack(req: Request) throws -> EventLoopFuture<BoardDTO> {
        let request = try req.content.decode(TakeTileBackRequestDTO.self)
        
        let authHeader = req.headers.bearerAuthorization!
        let token = authHeader.token
        
        return userService.authenticate(jwt: token, on: req).flatMap { user in
            let takeTileBackRequest = TakeTileBackRequestModel(
                userId: user.id!,
                verticalCoord: request.verticalCoord,
                horizontalCoord: request.horizontalCoord
            )
            
            return boardService.takeTileBack(takeTileBackRequest: takeTileBackRequest, on: req)
        }
    }
    
    @Sendable
    func getBoard(req: Request) throws -> EventLoopFuture<BoardDTO> {
        let authHeader = req.headers.bearerAuthorization!
        let token = authHeader.token
        
        return userService.authenticate(jwt: token, on: req).flatMap { user in
            let getBoardRequest = GetBoardRequestModel(
                userId: user.id!
            )
            
            return boardService.getBoard(getBoardRequest: getBoardRequest, on: req)
        }
    }
    
    @Sendable
    func getStartingBoard(req: Request) throws -> EventLoopFuture<BoardDTO> {
        return boardService.getStartingBoard(on: req)
    }
}
