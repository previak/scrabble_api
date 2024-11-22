import Vapor

protocol GameService: Sendable {
    func getGame(id: UUID, on req: Request) -> EventLoopFuture<GameDTO>
    func createGame(game: GameDTO, on req: Request) -> EventLoopFuture<GameDTO>
    func updateGame(game: GameDTO, on req: Request) -> EventLoopFuture<GameDTO>
    func playerDrawTiles(drawTilesRequest: DrawPlayerTilesRequestModel, on req: Request) -> EventLoopFuture<DrawPlayerTilesResponseModel>
    func leaveGame(leaveGameRequest: LeaveGameRequestModel, on req: Request) -> EventLoopFuture<LeaveGameResponseModel>
    func startGame(startGameRequest: StartGameRequestModel, on req: Request) -> EventLoopFuture<StartGameResponseModel>
    func getLeftTilesNumber(getLeftTilesNumberRequest: GetLeftTilesNumberRequestModel, on req: Request) -> EventLoopFuture<GetLeftTilesNumberResponseModel>
}
