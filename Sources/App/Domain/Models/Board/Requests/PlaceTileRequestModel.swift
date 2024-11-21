import Foundation

final class PlaceTileRequestModel {
    var boardId: UUID
    var letter: String
    var verticalCoord: Int
    var horizontalCoord: Int
    
    init (boardId: UUID, letter: String, verticalCoord: Int, horizontalCoord: Int) {
        self.boardId = boardId
        self.letter = letter
        self.verticalCoord = verticalCoord
        self.horizontalCoord = horizontalCoord
    }
}
