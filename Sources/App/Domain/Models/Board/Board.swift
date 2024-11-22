import Vapor
import Fluent
import Foundation

final class Board: Model, @unchecked Sendable {
    static let schema = "boards"
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: "game_id")
    var game: Game
    
    @Field(key: "tiles")
    var tiles: String
    
    init() {}
    
    init(
        id: UUID,
        gameID: UUID,
        tiles: String
    ) {
        self.id = id
        self.$game.id = gameID
        self.tiles = tiles
    }
    
    func toDTO() -> BoardDTO? {
        guard let tilesArray = self.getTiles() else { return nil }
        return BoardDTO(
            id: self.id,
            gameId: self.$game.id,
            tiles: tilesArray
        )
    }
    
    
    func getTiles() -> [[TileDTO]]? {
        let decoder = JSONDecoder()
        
        guard let jsonData = self.tiles.data(using: .utf8) else {
            print("Error converting tiles string to data")
            return nil
        }
        
        do {
            let tilesArray = try decoder.decode([[TileDTO]].self, from: jsonData)
            return tilesArray
        } catch {
            print("Error decoding tiles JSON: \(error)")
            return nil
        }
    }
}
