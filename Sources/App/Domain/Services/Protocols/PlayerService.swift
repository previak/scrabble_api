import Vapor

protocol PlayerService: Sendable {
    func getPlayer(id: UUID, on req: Request) -> EventLoopFuture<PlayerDTO>
    func getPlayerScore(getPlayerScoreRequest: GetPlayerScoreRequestModel, on req: Request) -> EventLoopFuture<GetPlayerScoreResponseModel>
    func createPlayer(createRequest: CreatePlayerRequestModel, on req: Request) -> EventLoopFuture<PlayerDTO>
    func updatePlayer(player: PlayerDTO, on req: Request) -> EventLoopFuture<PlayerDTO>
    func deletePlayer(id: UUID, on req: Request) -> EventLoopFuture<Void>
    func getPlayerTiles(getPlayerTilesRequest: GetPlayerTilesRequestModel, on req: Request) -> EventLoopFuture<GetPlayerTilesResponseModel>
}
