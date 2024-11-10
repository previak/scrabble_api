import Fluent
import Vapor

struct BoardDTO: Content {
    var id: UUID?
    var game: Game?
    var tiles: [[TileDTO]]
    
    func toModel() -> Board {
        let model = Board()
        
        model.id = self.id
        if let game = game {
            model.game = game
        }
        
        if let tiles = tilesToJSONString(tiles: tiles) {
            model.tiles = tiles
        }
       
        return model
    }
    
    func tilesToJSONString(tiles: [[TileDTO]]) -> String? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        do {
            let jsonData = try encoder.encode(tiles)
            let jsonString = String(data: jsonData, encoding: .utf8)
            return jsonString
        } catch {
            print("Error encoding tiles: \(error)")
            return nil
        }
    }
}
