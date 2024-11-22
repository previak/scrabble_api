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
    
    func playerDrawTiles(drawTilesRequest: DrawPlayerTilesRequestModel, on: Request) -> EventLoopFuture<String> {
        let lettersCount = drawTilesRequest.letterCount

        return Game.find(drawTilesRequest.gameId, on: on.db).flatMap { game in
            guard var remainingLetters = game?.remainingLetters, remainingLetters.count >= lettersCount else {
                return on.eventLoop.makeFailedFuture(Abort(.notFound, reason: "Not enough letters available"))
            }

            let drawnLetters = String(remainingLetters.prefix(lettersCount))
            remainingLetters.removeFirst(lettersCount)
            
            game?.remainingLetters = remainingLetters
            let updatePoolFuture = game!.update(on: on.db)
            
            return updatePoolFuture.flatMap {
                return Player.find(drawTilesRequest.playerId, on: on.db).flatMap { player in
                    guard let player = player else {
                        return on.eventLoop.makeFailedFuture(Abort(.notFound))
                    }
                    
                    player.availableLetters += drawnLetters
                    return player.update(on: on.db).map { drawnLetters }
                }
            }
        }
    }
}
