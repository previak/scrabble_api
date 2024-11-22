import Vapor
import Fluent

final class GameServiceImpl: GameService {
    private let gameRepository: GameRepository
    private let playerRepository: PlayerRepository
    private let roomRepository: RoomRepository
    
    init(gameRepository: GameRepository, playerRepository: PlayerRepository, roomRepository: RoomRepository) {
        self.gameRepository = gameRepository
        self.playerRepository = playerRepository
        self.roomRepository = roomRepository
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
    
    func playerDrawTiles(drawTilesRequest: DrawPlayerTilesRequestModel, on req: Request) -> EventLoopFuture<DrawPlayerTilesResponseModel> {
        let lettersCount = drawTilesRequest.letterCount

        return playerRepository.findByUserId(userId: drawTilesRequest.userId, on: req).flatMap { player in
            guard let player = player else {
                return req.eventLoop.makeFailedFuture(Abort(.notFound, reason: "Player not found"))
            }

            return self.roomRepository.findByPlayer(player, on: req).flatMap { room in
                guard let room = room else {
                    return req.eventLoop.makeFailedFuture(Abort(.notFound, reason: "Room not found"))
                }

                return self.gameRepository.findByRoomId(roomId: room.id!, on: req).flatMap { game in
                    guard var remainingLetters = game?.remainingLetters, remainingLetters.count >= lettersCount else {
                        return req.eventLoop.makeFailedFuture(Abort(.notFound, reason: "Not enough letters available"))
                    }

                    let drawnLetters = String(remainingLetters.prefix(lettersCount))
                    remainingLetters.removeFirst(lettersCount)

                    game?.remainingLetters = remainingLetters
                    let updatePoolFuture = game!.update(on: req.db)

                    return updatePoolFuture.flatMap {
                        player.availableLetters += drawnLetters
                        return player.update(on: req.db).map {
                            DrawPlayerTilesResponseModel(tiles: drawnLetters)
                        }
                    }
                }
            }
        }
    }
    
    func leaveGame(leaveGameRequest: LeaveGameRequestModel, on req: Request) -> EventLoopFuture<LeaveGameResponseModel> {
        let userId = leaveGameRequest.userId
        
        return self.playerRepository.findByUserId(userId: userId, on: req).flatMap { player in
            guard let player = player else {
                return req.eventLoop.makeFailedFuture(Abort(.notFound, reason: "Player not found"))
            }
            
            let roomId = player.$room.id
            
            return self.playerRepository.delete(id: player.id!, on: req).flatMap {
                self.playerRepository.findByRoomId(roomId: roomId, on: req).flatMap { players in
                    if players.isEmpty {
                        return self.roomRepository.find(id: roomId, on: req).flatMap { room in
                            guard let room = room else {
                                return req.eventLoop.makeFailedFuture(Abort(.notFound, reason: "Room not found"))
                            }
                            room.gameState = .finished
                            return self.roomRepository.update(room: room, on: req).map {_ in
                                LeaveGameResponseModel(playerCount: 0)
                            }
                        }
                    } else {
                        return req.eventLoop.makeSucceededFuture(LeaveGameResponseModel(playerCount: players.count - 1))
                    }
                }
            }
        }
    }
}
