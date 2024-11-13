import Fluent
import Vapor

public struct UserDTO: Content, Codable, Sendable {
    var id: UUID?
    var username: String
    var passwordHash: String
    var apiKey: String
    
    func toModel() -> User {
        let model = User()
        
        if let id = id {
            model.id = id
        }
        
        model.username = username
        model.passwordHash = passwordHash
        model.apiKey = apiKey
        
        return model
    }
}
