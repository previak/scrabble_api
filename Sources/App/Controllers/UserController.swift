import Vapor

struct UserController: RouteCollection, Sendable {
    private let userService: UserService
    
    init(userService: UserService) {
        self.userService = userService
    }
    
    func boot(routes: RoutesBuilder) throws {
        let users = routes.grouped("users")
        
        users.get(":id", use: getUser)
        users.post(use: createUser)
        users.put(":id", use: updateUser)
        users.delete(":id", use: deleteUser)
    }
    
    @Sendable
    func getUser(req: Request) throws -> EventLoopFuture<UserDTO> {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Missing or invalid user ID.")
        }
        return userService.getUser(id: id, on: req)
    }
    
    @Sendable
    func createUser(req: Request) throws -> EventLoopFuture<UserDTO> {
        let user = try req.content.decode(UserDTO.self)
        return userService.createUser(user: user, on: req)
    }
    
    @Sendable
    func updateUser(req: Request) throws -> EventLoopFuture<UserDTO> {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Missing or invalid user ID.")
        }
        var user = try req.content.decode(UserDTO.self)
        user.id = id
        return userService.updateUser(user: user, on: req)
    }
    
    @Sendable
    func deleteUser(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Missing or invalid user ID.")
        }
        return userService.deleteUser(id: id, on: req).transform(to: .noContent)
    }
}
