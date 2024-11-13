import Vapor

final class UserRepositoryImpl: UserRepository {
    func find(id: UUID, on req: Request) -> EventLoopFuture<User?> {
        return User.find(id, on: req.db)
    }
    
    func create(user: User, on req: Request) -> EventLoopFuture<User> {
        return user.save(on: req.db).map { user }
    }
    
    func update(user: User, on req: Request) -> EventLoopFuture<User> {
        return user.update(on: req.db).map { user }
    }
    
    func delete(id: UUID, on req: Request) -> EventLoopFuture<Void> {
        return User.find(id, on: req.db).flatMap { user in
            guard let user = user else {
                return req.eventLoop.makeFailedFuture(Abort(.notFound))
            }
            return user.delete(on: req.db)
        }
    }
}
