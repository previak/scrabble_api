import Vapor

struct UserController: RouteCollection {
    private let userService: UserService
    
    init(userService: UserService) {
        self.userService = userService
    }
    
    func boot(routes: RoutesBuilder) throws {
        let protected = routes.grouped(JWTMiddleware())

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
