import Foundation

final class RegisterResponseModel: Sendable {
    let accessToken: String
    let apiKey: String
    
    init(accessToken: String, apiKey: String) {
        self.accessToken = accessToken
        self.apiKey = apiKey
    }
}
