import Vapor
import VaporToOpenAPI

struct GameController: RouteCollection, Sendable {
    private let gameService: GameService
    private let userService: UserService
    
    init(gameService: GameService, userService: UserService) {
        self.gameService = gameService
        self.userService = userService
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
                response: .type(LeaveGameResponseDTO.self),
                auth: .apiKey(), .bearer()
            )
        
        games.post("start", use: startGame)
            .openAPI(
                summary: "Start game",
                description: "Start game",
                response: .type(Response.self),
                auth: .apiKey(), .bearer()
            )
        games.get("tile", "get-left-number", use: getLeftTilesNumber)
            .openAPI(
                summary: "Get left tiles number",
                description: "Get number of letter tiles left in the bag",
                response: .type(GetPlayerTilesResponseDTO.self),
                auth: .apiKey(), .bearer()
            )
        
    }

    @Sendable
    func playerDrawTiles(req: Request) throws -> EventLoopFuture<DrawPlayerTilesResponseDTO> {
        let request = try req.content.decode(DrawPlayerTilesRequestDTO.self)
        
        let authHeader = req.headers.bearerAuthorization!
        let token = authHeader.token
        
        return userService.authenticate(jwt: token, on: req).flatMap { user in
            let drawTilesRequest = DrawPlayerTilesRequestModel(
                userId: user.id!,
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
    }
    
    @Sendable
    func leaveGame(req: Request) throws -> EventLoopFuture<LeaveGameResponseDTO> {
        let authHeader = req.headers.bearerAuthorization!
        let token = authHeader.token
        
        return userService.authenticate(jwt: token, on: req).flatMap { user in
            let leaveGameRequest = LeaveGameRequestModel(
                userId: user.id!
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
    
    @Sendable
    func startGame(req: Request) throws -> EventLoopFuture<Response> {
        let authHeader = req.headers.bearerAuthorization!
        let token = authHeader.token
    
        return userService.authenticate(jwt: token, on: req).flatMap { user in
            let startGameRequest = StartGameRequestModel(
                userId: user.id!
            )
            
            
            return gameService
                .startGame(startGameRequest: startGameRequest, on: req)
                .map{_ in
                    return Response(statusCode: HTTPResponseStatus.ok)
                }
        }
    }
    
    @Sendable
    func getLeftTilesNumber(req: Request) throws -> EventLoopFuture<GetLeftTilesNumberResponseDTO> {
        
        let authHeader = req.headers.bearerAuthorization!
        let token = authHeader.token
        
        return userService.authenticate(jwt: token, on: req).flatMap { user in
            let getLeftTilesNumberRequest = GetLeftTilesNumberRequestModel(
                userId: user.id!
            )
            
            
            return gameService.getLeftTilesNumber(getLeftTilesNumberRequest: getLeftTilesNumberRequest, on: req)
                .map { responseModel in
                    GetLeftTilesNumberResponseDTO(
                        tilesNumber: responseModel.tilesNumber
                    )
                }
        }
    }
}
