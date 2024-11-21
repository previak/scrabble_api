import Foundation

final class PlaceTileRequestModel: Sendable {
    let boardId: UUID
    let letter: String
    let verticalCoord: Int
    let horizontalCoord: Int
    
    init (boardId: UUID, letter: String, verticalCoord: Int, horizontalCoord: Int) {
        self.boardId = boardId
        self.letter = letter
        self.verticalCoord = verticalCoord
        self.horizontalCoord = horizontalCoord
    }
}
