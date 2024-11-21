import Vapor

final class UserServiceImpl: UserService {
    private let userRepository: UserRepository
    private let API_KEY_PREFIX = "api-key-"
    
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
    
    func register(registerRequest: RegisterRequestModel, on req: Request) -> EventLoopFuture<RegisterResponseModel> {
        return userRepository.findByUsername(username: registerRequest.username, on: req).flatMap { existingUser in
            guard existingUser == nil else {
                return req.eventLoop.makeFailedFuture(Abort(.conflict, reason: "User with such username already exists"))
            }

            let passwordHash: String
            let apiKey: String
            
            do {
                passwordHash = try req.password.hash(registerRequest.password)
                let dataForApiKey = "username: \(registerRequest.username); password: \(registerRequest.password)"
                let dataHash = try req.password.hash(dataForApiKey)
                
                apiKey = self.API_KEY_PREFIX + dataHash
            
            } catch {
                return req.eventLoop.makeFailedFuture(error)
            }

            let user = User(
                username: registerRequest.username,
                passwordHash: passwordHash,
                apiKey: apiKey
            )
            
            return self.userRepository.create(user: user, on: req).flatMap { createdUser in
                let expiration = Date().addingTimeInterval(60 * 60 * 24)
                let payload = UserJWTPayload(
                    id: createdUser.id!,
                    username: createdUser.username,
                    expiration: expiration
                )
                do {
                    let token = try req.jwt.sign(payload)
                    let response = RegisterResponseModel(accessToken: token, apiKey: apiKey)
                    return req.eventLoop.makeSucceededFuture(response)
                } catch {
                    return req.eventLoop.makeFailedFuture(error)
                }
            }
        }
    }
    
    func login(loginRequest: LoginRequestModel, on req: Request) -> EventLoopFuture<LoginResponseModel> {
        return userRepository.findByUsername(username: loginRequest.username, on: req).flatMapThrowing { user in
            guard let user = user else {
                throw Abort(.unauthorized, reason: "Invalid username or password")
            }
                
            guard try req.password.verify(loginRequest.password, created: user.passwordHash) else {
                throw Abort(.unauthorized, reason: "Invalid username or password")
            }
                
            let expiration = Date().addingTimeInterval(60 * 60 * 24)
            let payload = UserJWTPayload(id: user.id!, username: user.username, expiration: expiration)
            return LoginResponseModel(accessToken: try req.jwt.sign(payload))
        }
    }
        
    func authenticate(jwt: String, on req: Request) -> EventLoopFuture<UserDTO> {
        do {
            // Attempt to verify the JWT synchronously
            let payload = try req.jwt.verify(jwt, as: UserJWTPayload.self)
            
            // Use the payload to fetch the user asynchronously
            return self.getUser(id: payload.id, on: req)
            
        } catch {
            return req.eventLoop.makeFailedFuture(error)
        }
    }
}
