import Vapor
import Fluent

final class GameServiceImpl: GameService {
    private let gameRepository: GameRepository
    private let playerRepository: PlayerRepository
    private let roomRepository: RoomRepository
    private let boardService: BoardService
    private let boardRepository: BoardRepository
    
    init(
        gameRepository: GameRepository,
        playerRepository: PlayerRepository,
        roomRepository: RoomRepository,
        boardService: BoardService,
        boardRepository: BoardRepository
    ) {
        self.gameRepository = gameRepository
        self.playerRepository = playerRepository
        self.roomRepository = roomRepository
        self.boardService = boardService
        self.boardRepository = boardRepository
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
        return findPlayer(for: startGameRequest.userId, on: req).flatMap { player in
            guard let player = player else {
                return req.eventLoop.makeFailedFuture(Abort(.notFound, reason: "Player not found"))
            }

            return self.findRoom(for: player.$room.id, on: req).flatMap { room in
                guard let room = room else {
                    return req.eventLoop.makeFailedFuture(Abort(.notFound, reason: "Room not found"))
                }

                guard room.gameState == .forming else {
                    return req.eventLoop.makeFailedFuture(Abort(.badRequest, reason: "Room is not in 'Forming' state"))
                }

                return self.getPlayersInRoom(room, on: req).flatMap { players in
                    return self.initializeGame(with: players, room: room, on: req)
                }
            }
        }
    }
    
    func getLeftTilesNumber(getLeftTilesNumberRequest: GetLeftTilesNumberRequestModel, on req: Request) -> EventLoopFuture<GetLeftTilesNumberResponseModel> {
        
        return playerRepository.findByUserId(userId: getLeftTilesNumberRequest.userId, on: req).flatMap { player in
                guard let player = player else {
                    return req.eventLoop.makeFailedFuture(Abort(.notFound, reason: "Player not found"))
                }

            return self.roomRepository.find(id: player.$room.id, on: req).flatMap { room in
                    guard let room = room else {
                        return req.eventLoop.makeFailedFuture(Abort(.notFound, reason: "Room not found"))
                    }

                return self.gameRepository.findByRoomId(roomId: room.id!, on: req).flatMap { game in
                        guard let game = game else {
                            return req.eventLoop.makeFailedFuture(Abort(.notFound, reason: "Game not found"))
                        }
                        
                        let remainingTilesCount = game.remainingLetters.count

                        let response = GetLeftTilesNumberResponseModel(tilesNumber: remainingTilesCount)
                        return req.eventLoop.makeSucceededFuture(response)
                    }
                }
            }
    }

    private func findPlayer(for userId: UUID, on req: Request) -> EventLoopFuture<Player?> {
        return Player.query(on: req.db)
            .filter(\.$user.$id == userId)
            .first()
    }

    private func findRoom(for roomId: UUID, on req: Request) -> EventLoopFuture<Room?> {
        return Room.find(roomId, on: req.db)
    }

    private func getPlayersInRoom(_ room: Room, on req: Request) -> EventLoopFuture<[Player]> {
        return Player.query(on: req.db)
            .filter(\.$room.$id == room.id!)
            .all()
    }

    private func initializeGame(with players: [Player], room: Room, on req: Request) -> EventLoopFuture<StartGameResponseModel> {
        guard !players.isEmpty else {
            return req.eventLoop.makeFailedFuture(Abort(.badRequest, reason: "No players in the room"))
        }

        let shuffledPlayers = players.shuffled()

        // Set turn orders and initial scores for players
        for (index, player) in shuffledPlayers.enumerated() {
            player.turnOrder = index + 1
            player.score = 0
        }

        return createGame(room: room, players: shuffledPlayers, on: req).flatMap { createdGame in
            return self.assignTilesToPlayers(players: shuffledPlayers, on: req).flatMap { updatedPlayers in
                return self.savePlayers(updatedPlayers, on: req).flatMap {
                    self.updateRoomState(room, on: req).flatMap {
                        self.createBoard(gameId: createdGame.id!, on: req).flatMap { board in
                            return self.generateStartGameResponse(players: updatedPlayers, on: req)
                        }
                    }
                }
            }
        }
    }

    private func createGame(room: Room, players: [Player], on req: Request) -> EventLoopFuture<Game> {
        let gameId = UUID()
        let remainingLetters = generateInitialLetterBag()
        let newGame = Game(id: gameId, roomID: room.id!, isPaused: false, remainingLetters: remainingLetters)

        return self.gameRepository.create(game: newGame, on: req)
    }

    private func assignTilesToPlayers(players: [Player], on req: Request) -> EventLoopFuture<[Player]> {
        return players.reduce(req.eventLoop.makeSucceededFuture([Player]())) { previousFuture, player in
            previousFuture.flatMap { processedPlayers in
                let drawRequest = DrawPlayerTilesRequestModel(userId: player.$user.id, letterCount: 7)
                return self.playerDrawTiles(drawTilesRequest: drawRequest, on: req).map { response in
                    player.availableLetters = response.tiles
                    return processedPlayers + [player] // Append processed player to the result array
                }
            }
        }
    }

    private func savePlayers(_ players: [Player], on req: Request) -> EventLoopFuture<Void> {
        let saveFutures = players.map { $0.save(on: req.db) }
        return saveFutures.flatten(on: req.eventLoop)
    }

    private func updateRoomState(_ room: Room, on req: Request) -> EventLoopFuture<Void> {
        room.gameState = .playing
        return room.save(on: req.db)
    }

    private func createBoard(gameId: UUID, on req: Request) -> EventLoopFuture<Board> {
        return self.boardService.getStartingBoard(on: req).flatMap { boardDTO in
            let newBoard = Board(id: UUID(), gameID: gameId, tiles: self.encodeTilesToString(tiles: boardDTO.tiles))
            return self.boardRepository.create(board: newBoard, on: req)
        }
    }

    private func generateStartGameResponse(players: [Player], on req: Request) -> EventLoopFuture<StartGameResponseModel> {
        let response = StartGameResponseModel(
            players: players.map { player in
                StartGamePlayerInfoModel(
                    turnOrder: player.turnOrder,
                    nickname: player.nickname
                )
            }
        )
        return req.eventLoop.makeSucceededFuture(response)
    }

    // Helper function to encode tiles array to string
    func encodeTilesToString(tiles: [[TileDTO]]) -> String {
        let encoder = JSONEncoder()
        guard let jsonData = try? encoder.encode(tiles) else {
            return "[]"
        }
        return String(data: jsonData, encoding: .utf8) ?? "[]"
    }



    private func generateInitialLetterBag() -> String {
        let letters = "AAAAAAAAABBCCDDDDEEEEEEEEEEEFFGGGHHIIIIIIIIIJKLLLLMMNNNNNNOOOOOOPPQRRRRRRSSSSTTTTTTUUUUVVWWXYYZ"
        return String(letters.shuffled())
    }
}
