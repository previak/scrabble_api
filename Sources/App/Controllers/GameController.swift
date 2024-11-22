import Vapor
import VaporToOpenAPI

struct GameController: RouteCollection, Sendable {
    private let gameService: GameService
    
    init(gameService: GameService) {
        self.gameService = gameService
    }
    
    func boot(routes: RoutesBuilder) throws {
        let games = routes.grouped("games")

        games.post("tile", "draw", use: playerDrawTiles)
            .openAPI(
                summary: "Draw tiles for player",
                description: "Draw tiles for player",
                body: .type(DrawPlayerTilesRequestDTO.self),
                response: .type(DrawPlayerTilesResponseDTO.self),
                auth: .apiKey(), .bearer()
            )
        
        games.post("leave", use: leaveGame)
            .openAPI(
                summary: "Leave game",
                description: "Leave game",
                body: .type(LeaveGameRequestDTO.self),
                response: .type(LeaveGameResponseDTO.self),
                auth: .apiKey(), .bearer()
            )
    }

    @Sendable
    func playerDrawTiles(req: Request) throws -> EventLoopFuture<DrawPlayerTilesResponseDTO> {
        let request = try req.content.decode(DrawPlayerTilesRequestDTO.self)
        
        let drawTilesRequest = DrawPlayerTilesRequestModel(
            gameId: request.gameId,
            playerId: request.playerId,
            letterCount: request.letterCount
        )
        
        return gameService
            .playerDrawTiles(drawTilesRequest: drawTilesRequest, on: req)
            .map { responseModel in
                DrawPlayerTilesResponseDTO(
                    tiles: responseModel.tiles
                )
            }
    }
    
    @Sendable
    func leaveGame(req: Request) throws -> EventLoopFuture<LeaveGameResponseDTO> {
        let request = try req.content.decode(LeaveGameRequestDTO.self)
        
        let leaveGameRequest = LeaveGameRequestModel(
            userId: request.userId
        )
        
        return gameService
            .leaveGame(leaveGameRequest: leaveGameRequest, on: req)
            .map { responseModel in
                LeaveGameResponseDTO(
                    playerCount: responseModel.playerCount
                )
            }
    }
    
    
}
