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
    
    func startGame(startGameRequest: StartGameRequestModel, on req: Request) -> EventLoopFuture<StartGameResponseModel> {
        return Room.find(startGameRequest.roomId, on: req.db).flatMap { room in
            guard let room = room else {
                return req.eventLoop.makeFailedFuture(Abort(.notFound, reason: "Room not found"))
            }
            
            guard room.gameState == .forming else {
                return req.eventLoop.makeFailedFuture(Abort(.badRequest, reason: "Room is not in 'Forming' state"))
            }
            
            return Player.query(on: req.db).filter(\.$room.$id == room.id!).all().flatMap { players in
                guard !players.isEmpty else {
                    return req.eventLoop.makeFailedFuture(Abort(.badRequest, reason: "No players in the room"))
                }
                
                let shuffledPlayers = players.shuffled()
                for (index, player) in shuffledPlayers.enumerated() {
                    player.turnOrder = index + 1
                    player.score = 0
                }
                
                let gameId = UUID()
                let remainingLetters = self.generateInitialLetterBag()
                let newGame = Game(id: gameId, roomID: room.id!, isPaused: false, remainingLetters: remainingLetters)
                
                return self.gameRepository.create(game: newGame, on: req).flatMap { createdGame in
                    // Sequentially process players to draw tiles
                    shuffledPlayers.reduce(req.eventLoop.makeSucceededFuture([Player]())) { previousFuture, player in
                        previousFuture.flatMap { processedPlayers in
                            let drawRequest = DrawPlayerTilesRequestModel(gameId: gameId, playerId: player.id!, letterCount: 7)
                            return self.playerDrawTiles(drawTilesRequest: drawRequest, on: req).map { response in
                                player.availableLetters = response.tiles
                                return processedPlayers + [player] // Append processed player to the result array
                            }
                        }
                    }.flatMap { updatedPlayers in
                        // Save all updated players
                        let saveFutures = updatedPlayers.map { $0.save(on: req.db) }
                        return saveFutures.flatten(on: req.eventLoop).flatMap {
                            room.gameState = .playing
                            return room.save(on: req.db).map {
                                let response = StartGameResponseModel(
                                    players: updatedPlayers.map { player in
                                        StartGamePlayerInfoModel(
                                            turnOrder: player.turnOrder,
                                            nickname: player.nickname
                                        )
                                    }
                                )
                                return response
                            }
                        }
                    }
                }

            }
        }
    }


    private func generateInitialLetterBag() -> String {
        let letters = "AAAAAAAAABBCCDDDDEEEEEEEEEEEFFGGGHHIIIIIIIIIJKLLLLMMNNNNNNOOOOOOPPQRRRRRRSSSSTTTTTTUUUUVVWWXYYZ"
        return String(letters.shuffled())
    }
}
