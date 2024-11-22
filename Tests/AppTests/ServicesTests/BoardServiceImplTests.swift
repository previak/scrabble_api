import XCTest
@testable import App // Подставьте имя вашего модуля
import Vapor
import Fluent

// MARK: - Mock BoardRepository
final class MockBoardRepository: BoardRepository {
    func findByGameId(gameId: UUID, on req: Vapor.Request) -> NIOCore.EventLoopFuture<App.Board?> {
        return findByGameId(gameId: UUID(), on: req)
    }
    
    var boards: [UUID: BoardDTO] = [:]

    // Реализация поиска доски
    func find(id: UUID, on req: Request) -> EventLoopFuture<Board?> {
        if let board = boards[id] {
            return req.eventLoop.makeSucceededFuture(board.toModel())
        } else {
            return req.eventLoop.makeSucceededFuture(nil)
        }
    }

    // Реализация создания доски
    func create(board: Board, on req: Request) -> EventLoopFuture<Board> {
        boards[board.id!] = board.toDTO()!
        return req.eventLoop.makeSucceededFuture(board)
    }

    // Реализация обновления доски
    func update(board: Board, on req: Request) -> EventLoopFuture<Board> {
        boards[board.id!] = board.toDTO()!
        return req.eventLoop.makeSucceededFuture(board)
    }

    // Реализация удаления доски
    func delete(id: UUID, on req: Request) -> EventLoopFuture<Void> {
        boards.removeValue(forKey: id)
        return req.eventLoop.makeSucceededFuture(())
    }
}

// MARK: - Test Class
/*final class BoardServiceTests: XCTestCase {
    private var app: Application!
    private var mockBoardRepository: MockBoardRepository!
    private var mockRoomRepository: MockRoomRepository!
    private var mockGameRepository: MockGameRepository!
    private var mockPlayerRepository: MockPlayerRepository!
    private var boardService: BoardService!

    override func setUp() {
        super.setUp()

        app = Application(.testing)
        mockBoardRepository = MockBoardRepository()
        mockRoomRepository = MockRoomRepository()
        mockGameRepository = MockGameRepository()
        mockPlayerRepository = MockPlayerRepository()
        boardService = BoardServiceImpl(boardRepository: mockBoardRepository, playerRepository: mockPlayerRepository, roomRepository: mockRoomRepository, gameRepository: mockGameRepository)
    }

    override func tearDown() {
        mockBoardRepository = nil
        boardService = nil
        app.shutdown()
        super.tearDown()
    }

    // MARK: - Test Cases

    // Тест успешного добавления плитки
    func testPlaceTileSuccessfully() throws {
        let boardId = UUID()

        let initialBoard = BoardDTO(
            tiles: Array(
                repeating: Array(repeating: TileDTO(modifier: .empty, letter: nil), count: 15),
                count: 15
            )
        )

        mockBoardRepository.boards[boardId] = initialBoard

        let req = Request(application: app, on: app.eventLoopGroup.next())

        let placeTileRequest = PlaceTileRequestModel(
            userId: boardId,
            letter: "A",
            verticalCoord: 7,
            horizontalCoord: 7
        )

        let futureResult = boardService.placeTile(placeTileRequest: placeTileRequest, on: req)
        let result = try futureResult.wait()

        print("Tile after placement: \(result.tiles[7][7])")
        
        XCTAssertEqual(result.tiles[7][7].letter, "A")

        XCTAssertEqual(result.tiles[7][7].modifier, .empty)
    }
    

    // Тест добавления на клетку с модификатором
    func testPlaceTileOnModifiedTile() throws {
        let boardId = UUID()
        var tiles = Array(
            repeating: Array(repeating: TileDTO(modifier: .empty, letter: nil), count: 15),
            count: 15
        )

        tiles[7][7] = TileDTO(modifier: .doubleLetter, letter: nil)

        let initialBoard = BoardDTO(tiles: tiles)
        mockBoardRepository.boards[boardId] = initialBoard

        let req = Request(application: app, on: app.eventLoopGroup.next())

        let placeTileRequest = PlaceTileRequestModel(
            userId: boardId,
            letter: "B",
            verticalCoord: 7,
            horizontalCoord: 7
        )

        let futureResult = boardService.placeTile(placeTileRequest: placeTileRequest, on: req)
        let result = try futureResult.wait()

        print("Tile after placement: \(result.tiles[7][7])")

        XCTAssertEqual(result.tiles[7][7].letter, "B")
        XCTAssertEqual(result.tiles[7][7].modifier, .doubleLetter)
    }
}
*/
