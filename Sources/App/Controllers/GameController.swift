import Vapor

struct GameController: RouteCollection, Sendable {
    private let gameService: GameService
    
    init(gameService: GameService) {
        self.gameService = gameService
    }
    
    func boot(routes: RoutesBuilder) throws {
        let games = routes.grouped("games")
        
        games.get(":id", use: getGame)
        games.post(use: createGame)
        games.put(":id", use: updateGame)
        games.delete(":id", use: deleteGame)
    }
    
    @Sendable
    func getGame(req: Request) throws -> EventLoopFuture<GameDTO> {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Missing or invalid game ID.")
        }
        return gameService.getGame(id: id, on: req)
    }
    
    @Sendable
    func createGame(req: Request) throws -> EventLoopFuture<GameDTO> {
        let game = try req.content.decode(GameDTO.self)
        return gameService.createGame(game: game, on: req)
    }
    
    @Sendable
    func updateGame(req: Request) throws -> EventLoopFuture<GameDTO> {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Missing or invalid game ID.")
        }
        var game = try req.content.decode(GameDTO.self)
        game.id = id
        return gameService.updateGame(game: game, on: req)
    }
    
    @Sendable
    func deleteGame(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Missing or invalid game ID.")
        }
        return gameService.deleteGame(id: id, on: req).transform(to: .noContent)
    }
}
