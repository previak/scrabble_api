import Foundation

final class RegisterRequestModel: Sendable {
    let username: String
    let password: String
    
    init(username: String, password: String) {
        self.username = username
        self.password = password
    }
}
