import Vapor
import Fluent

final class BoardServiceImpl: BoardService {
    private let fileManager = FileManager.default
    private let jsonDecoder = JSONDecoder()
    
    private let startingBoardResourceName = "StartingBoard"
    
    func getStartingBoard(on req: Request) -> EventLoopFuture<BoardDTO> {
        return readBoardFromFile(on: req)
    }
    
    private func readBoardFromFile(on req: Request) -> EventLoopFuture<BoardDTO> {
        guard let path = filePath(resourceName: startingBoardResourceName) else {
              return req.eventLoop.makeFailedFuture(Abort(.internalServerError, reason: "Unable to find the file path"))
          }
        
        do {
            let data = try Data(contentsOf: path)
            req.logger.debug("Successfully read data from file: \(path.path)")
            let boardTiles = try self.jsonDecoder.decode([[TileDTO]].self, from: data)
            let board = BoardDTO(tiles: boardTiles)
            return req.eventLoop.makeSucceededFuture(board)
        } catch {
            return req.eventLoop.makeFailedFuture(Abort(.internalServerError, reason: "Error reading or decoding JSON file"))
        }
    }

    private func filePath(resourceName: String) -> URL? {
        return Bundle.module.url(forResource: resourceName, withExtension: "json")
    }
}
