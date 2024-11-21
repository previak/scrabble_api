import Vapor

final class PlayerServiceImpl: PlayerService {
    private let playerRepository: PlayerRepository
    
    init(playerRepository: PlayerRepository) {
        self.playerRepository = playerRepository
    }
    
    func getPlayer(id: UUID, on req: Request) -> EventLoopFuture<PlayerDTO> {
        return playerRepository.find(id: id, on: req).flatMapThrowing { player in
            guard let player = player else {
                throw Abort(.notFound)
            }
            return player.toDTO()
        }
    }
    
    func getPlayerScore(getPlayerScoreRequest: GetPlayerScoreRequestModel, on req: Request) -> EventLoopFuture<GetPlayerScoreResponseModel> {

        let playerId = getPlayerScoreRequest.playerId
        
        return playerRepository.find(id: playerId, on: req).flatMapThrowing { player in
            guard let player = player else {
                throw Abort(.notFound)
            }
            
            let response = GetPlayerScoreResponseModel(score: player.score)
            return response
        }
    }
    
    func createPlayer(
        createRequest: CreatePlayerRequestModel,
        on req: Request) -> EventLoopFuture<PlayerDTO> {
        let createPlayerRequest = CreatePlayerRequest(
            userId: createRequest.userId,
            roomId: createRequest.roomId,
            nickname: createRequest.nickname)
            
        return playerRepository.create(
            createRequest: createPlayerRequest,
            on: req
        ).map { $0.toDTO() }
    }
    
    func updatePlayer(player: PlayerDTO, on req: Request) -> EventLoopFuture<PlayerDTO> {
        let model = player.toModel()
        return playerRepository.update(player: model, on: req).map { $0.toDTO() }
    }
    
    func deletePlayer(id: UUID, on req: Request) -> EventLoopFuture<Void> {
        return playerRepository.delete(id: id, on: req)
    }
}
