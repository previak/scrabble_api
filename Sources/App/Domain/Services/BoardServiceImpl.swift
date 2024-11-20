import Vapor
import Fluent


final class BoardServiceImpl: BoardService {
    private let boardRepository: BoardRepository
    
    private let fileManager = FileManager.default
    private let jsonDecoder = JSONDecoder()
    
    private let startingBoardResourceName = "StartingBoard"
        
    init(boardRepository: BoardRepository) {
            self.boardRepository = boardRepository
    }
    
    func getStartingBoard(on req: Request) -> EventLoopFuture<BoardDTO> {
        return readBoardFromFile(on: req)
    }
    
    func getBoard(id: UUID, on req: Request) -> EventLoopFuture<BoardDTO> {
            return boardRepository.find(id: id, on: req).flatMapThrowing { board in
                guard let board = board else {
                    throw Abort(.notFound)
                }
                return board.toDTO()!
            }
        }
        
    func createBoard(board: BoardDTO, on req: Request) -> EventLoopFuture<BoardDTO> {
        let model = board.toModel()
        return boardRepository.create(board: model, on: req).map { $0.toDTO()! }
    }
        
    func updateBoard(board: BoardDTO, on req: Request) -> EventLoopFuture<BoardDTO> {
        let model = board.toModel()
        return boardRepository.update(board: model, on: req).map { $0.toDTO()! }
    }
        
    func deleteBoard(id: UUID, on req: Request) -> EventLoopFuture<Void> {
        return boardRepository.delete(id: id, on: req)
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

extension FileManager: @unchecked @retroactive Sendable {}
