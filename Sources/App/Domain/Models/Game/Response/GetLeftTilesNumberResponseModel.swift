import Foundation

final class GetLeftTilesNumberResponseModel : Sendable {
    let tilesNumber: Int
    
    init (tilesNumber: Int) {
        self.tilesNumber = tilesNumber
    }
}
