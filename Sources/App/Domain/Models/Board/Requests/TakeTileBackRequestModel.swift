import Foundation

final class TakeTileBackRequestModel {
    var boardId: UUID
    var verticalCoord: Int
    var horizontalCoord: Int
    
    init (boardId: UUID, verticalCoord: Int, horizontalCoord: Int) {
        self.boardId = boardId
        self.verticalCoord = verticalCoord
        self.horizontalCoord = horizontalCoord
    }
}
