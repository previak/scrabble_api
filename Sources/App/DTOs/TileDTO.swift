import Fluent
import Vapor

struct TileDTO: Content, Codable {
    var modifier: TileModifier
    var letter: String?
}
