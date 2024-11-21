import XCTest
@testable import App // Подставьте имя вашего модуля
import Vapor
import Fluent

// MARK: - Mock BoardRepository
final class MockBoardRepository: BoardRepository {
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
final class BoardServiceTests: XCTestCase {
    private var app: Application!
    private var mockBoardRepository: MockBoardRepository!
    private var boardService: BoardService!

    override func setUp() {
        super.setUp()

        // Создание тестового приложения
        app = Application(.testing)
        mockBoardRepository = MockBoardRepository()
        boardService = BoardServiceImpl(boardRepository: mockBoardRepository)
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
        // Уникальный ID доски
        let boardId = UUID()

        // Создаём стартовую доску
        let initialBoard = BoardDTO(
            tiles: Array(
                repeating: Array(repeating: TileDTO(modifier: .empty, letter: nil), count: 15),
                count: 15
            )
        )
        // Сохраняем доску в репозитории
        mockBoardRepository.boards[boardId] = initialBoard

        // Создаём объект Request
        let req = Request(application: app, on: app.eventLoopGroup.next())

        // Создаём запрос для размещения плитки
        let placeTileRequest = PlaceTileRequestModel(
            boardId: boardId,    // Сначала ID доски
            letter: "A",         // Затем буква
            verticalCoord: 7,    // Координата по вертикали
            horizontalCoord: 7   // Координата по горизонтали
        )

        // Основное выполнение
        let futureResult = boardService.placeTile(placeTileRequest: placeTileRequest, on: req)
        let result = try futureResult.wait()

        // Отладочный вывод результата (если что-то идёт не так)
        print("Tile after placement: \(result.tiles[7][7])")
        
        // Проверяем, что буква добавлена в нужное место
        XCTAssertEqual(result.tiles[7][7].letter, "A")

        // Убедимся, что модификатор не изменился
        XCTAssertEqual(result.tiles[7][7].modifier, .empty)
    }

    // Тест добавления на клетку с модификатором
    func testPlaceTileOnModifiedTile() throws {
        let boardId = UUID()
        var tiles = Array(
            repeating: Array(repeating: TileDTO(modifier: .empty, letter: nil), count: 15),
            count: 15
        )
        // Указываем специальный модификатор для клетки
        tiles[7][7] = TileDTO(modifier: .doubleLetter, letter: nil)

        let initialBoard = BoardDTO(tiles: tiles)
        mockBoardRepository.boards[boardId] = initialBoard

        let req = Request(application: app, on: app.eventLoopGroup.next())

        let placeTileRequest = PlaceTileRequestModel(
            boardId: boardId,
            letter: "B",
            verticalCoord: 7,
            horizontalCoord: 7
        )

        let futureResult = boardService.placeTile(placeTileRequest: placeTileRequest, on: req)
        let result = try futureResult.wait()

        // Отладочный вывод результата
        print("Tile after placement: \(result.tiles[7][7])")

        XCTAssertEqual(result.tiles[7][7].letter, "B")
        XCTAssertEqual(result.tiles[7][7].modifier, .doubleLetter)
    }
}
