import Vapor

struct GameController: RouteCollection, Sendable {
    private let gameService: GameService
    
    init(gameService: GameService) {
        self.gameService = gameService
    }
    
    func boot(routes: RoutesBuilder) throws {
        let games = routes.grouped("games")

        games.post("player-draw-tiles", use: playerDrawTiles)
            .openAPI(
                summary: "Draw tiles for player",
                description: "Draw tiles for player",
                body: .type(DrawPlayerTilesRequestDTO.self),
                response: .type(String.self),
                auth: .apiKey(), .bearer()
            )
    }

    @Sendable
    func playerDrawTiles(req: Request) throws -> EventLoopFuture<String> {
        let request = try req.content.decode(DrawPlayerTilesRequestDTO.self)
        
        let drawTilesRequest = DrawPlayerTilesRequestModel(
            gameId: request.gameId,
            playerId: request.playerId,
            letterCount: request.letterCount
        )
        
        return gameService.playerDrawTiles(drawTilesRequest: drawTilesRequest, on: req)
    }
    
    
}
