import Vapor
import VaporToOpenAPI

struct GameController: RouteCollection, Sendable {
    private let gameService: GameService
    
    init(gameService: GameService) {
        self.gameService = gameService
    }
    
    func boot(routes: RoutesBuilder) throws {
        let games = routes.grouped("games")
    
        games.post("leave-game", use: leaveGame)
            .openAPI(
                summary: "Leave game",
                description: "Leave game",
                body: .type(LeaveGameRequestDTO.self),
                response: .type(LeaveGameResponseDTO.self),
                auth: .apiKey(), .bearer()
            )
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
