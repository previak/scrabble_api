import Fluent
import Vapor

public struct Response: Content, Codable, Sendable {
    var statusCode: HTTPResponseStatus
    var message: String?
    
    init(statusCode: HTTPResponseStatus, message: String? = nil) {
        self.statusCode = statusCode
        self.message = message
    }
}
