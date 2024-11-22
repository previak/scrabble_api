import Foundation

final class PlaceTileRequestModel: Sendable {
    let userId: UUID
    let letter: String
    let verticalCoord: Int
    let horizontalCoord: Int
    
    init (userId: UUID, letter: String, verticalCoord: Int, horizontalCoord: Int) {
        self.userId = userId
        self.letter = letter
        self.verticalCoord = verticalCoord
        self.horizontalCoord = horizontalCoord
    }
}
