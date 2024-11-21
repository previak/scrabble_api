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
 
        users.post(use: createUser)

        let auth = routes.grouped("auth")
        auth.post("register", use: register)
            .openAPI(
                summary: "Register",
                description: "Register a new user and get a JWT token",
                body: .type(RegisterRequest.self),
                response: .type(String.self),
                auth: .apiKey()
            )
        auth.post("login", use: login)
            .openAPI(
                summary: "Login",
                description: "Login",
                body: .type(LoginCredentials.self),
                response: .type(String.self),
                auth: .apiKey()
            )
        auth.post("authenticate", use: authenticate)
            .openAPI(
                summary: "Auth",
                description: "Authenticate",
                body: .type(AuthRequest.self),
                response: .type(UserDTO.self),
                auth: .apiKey()
            )
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
        guard req.parameters.get("id", as: UUID.self) != nil else {
            throw Abort(.badRequest, reason: "Missing or invalid user ID.")
        }
        let user = try req.content.decode(UserDTO.self)
        return userService.updateUser(user: user, on: req)
    }
    
    @Sendable
    func deleteUser(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Missing or invalid user ID.")
        }
        return userService.deleteUser(id: id, on: req).transform(to: .noContent)
    }
    
    @Sendable
    func register(req: Request) throws -> EventLoopFuture<String> {
        let registerRequest = try req.content.decode(RegisterRequest.self)
        return userService.register(username: registerRequest.username, password: registerRequest.password, on: req)
    }
    
    @Sendable
    func login(req: Request) throws -> EventLoopFuture<String> {
        let credentials = try req.content.decode(LoginCredentials.self)
        return userService.login(username: credentials.username, password: credentials.password, on: req)
    }
    
    @Sendable
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

struct RegisterRequest: Content {
    let username: String
    let password: String
}
