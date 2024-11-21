import Foundation

final class TakeTileBackRequestModel: Sendable {
    let boardId: UUID
    let verticalCoord: Int
    let horizontalCoord: Int
    
    init (boardId: UUID, verticalCoord: Int, horizontalCoord: Int) {
        self.boardId = boardId
        self.verticalCoord = verticalCoord
        self.horizontalCoord = horizontalCoord
    }
}
