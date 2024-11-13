import Vapor

struct PlayerController: RouteCollection, Sendable {
    private let playerService: PlayerService
    
    init(playerService: PlayerService) {
        self.playerService = playerService
    }
    
    func boot(routes: RoutesBuilder) throws {
        let players = routes.grouped("players")
        
        players.get(":id", use: getPlayer)
        players.post(use: createPlayer)
        players.put(":id", use: updatePlayer)
        players.delete(":id", use: deletePlayer)
    }
    
    @Sendable
    func getPlayer(req: Request) throws -> EventLoopFuture<PlayerDTO> {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Missing or invalid player ID.")
        }
        return playerService.getPlayer(id: id, on: req)
    }
    
    @Sendable
    func createPlayer(req: Request) throws -> EventLoopFuture<PlayerDTO> {
        let player = try req.content.decode(PlayerDTO.self)
        return playerService.createPlayer(player: player, on: req)
    }
    
    @Sendable
    func updatePlayer(req: Request) throws -> EventLoopFuture<PlayerDTO> {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Missing or invalid player ID.")
        }
        var player = try req.content.decode(PlayerDTO.self)
        player.id = id
        return playerService.updatePlayer(player: player, on: req)
    }
    
    @Sendable
    func deletePlayer(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Missing or invalid player ID.")
        }
        return playerService.deletePlayer(id: id, on: req).transform(to: .noContent)
    }
}
