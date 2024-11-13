import Vapor

protocol UserRepository {
    func find(id: UUID, on req: Request) -> EventLoopFuture<User?>
    func create(user: User, on req: Request) -> EventLoopFuture<User>
    func update(user: User, on req: Request) -> EventLoopFuture<User>
    func delete(id: UUID, on req: Request) -> EventLoopFuture<Void>
}
