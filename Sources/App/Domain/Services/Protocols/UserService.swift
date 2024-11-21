import Vapor

protocol UserService: Sendable {
    func getUser(id: UUID, on req: Request) -> EventLoopFuture<UserDTO>
    func createUser(user: UserDTO, on req: Request) -> EventLoopFuture<UserDTO>
    func updateUser(user: UserDTO, on req: Request) -> EventLoopFuture<UserDTO>
    func deleteUser(id: UUID, on req: Request) -> EventLoopFuture<Void>
    func register(registerRequest: RegisterRequestModel, on req: Request) -> EventLoopFuture<RegisterResponseModel>
    func login(loginRequest: LoginRequestModel, on req: Request) -> EventLoopFuture<LoginResponseModel>
    func authenticate(jwt: String, on req: Request) -> EventLoopFuture<UserDTO>
}
