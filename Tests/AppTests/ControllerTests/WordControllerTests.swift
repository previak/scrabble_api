import XCTest
import Vapor
import Foundation
@testable import App


final class MockWordService: WordService {
    var getWordClosure: ((UUID, Request) -> EventLoopFuture<WordDTO>)?
    var createWordClosure: ((WordDTO, Request) -> EventLoopFuture<WordDTO>)?
    var updateWordClosure: ((WordDTO, Request) -> EventLoopFuture<WordDTO>)?
    var deleteWordClosure: ((UUID, Request) -> EventLoopFuture<Void>)?

    func getWord(id: UUID, on req: Request) -> EventLoopFuture<WordDTO> {
        return getWordClosure!(id, req)
    }
    
    func createWord(word: WordDTO, on req: Request) -> EventLoopFuture<WordDTO> {
        return createWordClosure!(word, req)
    }

    func updateWord(word: WordDTO, on req: Request) -> EventLoopFuture<WordDTO> {
        return updateWordClosure!(word, req)
    }

    func deleteWord(id: UUID, on req: Request) -> EventLoopFuture<Void> {
        return deleteWordClosure!(id, req)
    }
}


final class WordControllerTests: XCTestCase {
    var app: Application!
    var mockWordService: MockWordService!
    var wordController: WordController!

    override func setUp() {
        super.setUp()
        app = Application(.testing)
        mockWordService = MockWordService()
        wordController = WordController(wordService: mockWordService)
    }

    override func tearDown() {
        app.shutdown()
        super.tearDown()
    }
    
    /// Тест создания нового слова
    func testCreateWordSuccess() throws {
        let testGameDTO = GameDTO(id: UUID(), room: RoomDTO(id: UUID(), isOpen: true, isPublic: true, invitationCode: "ABC123", gameState: .forming, admin: User(id: UUID(), username: "Admin", passwordHash: "as", apiKey: "as")), isPaused: false)
        let testPlayerDTO = PlayerDTO(id: UUID(), user: UserDTO(id: UUID(), username: "playerUser", passwordHash: "hash", apiKey: "key"),
                                      room: RoomDTO(id: UUID(), isOpen: true, isPublic: true, invitationCode: "ABC123", gameState: .forming, admin: User(id: UUID(), username: "Admin", passwordHash: "as", apiKey: "as")),
                                      nickname: "Player1", score: 100, turnOrder: 1, availableLetters: "ABCDE")
        let testDirectionDTO = WordDirectionDTO.horizontal
        
        let createWordDTO = WordDTO(
            id: nil,
            game: testGameDTO,
            player: testPlayerDTO,
            word: "HELLO",
            startRow: 1,
            startColumn: 1,
            direction: testDirectionDTO
        )
        
        let createdWordDTO = WordDTO(
            id: UUID(),
            game: testGameDTO,
            player: testPlayerDTO,
            word: "HELLO",
            startRow: 1,
            startColumn: 1,
            direction: testDirectionDTO
        )
        
        mockWordService.createWordClosure = { wordDTO, _ in
            return self.app.eventLoopGroup.future(createdWordDTO)
        }

        let req = Request(application: app, method: .POST, url: URI(path: "/words"), on: app.eventLoopGroup.next())
        try req.content.encode(createWordDTO, as: .json)
        
        let futureWord = try wordController.createWord(req: req)
        let word = try futureWord.wait()
        
        XCTAssertNotNil(word.id)
        XCTAssertEqual(word.word, "HELLO")
        XCTAssertEqual(word.startRow, 1)
        XCTAssertEqual(word.startColumn, 1)
        XCTAssertEqual(word.direction, .horizontal)
    }

    /// Тест успешного получения слова по ID
    func testGetWordSuccess() throws {
        let testWordID = UUID()
        let testGameDTO = GameDTO(id: UUID(), room: RoomDTO(id: UUID(), isOpen: true, isPublic: true, invitationCode: "ABC123", gameState: .forming, admin: User(id: UUID(), username: "adminUser", passwordHash: "as", apiKey: "as")), isPaused: false)
        let testPlayerDTO = PlayerDTO(id: UUID(), user: UserDTO(id: UUID(), username: "playerUser", passwordHash: "passwordHash", apiKey: "key123"),
                                      room: RoomDTO(id: UUID(), isOpen: true, isPublic: true, invitationCode: "ABC321", gameState: .forming, admin: User(id: UUID(), username: "adminUser", passwordHash: "as", apiKey: "as")),
                                      nickname: "PlayerTest", score: 200, turnOrder: 2, availableLetters: "CDEFG")
        let testDirectionDTO = WordDirectionDTO.vertical
        let testWordDTO = WordDTO(
            id: testWordID,
            game: testGameDTO,
            player: testPlayerDTO,
            word: "WORLD",
            startRow: 2,
            startColumn: 2,
            direction: testDirectionDTO
        )
        
        mockWordService.getWordClosure = { id, _ in
            guard id == testWordID else { return self.app.eventLoopGroup.future(error: Abort(.notFound)) }
            return self.app.eventLoopGroup.future(testWordDTO)
        }

        let req = Request(application: app, on: app.eventLoopGroup.next())
        req.parameters.set("id", to: testWordID.uuidString)
        
        let futureWord = try wordController.getWord(req: req)
        let word = try futureWord.wait()

        XCTAssertEqual(word.id, testWordID)
        XCTAssertEqual(word.word, "WORLD")
        XCTAssertEqual(word.startRow, 2)
        XCTAssertEqual(word.startColumn, 2)
        XCTAssertEqual(word.direction, .vertical)
    }

    /// Тест для успешного обновления слова
    func testUpdateWordSuccess() throws {
        let testWordID = UUID()
        let testGameDTO = GameDTO(id: UUID(), room: RoomDTO(id: UUID(), isOpen: true, isPublic: false, invitationCode: "DEF321", gameState: .playing, admin: User(id: UUID(), username: "adminUserUpdated", passwordHash: "as", apiKey: "as")), isPaused: false)
        let testPlayerDTO = PlayerDTO(id: UUID(), user: UserDTO(id: UUID(), username: "player2", passwordHash: "hash", apiKey: "apikeyUpdated"),
                                      room: RoomDTO(id: UUID(), isOpen: false, isPublic: true, invitationCode: "DEF123", gameState: .playing, admin: User(id: UUID(), username: "adminUser2", passwordHash: "as", apiKey: "as")),
                                      nickname: "Player2", score: 500, turnOrder: 3, availableLetters: "FGHIJK")
        let testDirectionDTO = WordDirectionDTO.vertical
        let updatedWordDTO = WordDTO(
            id: testWordID,
            game: testGameDTO,
            player: testPlayerDTO,
            word: "HELLO_WORLD",
            startRow: 3,
            startColumn: 3,
            direction: testDirectionDTO
        )
        
        mockWordService.updateWordClosure = { wordDTO, _ in
            return self.app.eventLoopGroup.future(updatedWordDTO)
        }

        let req = Request(application: app, method: .PUT, url: URI(path: "/words/\(testWordID.uuidString)"), on: app.eventLoopGroup.next())
        try req.content.encode(updatedWordDTO, as: .json)
        req.parameters.set("id", to: testWordID.uuidString)

        let futureWord = try wordController.updateWord(req: req)
        let word = try futureWord.wait()
        
        XCTAssertEqual(word.id, testWordID)
        XCTAssertEqual(word.word, "HELLO_WORLD")
        XCTAssertEqual(word.startRow, 3)
        XCTAssertEqual(word.startColumn, 3)
        XCTAssertEqual(word.direction, .vertical)
    }

    /// Тест успешного удаления слова
    func testDeleteWordSuccess() throws {
        let testWordID = UUID()

        mockWordService.deleteWordClosure = { id, _ in
            guard id == testWordID else { return self.app.eventLoopGroup.future(error: Abort(.notFound)) }
            return self.app.eventLoopGroup.future()
        }

        let req = Request(application: app, on: app.eventLoopGroup.next())
        req.parameters.set("id", to: testWordID.uuidString)
        
        let futureResponse = try wordController.deleteWord(req: req)
        let response = try futureResponse.wait()

        XCTAssertEqual(response, .noContent)
    }
    
    /// Тест, когда слово не найдено (404 Not Found)
    func testGetWordNotFound() throws {
        let testWordID = UUID()

        mockWordService.getWordClosure = { id, _ in
            return self.app.eventLoopGroup.future(error: Abort(.notFound))
        }
        
        let req = Request(application: app, on: app.eventLoopGroup.next())
        req.parameters.set("id", to: testWordID.uuidString)
        
        XCTAssertThrowsError(try wordController.getWord(req: req).wait()) { error in
            XCTAssertEqual((error as? Abort)?.status, .notFound)
        }
    }

    /// Тест, когда слово не может быть удалено (слово не найдено)
    func testDeleteWordNotFound() throws {
        let testWordID = UUID()

        mockWordService.deleteWordClosure = { id, _ in
            return self.app.eventLoopGroup.future(error: Abort(.notFound))
        }

        let req = Request(application: app, on: app.eventLoopGroup.next())
        req.parameters.set("id", to: testWordID.uuidString)

        XCTAssertThrowsError(try wordController.deleteWord(req: req).wait()) { error in
            XCTAssertEqual((error as? Abort)?.status, .notFound)
        }
    }
}
