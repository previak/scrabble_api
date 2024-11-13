import Vapor
import Fluent

final class BoardServiceImpl: BoardService {
    private let fileManager = FileManager.default
    private let jsonDecoder = JSONDecoder()
    
    // The file name of the starting board
    private let fileName = "StartingBoard.json"
    
    func getStartingBoard(on req: Request) -> EventLoopFuture<BoardDTO> {
        return readBoardFromFile(on: req)
    }
    
    private func readBoardFromFile(on req: Request) -> EventLoopFuture<BoardDTO> {
        // Use the event loop to create a future
//        guard let path = self.filePath(filename: fileName) else {
//            return req.eventLoop.makeFailedFuture(Abort(.internalServerError, reason: "Unable to find the file path"))
//        }
        
        let path = URL(fileURLWithPath: "/Users/klysin/Desktop/scrabble_api/Sources/Data/StartingBoard.json")
        
        do {
            req.logger.info("AMOGUS")
            let data = try Data(contentsOf: path)
            req.logger.info("Successfully read data from file: \(path.path)")
            req.logger.info("Data content: \(String(data: data, encoding: .utf8) ?? "Invalid UTF-8 data")")
            //let board = try self.jsonDecoder.decode(BoardDTO.self, from: data)
            let boardTiles = try self.jsonDecoder.decode([[TileDTO]].self, from: data)
            let board = BoardDTO(tiles: boardTiles)
            return req.eventLoop.makeSucceededFuture(board)
        } catch {
            return req.eventLoop.makeFailedFuture(Abort(.internalServerError, reason: "Error reading or decoding JSON file"))
        }
    }

    
    private func filePath(filename: String) -> URL? {
        let fileURL = URL(fileURLWithPath: fileManager.currentDirectoryPath).appendingPathComponent(fileName)
        return fileURL
    }
}
