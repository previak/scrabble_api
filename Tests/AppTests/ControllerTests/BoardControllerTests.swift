import XCTest
import Vapor
import Fluent
import Foundation
@testable import App

final class BoardControllerTests: XCTestCase {

    var app: Application!
    var mockBoardService: MockBoardService!
    var boardController: BoardController!

    override func setUp() {
        super.setUp()
        app = Application(.testing)
        mockBoardService = MockBoardService()
        boardController = BoardController(boardService: mockBoardService)
    }

    override func tearDown() {
        app.shutdown()
        super.tearDown()
    }

    /// Тест для получения стартовой доски
    func testGetStartingBoard() throws {
        let startingBoard = BoardDTO(id: UUID(), game: nil, tiles: [[TileDTO(modifier: .empty, letter: nil)]])

        mockBoardService.getStartingBoardClosure = { _ in
            return self.app.eventLoopGroup.future(startingBoard)
        }

        let req = Request(application: app, on: app.eventLoopGroup.next())

        let futureBoard = try boardController.getStartingBoard(req: req)
        let board = try futureBoard.wait()

        XCTAssertNotNil(board.id, "ID стартовой доски должен быть не nil")
        XCTAssertEqual(board.tiles.count, 1, "Доска должна стартовать с одной строкой плиток")
        XCTAssertEqual(board.tiles[0][0].modifier, .empty, "Модификатор на стартовой доске должен быть пустой (empty)")
        XCTAssertNil(board.tiles[0][0].letter, "На стартовой доске буква должна быть nil")
    }

    /// Тест для получения доски по ID
    func testGetBoard() throws {
        let testBoardID = UUID()
        let tile = TileDTO(modifier: .doubleWord, letter: "A")
        let testBoard = BoardDTO(id: testBoardID, game: nil, tiles: [[tile]])

        mockBoardService.getBoardClosure = { id, _ in
            guard id == testBoardID else { return self.app.eventLoopGroup.future(error: Abort(.notFound)) }
            return self.app.eventLoopGroup.future(testBoard)
        }

        let req = Request(application: app, on: app.eventLoopGroup.next())
        req.parameters.set("id", to: testBoardID.uuidString)

        let futureBoard = try boardController.getBoard(req: req)
        let board = try futureBoard.wait()

        XCTAssertEqual(board.id, testBoardID)
        XCTAssertEqual(board.tiles[0][0].letter, "A")
        XCTAssertEqual(board.tiles[0][0].modifier, .doubleWord)
    }

    /// Тестируем создание новой доски
    func testCreateBoard() throws {
        let requestBoard = BoardDTO(id: nil, game: nil, tiles: [[TileDTO(modifier: .doubleLetter, letter: "B")]])

        let createdBoard = BoardDTO(id: UUID(), game: nil, tiles: [[TileDTO(modifier: .doubleLetter, letter: "B")]])

        mockBoardService.createBoardClosure = { boardDTO, _ in
            return self.app.eventLoopGroup.future(createdBoard)
        }

        let req = Request(application: app, method: .POST, url: URI(path: "/boards"), on: app.eventLoopGroup.next())
        try req.content.encode(requestBoard, as: .json)

        let futureBoard = try boardController.createBoard(req: req)
        let board = try futureBoard.wait()

        XCTAssertNotNil(board.id, "Созданная доска должна иметь идентификатор")
        XCTAssertEqual(board.tiles[0][0].letter, "B")
        XCTAssertEqual(board.tiles[0][0].modifier, .doubleLetter)
    }

    /// Тестируем обновление доски
    func testUpdateBoard() throws {
        let boardID = UUID()
        let requestBoard = BoardDTO(id: boardID, game: nil, tiles: [[TileDTO(modifier: .tripleWord, letter: "C")]])

        mockBoardService.updateBoardClosure = { boardDTO, _ in
            return self.app.eventLoopGroup.future(requestBoard)
        }

        let req = Request(application: app, method: .PUT, url: URI(path: "/boards/\(boardID.uuidString)"), on: app.eventLoopGroup.next())
        try req.content.encode(requestBoard, as: .json)
        req.parameters.set("id", to: boardID.uuidString)

        let futureBoard = try boardController.updateBoard(req: req)
        let board = try futureBoard.wait()

        XCTAssertEqual(board.id, boardID)
        XCTAssertEqual(board.tiles[0][0].letter, "C")
        XCTAssertEqual(board.tiles[0][0].modifier, .tripleWord)
    }

    /// Тестируем удаление доски по ID
    func testDeleteBoard() throws {
        let testBoardID = UUID()

        mockBoardService.deleteBoardClosure = { id, _ in
            guard id == testBoardID else { return self.app.eventLoopGroup.future(error: Abort(.notFound)) }
            return self.app.eventLoopGroup.future()
        }

        let req = Request(application: app, on: app.eventLoopGroup.next())
        req.parameters.set("id", to: testBoardID.uuidString)

        let futureResponse = try boardController.deleteBoard(req: req)
        let response = try futureResponse.wait()

        XCTAssertEqual(response, .noContent)
    }
}

// Моковый сервис для работы с досками
final class MockBoardService: BoardService {
    var getStartingBoardClosure: ((Request) -> EventLoopFuture<BoardDTO>)?

    var getBoardClosure: ((UUID, Request) -> EventLoopFuture<BoardDTO>)?

    var createBoardClosure: ((BoardDTO, Request) -> EventLoopFuture<BoardDTO>)?

    var updateBoardClosure: ((BoardDTO, Request) -> EventLoopFuture<BoardDTO>)?

    var deleteBoardClosure: ((UUID, Request) -> EventLoopFuture<Void>)?

    func getStartingBoard(on req: Request) -> EventLoopFuture<BoardDTO> {
        return getStartingBoardClosure!(req)
    }

    func getBoard(id: UUID, on req: Request) -> EventLoopFuture<BoardDTO> {
        return getBoardClosure!(id, req)
    }

    func createBoard(board: BoardDTO, on req: Request) -> EventLoopFuture<BoardDTO> {
        return createBoardClosure!(board, req)
    }

    func updateBoard(board: BoardDTO, on req: Request) -> EventLoopFuture<BoardDTO> {
        return updateBoardClosure!(board, req)
    }

    func deleteBoard(id: UUID, on req: Request) -> EventLoopFuture<Void> {
        return deleteBoardClosure!(id, req)
    }
}
