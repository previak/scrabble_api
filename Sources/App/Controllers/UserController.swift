import Vapor

struct UserController: RouteCollection {
    private let userService: UserService
    
    init(userService: UserService) {
        self.userService = userService
    }
    
    func boot(routes: RoutesBuilder) throws {
        let protectedRoutes = routes.grouped(APIKeyMiddleware())
        let protectedUsers = protectedRoutes.grouped("users")
        let auth = routes.grouped("auth")
        
        
        auth.post("register", use: register)
            .openAPI(
                summary: "Register",
                description: "Register a new user and get a JWT token and API token",
                body: .type(RegisterRequestDTO.self),
                response: .type(RegisterResponseDTO.self)
            )
        auth.post("login", use: login)
            .openAPI(
                summary: "Login",
                description: "Login",
                body: .type(LoginRequestDTO.self),
                response: .type(LoginResponseDTO.self)
            )
        auth.post("authenticate", use: authenticate)
            .openAPI(
                summary: "Auth",
                description: "Authenticate",
                body: .type(AuthRequestDTO.self),
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
    func register(req: Request) throws -> EventLoopFuture<RegisterResponseDTO> {
        let registerRequest = try req.content.decode(RegisterRequestDTO.self)
        let requestModel = RegisterRequestModel(
            username: registerRequest.username,
            password: registerRequest.password
        )
        
        return userService.register(registerRequest: requestModel, on: req).flatMap { response in
            let responseDTO = RegisterResponseDTO(
                accessToken: response.accessToken,
                apiKey: response.apiKey
            )
            return req.eventLoop.makeSucceededFuture(responseDTO)
        }
    }
    
    @Sendable
    func login(req: Request) throws -> EventLoopFuture<LoginResponseDTO> {
        let loginRequest = try req.content.decode(LoginRequestDTO.self)
        let requestModel = LoginRequestModel(
            username: loginRequest.username,
            password: loginRequest.password
        )
        
        return userService.login(loginRequest: requestModel, on: req).flatMap {response in
            let responseDTO = LoginResponseDTO(accessToken: response.accessToken)
            return req.eventLoop.makeSucceededFuture(responseDTO)
        }
    }
    
    @Sendable
    func authenticate(req: Request) throws -> EventLoopFuture<UserDTO> {
        let authRequest = try req.content.decode(AuthRequestDTO.self)
        return userService.authenticate(jwt: authRequest.accessToken, on: req)
    }
}
