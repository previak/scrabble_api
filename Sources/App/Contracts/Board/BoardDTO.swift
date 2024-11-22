import Fluent
import Vapor

struct BoardDTO: Content, Sendable {
    var id: UUID?
    var gameId: UUID?
    var tiles: [[TileDTO]]
    
    
    
    func toModel() -> Board {
        let model = Board()
        
        model.id = self.id
        model.$game.id = gameId!
        
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
