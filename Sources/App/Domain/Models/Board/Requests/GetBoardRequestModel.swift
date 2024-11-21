import Foundation

final class GetBoardRequestModel {
    var boardId: UUID
    
    init (boardId: UUID) {
        self.boardId = boardId
    }
}

