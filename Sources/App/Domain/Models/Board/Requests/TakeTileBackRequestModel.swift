import Foundation

final class TakeTileBackRequestModel: Sendable {
    let userId: UUID
    let verticalCoord: Int
    let horizontalCoord: Int
    
    init (userId: UUID, verticalCoord: Int, horizontalCoord: Int) {
        self.userId = userId
        self.verticalCoord = verticalCoord
        self.horizontalCoord = horizontalCoord
    }
}
