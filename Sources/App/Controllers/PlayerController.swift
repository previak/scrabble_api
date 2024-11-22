import Vapor

struct PlayerController: RouteCollection, Sendable {
    private let playerService: PlayerService
    
    init(playerService: PlayerService) {
        self.playerService = playerService
    }
    
    func boot(routes: RoutesBuilder) throws {
        let players = routes.grouped("players")
        
        players.post("get-player-tiles", use: getPlayerTiles)
            .openAPI(
                summary: "Get player tiles",
                description: "Get player tiles",
                body: .type(GetPlayerTilesRequestDTO.self),
                response: .type(GetPlayerTilesResponseDTO.self),
                auth: .apiKey(), .bearer())
        players.post("score", use: getPlayerScore)
            .openAPI(
                summary: "Get player's score",
                description: "Get player's score by his Id",
                body: .type(GetPlayerScoreRequestDTO.self),
                response: .type(GetPlayerScoreResponseDTO.self),
                auth: .apiKey(), .bearer()
            )
    }
    
    @Sendable
    func getPlayerScore(req: Request) throws -> EventLoopFuture<GetPlayerScoreResponseDTO> {
        let request = try req.content.decode(GetPlayerScoreRequestDTO.self)

        let getPlayerScoreRequest = GetPlayerScoreRequestModel(
            playerId: request.playerId
        )
        
        return playerService.getPlayerScore(getPlayerScoreRequest: getPlayerScoreRequest, on: req)
            .map { responseModel in
                GetPlayerScoreResponseDTO(
                    score: responseModel.score
                )
            }
    }
    
    @Sendable
    func getPlayerTiles(req: Request) throws -> EventLoopFuture<GetPlayerTilesResponseDTO> {
        let request = try req.content.decode(GetPlayerTilesRequestDTO.self)
        
        let getPlayerTilesRequest = GetPlayerTilesRequestModel(
            playerId: request.playerId
        )
        
        return playerService.getPlayerTiles(getPlayerTilesRequest: getPlayerTilesRequest, on: req)
            .map{ responseModel in
                GetPlayerTilesResponseDTO(availableLetters: responseModel.availableLetters)
            }
    }
}
