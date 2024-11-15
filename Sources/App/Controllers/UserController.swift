import Vapor

struct UserController: RouteCollection {
    private let userService: UserService
    
    init(userService: UserService) {
        self.userService = userService
    }
    
    func boot(routes: RoutesBuilder) throws {
        let protected = routes.grouped(JWTMiddleware())
        protected.get("users", ":id", use: getUser)
        protected.put("users", ":id", use: updateUser)
        protected.delete("users", ":id", use: deleteUser)
        
        
        let users = routes.grouped("users")
        
        //users.get(":id", use: getUser)
        users.post(use: createUser)
        //users.put(":id", use: updateUser)
        //users.delete(":id", use: deleteUser)
        
        let auth = routes.grouped("auth")
        auth.post("login", use: login)
        auth.post("authenticate", use: authenticate)
    }
    
    func getUser(req: Request) throws -> EventLoopFuture<UserDTO> {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Missing or invalid user ID.")
        }
        return userService.getUser(id: id, on: req)
    }
    
    func createUser(req: Request) throws -> EventLoopFuture<UserDTO> {
        let user = try req.content.decode(UserDTO.self)
        return userService.createUser(user: user, on: req)
    }
    
    func updateUser(req: Request) throws -> EventLoopFuture<UserDTO> {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Missing or invalid user ID.")
        }
        let user = try req.content.decode(UserDTO.self)
        // user.id = id
        return userService.updateUser(user: user, on: req)
    }
    
    func deleteUser(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Missing or invalid user ID.")
        }
        return userService.deleteUser(id: id, on: req).transform(to: .noContent)
    }
    
    func login(req: Request) throws -> EventLoopFuture<String> {
        let credentials = try req.content.decode(LoginCredentials.self)
        return userService.login(username: credentials.username, password: credentials.password, on: req)
    }
    
    func authenticate(req: Request) throws -> EventLoopFuture<UserDTO> {
        let authRequest = try req.content.decode(AuthRequest.self)
        return userService.authenticate(jwt: authRequest.token, on: req)
    }
}

struct LoginCredentials: Content {
    let username: String
    let password: String
}

struct AuthRequest: Content {
    let token: String
}
