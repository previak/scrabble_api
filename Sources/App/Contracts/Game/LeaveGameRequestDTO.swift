import Fluent
import Vapor

public struct LeaveGameRequestDTO: Content, Codable, Sendable {
    var userId: UUID
}
