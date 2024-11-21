import Foundation

final class LoginResponseModel: Sendable {
    let accessToken: String
    
    init(accessToken: String) {
        self.accessToken = accessToken
    }
}
