import Foundation

final class DrawPlayerTilesResponseModel : Sendable {
    let tiles: String
    
    init (tiles: String) {
        self.tiles = tiles
    }
}

