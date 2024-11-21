import Fluent
import Vapor

struct TileDTO: Content, Codable, Sendable {
    var modifier: TileModifier
    var letter: String?
}
