import Vapor

final class GameServiceImpl: GameService {
    private let gameRepository: GameRepository
    
    init(gameRepository: GameRepository) {
        self.gameRepository = gameRepository
    }
    
    func getGame(id: UUID, on req: Request) -> EventLoopFuture<GameDTO> {
        return gameRepository.find(id: id, on: req).flatMapThrowing { game in
            guard let game = game else {
                throw Abort(.notFound)
            }
            return game.toDTO()
        }
    }
    
    func createGame(game: GameDTO, on req: Request) -> EventLoopFuture<GameDTO> {
        let model = game.toModel()
        return gameRepository.create(game: model, on: req).map { $0.toDTO() }
    }
    
    func updateGame(game: GameDTO, on req: Request) -> EventLoopFuture<GameDTO> {
        let model = game.toModel()
        return gameRepository.update(game: model, on: req).map { $0.toDTO() }
    }
}
