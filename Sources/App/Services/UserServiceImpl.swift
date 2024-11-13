import Vapor

final class UserServiceImpl: UserService {
    private let userRepository: UserRepository
    
    init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }
    
    func getUser(id: UUID, on req: Request) -> EventLoopFuture<UserDTO> {
        return userRepository.find(id: id, on: req).flatMapThrowing { user in
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
}
