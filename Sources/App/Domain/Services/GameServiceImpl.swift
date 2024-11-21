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
