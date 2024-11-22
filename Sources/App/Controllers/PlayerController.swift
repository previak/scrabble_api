import Vapor

struct PlayerController: RouteCollection, Sendable {
    private let playerService: PlayerService
    private let userService: UserService
    
    init(playerService: PlayerService, userService: UserService) {
        self.playerService = playerService
        self.userService = userService
    }
    
    func boot(routes: RoutesBuilder) throws {
        let players = routes.grouped("players")
        
        players.get("get-tiles", use: getPlayerTiles)
            .openAPI(
                summary: "Get player tiles",
                description: "Get player tiles",
                response: .type(GetPlayerTilesResponseDTO.self),
                auth: .apiKey(), .bearer())
        players.get("score", use: getPlayerScore)
            .openAPI(
                summary: "Get player's score",
                description: "Get player's score",
                response: .type(GetPlayerScoreResponseDTO.self),
                auth: .apiKey(), .bearer()
            )
    }
    
    @Sendable
    func getPlayerScore(req: Request) throws -> EventLoopFuture<GetPlayerScoreResponseDTO> {
        let authHeader = req.headers.bearerAuthorization!
        let token = authHeader.token
        
        return userService.authenticate(jwt: token, on: req).flatMap { user in
            let getPlayerScoreRequest = GetPlayerScoreRequestModel(
                userId: user.id!
            )
            
            return playerService.getPlayerScore(getPlayerScoreRequest: getPlayerScoreRequest, on: req)
                .map { responseModel in
                    GetPlayerScoreResponseDTO(
                        score: responseModel.score
                    )
                }
        }
    }
    
    @Sendable
    func getPlayerTiles(req: Request) throws -> EventLoopFuture<GetPlayerTilesResponseDTO> {
        let authHeader = req.headers.bearerAuthorization!
        let token = authHeader.token
        
        return userService.authenticate(jwt: token, on: req).flatMap { user in
            let getPlayerTilesRequest = GetPlayerTilesRequestModel(
                userId: user.id!
            )
            
            return playerService.getPlayerTiles(getPlayerTilesRequest: getPlayerTilesRequest, on: req)
                .map{ responseModel in
                    GetPlayerTilesResponseDTO(availableLetters: responseModel.availableLetters)
                }
        }
    }
}
