import Fluent
import Vapor

public struct StartGameRequestDTO: Content, Codable, Sendable {
    var roomId: UUID
}
