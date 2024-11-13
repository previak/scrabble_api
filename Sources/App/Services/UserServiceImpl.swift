import Vapor

final class UserServiceImpl: UserService {
    private let userRepository: UserRepository
    
    init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }
    
    func getUser(id: UUID, on req: Request) -> EventLoopFuture<UserDTO> {
        return userRepository.findById(id: id, on: req).flatMapThrowing { user in
            guard let user = user else {
                throw Abort(.notFound)
            }
            return user.toDTO()
        }
    }
    
    func createUser(user: UserDTO, on req: Request) -> EventLoopFuture<UserDTO> {
        let model = user.toModel()
        return userRepository.create(user: model, on: req).map { $0.toDTO() }
    }
    
    func updateUser(user: UserDTO, on req: Request) -> EventLoopFuture<UserDTO> {
        let model = user.toModel()
        return userRepository.update(user: model, on: req).map { $0.toDTO() }
    }
    
    func deleteUser(id: UUID, on req: Request) -> EventLoopFuture<Void> {
        return userRepository.delete(id: id, on: req)
    }
    
    func login(username: String, password: String, on req: Request) -> EventLoopFuture<String> {
        return userRepository.findByUsername(username: username, on: req).flatMapThrowing { user in
            guard let user = user else {
                throw Abort(.unauthorized, reason: "Invalid username or password")
            }
                
            guard try req.password.verify(password, created: user.passwordHash) else {
                throw Abort(.unauthorized, reason: "Invalid username or password")
            }
                
            let expiration = Date().addingTimeInterval(60 * 60 * 24) // 1 day
            let payload = UserJWTPayload(id: user.id!, username: user.username, expiration: expiration)
            return try req.jwt.sign(payload)
        }
    }
        
//    func authenticate(jwt: String, on req: Request) -> EventLoopFuture<UserDTO> {
//        return req.jwt.verify(jwt, as: UserJWTPayload.self).flatMap { payload in
//            return self.getUser(id: payload.id, on: req)
//        }
//    }
}
