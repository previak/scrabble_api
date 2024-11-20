import Vapor

protocol UserRepository: Sendable {
    func findById(id: UUID, on req: Request) -> EventLoopFuture<User?>
    func findByUsername(username: String, on req: Request) -> EventLoopFuture<User?>
    func create(user: User, on req: Request) -> EventLoopFuture<User>
    func update(user: User, on req: Request) -> EventLoopFuture<User>
    func delete(id: UUID, on req: Request) -> EventLoopFuture<Void>
}
