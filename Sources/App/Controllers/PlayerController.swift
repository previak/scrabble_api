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
                body: .type(UUID.self),
                response: .type(GetPlayerTilesResponseDTO.self),
                auth: .apiKey(), .bearer())
        players.get("score", use: getPlayerScore)
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
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Missing or invalid player ID.")
        }
        return playerService.getPlayerTiles(id: id, on: req).map{tiles in
            GetPlayerTilesResponseDTO(availableLetters: tiles)}
    }
}
