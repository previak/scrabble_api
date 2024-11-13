import Vapor

protocol UserService {
    func getUser(id: UUID, on req: Request) -> EventLoopFuture<UserDTO>
    func createUser(user: UserDTO, on req: Request) -> EventLoopFuture<UserDTO>
    func updateUser(user: UserDTO, on req: Request) -> EventLoopFuture<UserDTO>
    func deleteUser(id: UUID, on req: Request) -> EventLoopFuture<Void>
}
