/*import XCTest
import XCTVapor
@testable import App
import Vapor

final class BoardControllerTests: XCTestCase {
    var app: Application!
    var mockBoardService: MockBoardService!
    var mockUserService: MockUserService!
    var boardController: BoardController!

    override func setUp() {
        super.setUp()
        app = Application(.testing)
        mockBoardService = MockBoardService()
        boardController = BoardController(boardService: mockBoardService, userService: mockUserService)

        let routes = app.routes
        try? boardController.boot(routes: routes)
    }

    override func tearDown() {
        app.shutdown()
        super.tearDown()
    }

    // MARK: - Тест установки плитки на доску
    /*func testPlaceTile() throws {
        // Arrange
        let tilePlacementRequest = PlaceTileRequestDTO(
            letter: "A",
            verticalCoord: 2,
            horizontalCoord: 3
        )
        let updatedBoard = BoardDTO(
            id: UUID(),
            tiles: [[TileDTO(modifier: .doubleLetter, letter: nil)]]
        )

        mockBoardService.placeTileClosure = { request, req in
            //XCTAssertEqual(request.boardId, tilePlacementRequest.boardId)
            XCTAssertEqual(request.letter, "A")
            XCTAssertEqual(request.verticalCoord, 2)
            XCTAssertEqual(request.horizontalCoord, 3)
            return req.eventLoop.future(updatedBoard)
        }

        let req = Request(application: app, method: .POST, url: URI(path: "/boards/place-tile"), on: app.eventLoopGroup.next())
        try req.content.encode(tilePlacementRequest, as: .json)

        // Act
        let futureBoard = try boardController.placeTile(req: req)
        let board = try futureBoard.wait()

        // Assert
        XCTAssertNotNil(board.id, "Доска должна иметь идентификатор")
        XCTAssertEqual(board.tiles[0][0].modifier, .doubleLetter, "Модификатор плитки должен быть `.doubleLetter`")
    }*/

    // MARK: - Тест возврата плитки с доски
    /*func testTakeTileBack() throws {
        // Arrange
        let takeTileBackRequest = TakeTileBackRequestDTO(
            verticalCoord: 3,
            horizontalCoord: 4
        )
        let updatedBoard = BoardDTO(
            id: UUID(),
            tiles: [[TileDTO(modifier: .empty, letter: nil)]]
        )

        mockBoardService.takeTileBackClosure = { request, req in
            //XCTAssertEqual(request.boardId, takeTileBackRequest.boardId)
            XCTAssertEqual(request.verticalCoord, 3)
            XCTAssertEqual(request.horizontalCoord, 4)
            return req.eventLoop.future(updatedBoard)
        }

        let req = Request(application: app, method: .POST, url: URI(path: "/boards/take-tile-back"), on: app.eventLoopGroup.next())
        try req.content.encode(takeTileBackRequest, as: .json)

        // Act
        let futureBoard = try boardController.takeTileBack(req: req)
        let board = try futureBoard.wait()

        // Assert
        XCTAssertNotNil(board.id, "Доска должна иметь идентификатор")
        XCTAssertEqual(board.tiles[0][0].modifier, .empty, "Модификатор плитки должен быть `.empty`")
    }*/

    // MARK: - Тест получения доски по ID
    /*func testGetBoard() throws {
        // Arrange
        let testBoardID = UUID()
        let tile = TileDTO(modifier: .doubleWord, letter: "A")
        let board = BoardDTO(
            id: testBoardID,
            tiles: [[tile]]
        )

        mockBoardService.getBoardClosure = { id, _ in
            guard id == testBoardID else {
                return self.app.eventLoopGroup.future(error: Abort(.notFound))
            }
            return self.app.eventLoopGroup.future(board)
        }

        let req = Request(application: app, method: .GET, url: URI(path: "/boards"), on: app.eventLoopGroup.next())
        req.parameters.set("id", to: testBoardID.uuidString)

        // Act
        let futureBoard = try boardController.getBoard(req: req)
        let result = try futureBoard.wait()

        // Assert
        XCTAssertEqual(result.id, testBoardID)
        XCTAssertEqual(result.tiles[0][0].modifier, .doubleWord)
        XCTAssertEqual(result.tiles[0][0].letter, "A")
    }*/

    // MARK: - Тест получения стартовой доски
    /*func testGetStartingBoard() throws {
        // Arrange
        let startingBoard = BoardDTO(
            id: UUID(),
            tiles: [[TileDTO(modifier: .empty, letter: nil)]]
        )

        mockBoardService.getStartingBoardClosure = { _ in
            return self.app.eventLoopGroup.future(startingBoard)
        }

        let req = Request(application: app, on: app.eventLoopGroup.next())

        // Act
        let futureBoard = try boardController.getStartingBoard(req: req)
        let result = try futureBoard.wait()

        // Assert
        XCTAssertNotNil(result.id, "Стартовая доска должна иметь идентификатор")
        XCTAssertEqual(result.tiles[0][0].modifier, .empty)
        XCTAssertNil(result.tiles[0][0].letter)
    }*/
}

// MARK: - MockBoardService для тестов
final class MockBoardService: BoardService {
    func getBoard(getBoardRequest: App.GetBoardRequestModel, on req: Vapor.Request) -> NIOCore.EventLoopFuture<App.BoardDTO> {
        return getBoard(getBoardRequest: getBoardRequest, on: req)
    }
    
    func updateBoard(board: App.BoardDTO, on req: Vapor.Request) -> NIOCore.EventLoopFuture<App.BoardDTO> {
        return updateBoard(board: board, on: req)
    }
    
    var placeTileClosure: ((PlaceTileRequestModel, Request) -> EventLoopFuture<BoardDTO>)?
    var takeTileBackClosure: ((TakeTileBackRequestModel, Request) -> EventLoopFuture<BoardDTO>)?
    var getBoardClosure: ((UUID, Request) -> EventLoopFuture<BoardDTO>)?
    var getStartingBoardClosure: ((Request) -> EventLoopFuture<BoardDTO>)?

    func placeTile(placeTileRequest: PlaceTileRequestModel, on req: Request) -> EventLoopFuture<BoardDTO> {
        placeTileClosure!(placeTileRequest, req)
    }

    func takeTileBack(takeTileBackRequest: TakeTileBackRequestModel, on req: Request) -> EventLoopFuture<BoardDTO> {
        takeTileBackClosure!(takeTileBackRequest, req)
    }

    /*func getBoard(getBoardRequest: GetBoardRequestModel, on req: Request) -> EventLoopFuture<BoardDTO> {
        getBoardClosure!(getBoardRequest, req)
    }*/

    func getStartingBoard(on req: Request) -> EventLoopFuture<BoardDTO> {
        getStartingBoardClosure!(req)
    }
}
*/
