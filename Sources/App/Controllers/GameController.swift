import Vapor

struct GameController: RouteCollection, Sendable {
    private let gameService: GameService
    
    init(gameService: GameService) {
        self.gameService = gameService
    }
    
    func boot(routes: RoutesBuilder) throws {
        _ = routes.grouped("games")
    
    }
    
}
