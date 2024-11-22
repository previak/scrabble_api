import Vapor
import Fluent


final class BoardServiceImpl: BoardService {
    private let boardRepository: BoardRepository
    private let playerRepository: PlayerRepository
    private let roomRepository: RoomRepository
    private let gameRepository: GameRepository
    
    private let fileManager = FileManager.default
    private let jsonDecoder = JSONDecoder()
    
    private let startingBoardResourceName = "StartingBoard"
        
    init(boardRepository: BoardRepository, playerRepository: PlayerRepository, roomRepository: RoomRepository, gameRepository: GameRepository) {
            self.boardRepository = boardRepository
            self.playerRepository = playerRepository
            self.roomRepository = roomRepository
            self.gameRepository = gameRepository
        }
    
    func placeTile(placeTileRequest: PlaceTileRequestModel, on req: Request) -> EventLoopFuture<BoardDTO> {
        
        let board = self.getBoard(getBoardRequest: GetBoardRequestModel(userId: placeTileRequest.userId), on: req)
        
        return board.flatMap { board in
            var mutableBoard = board
            
            mutableBoard.tiles[placeTileRequest.verticalCoord][placeTileRequest.horizontalCoord].letter = placeTileRequest.letter
            
            return self.updateBoard(board: mutableBoard, on: req).map { updatedBoard in
                return updatedBoard
            }
        }
    }
    
    func takeTileBack(takeTileBackRequest: TakeTileBackRequestModel, on req: Request) -> EventLoopFuture<BoardDTO> {
            
        let board = self.getBoard(getBoardRequest: GetBoardRequestModel(userId: takeTileBackRequest.userId), on: req)
        
        return board.flatMap { board in
            var mutableBoard = board

            if mutableBoard.tiles[takeTileBackRequest.verticalCoord][takeTileBackRequest.horizontalCoord].letter != nil {
                mutableBoard.tiles[takeTileBackRequest.verticalCoord][takeTileBackRequest.horizontalCoord].letter = nil
            } else {
                return req.eventLoop.makeFailedFuture(Abort(.badRequest, reason: "Tile is already empty"))
            }
            
            return self.updateBoard(board: mutableBoard, on: req).map { updatedBoard in
                return updatedBoard
            }
        }
    }
    
    func getStartingBoard(on req: Request) -> EventLoopFuture<BoardDTO> {
        return readBoardFromFile(on: req)
    }
    
    func getBoard(getBoardRequest: GetBoardRequestModel, on req: Request) -> EventLoopFuture<BoardDTO> {
        return playerRepository.findByUserId(userId: getBoardRequest.userId, on: req).flatMap { player in
                guard let player = player else {
                    return req.eventLoop.makeFailedFuture(Abort(.notFound, reason: "Player not found"))
                }
                
                return self.roomRepository.findByPlayer(player, on: req).flatMap { room in
                    guard let room = room else {
                        return req.eventLoop.makeFailedFuture(Abort(.notFound, reason: "Room not found"))
                    }
                    
                    return self.gameRepository.findByRoomId(roomId: room.id!, on: req).flatMap { game in
                        guard let game = game else {
                            return req.eventLoop.makeFailedFuture(Abort(.notFound, reason: "Game not found"))
                        }
                        
                        return self.boardRepository.findByGameId(gameId: game.id!, on: req).flatMap { board in
                            guard let board = board else {
                                return req.eventLoop.makeFailedFuture(Abort(.notFound, reason: "Board not found"))
                            }
                            
                            guard let boardDTO = board.toDTO() else {
                                return req.eventLoop.makeFailedFuture(Abort(.internalServerError, reason: "Failed to convert board to DTO"))
                            }
                            
                            return req.eventLoop.makeSucceededFuture(boardDTO)
                        }
                    }
                }
            }
        }
 
    func updateBoard(board: BoardDTO, on req: Request) -> EventLoopFuture<BoardDTO> {
        let model = board.toModel()
        return boardRepository.update(board: model, on: req).map { $0.toDTO()! }
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
