import XCTest
import XCTVapor
@testable import App

// MARK: - Mock WordRepository
final class MockWordRepository: WordRepository {
    var words: [UUID: Word] = [:]

    func find(id: UUID, on req: Request) -> EventLoopFuture<Word?> {
        req.eventLoop.future(words[id])
    }

    func create(word: Word, on req: Request) -> EventLoopFuture<Word> {
        words[word.id!] = word
        return req.eventLoop.future(word)
    }

    func update(word: Word, on req: Request) -> EventLoopFuture<Word> {
        words[word.id!] = word
        return req.eventLoop.future(word)
    }

    func delete(id: UUID, on req: Request) -> EventLoopFuture<Void> {
        words.removeValue(forKey: id)
        return req.eventLoop.future()
    }
}

// MARK: - Test Class
final class WordServiceImplTests: XCTestCase {
    private var app: Application!
    private var mockWordRepository: MockWordRepository!
    private var wordService: WordServiceImpl!

    override func setUp() {
        super.setUp()
        app = Application(.testing)
        mockWordRepository = MockWordRepository()
        wordService = WordServiceImpl(wordRepository: mockWordRepository)
    }

    override func tearDown() {
        mockWordRepository = nil
        wordService = nil
        app.shutdown()
        super.tearDown()
    }

    // MARK: - Test Cases

    /// Успешное получение слова
    func testGetWord_Success() throws {
        let wordId = UUID()
        let gameId = UUID()
        let playerId = UUID()

        // Создаем объект слова
        let word = Word(
            id: wordId,
            gameId: gameId,
            playerId: playerId,
            word: "HELLO",
            startRow: 1,
            startColumn: 1,
            direction: .horizontal
        )

        mockWordRepository.words[wordId] = word

        let req = Request(application: app, on: app.eventLoopGroup.next())

        let futureResult = wordService.getWord(id: wordId, on: req)
        let result = try futureResult.wait()

        XCTAssertEqual(result.id, wordId)
        XCTAssertEqual(result.word, "HELLO")
        XCTAssertEqual(result.startRow, 1)
        XCTAssertEqual(result.startColumn, 1)
        XCTAssertEqual(result.direction, .horizontal)
    }

    /// Ошибка: Слово не найдено
    func testGetWord_NotFound() throws {
        let wordId = UUID()
        let req = Request(application: app, on: app.eventLoopGroup.next())

        let futureResult = wordService.getWord(id: wordId, on: req)

        XCTAssertThrowsError(try futureResult.wait()) { error in
            XCTAssertTrue(error is Abort)
            XCTAssertEqual((error as? Abort)?.status, .notFound)
        }
    }

    /// Успешное создание слова
    func testCreateWord_Success() throws {
        let wordDTO = WordDTO(
            id: nil,
            game: GameDTO(id: UUID(), room: RoomDTO(id: UUID(), isOpen: true, isPublic: false, invitationCode: "INV123", gameState: .forming, admin: User(id: UUID(), username: "Admin", passwordHash: "hashed", apiKey: "apikey123")), isPaused: false),
            player: PlayerDTO(id: UUID(), user: UserDTO(id: UUID(), username: "JohnDoe", passwordHash: "hashedPwd", apiKey: "playerApiKey"), room: RoomDTO(id: UUID(), isOpen: true, isPublic: false, invitationCode: "ROOM123", gameState: .forming, admin: User(id: UUID(), username: "Admin", passwordHash: "hashed", apiKey: "adminApiKey")), nickname: "PlayerOne", score: 50, turnOrder: 1, availableLetters: "A,B,C"),
            word: "CREATE",
            startRow: 3,
            startColumn: 5,
            direction: .vertical
        )

        let req = Request(application: app, on: app.eventLoopGroup.next())

        // Создаем слово через сервис
        let futureResult = wordService.createWord(word: wordDTO, on: req)
        let result = try futureResult.wait()

        XCTAssertNotNil(result.id)
        XCTAssertEqual(result.word, "CREATE")
        XCTAssertEqual(result.startRow, 3)
        XCTAssertEqual(result.startColumn, 5)
        XCTAssertEqual(result.direction, .vertical)
    }

    /// Успешное обновление слова
    func testUpdateWord_Success() throws {
        let wordId = UUID()
        let gameId = UUID()
        let playerId = UUID()

        // Оригинальное слово
        let originalWord = Word(
            id: wordId,
            gameId: gameId,
            playerId: playerId,
            word: "UPDATE",
            startRow: 1,
            startColumn: 1,
            direction: .horizontal
        )

        mockWordRepository.words[wordId] = originalWord

        // DTO для обновления
        let updatedWordDTO = WordDTO(
            id: wordId,
            game: GameDTO(id: gameId, room: RoomDTO(id: UUID(), isOpen: true, isPublic: false, invitationCode: "ROOM456", gameState: .playing, admin: User(id: UUID(), username: "Admin", passwordHash: "hashedPwd", apiKey: "api456")), isPaused: true),
            player: PlayerDTO(id: playerId, user: UserDTO(id: UUID(), username: "JaneDoe", passwordHash: "hashedPwd2", apiKey: "playerApi2"), room: RoomDTO(id: UUID(), isOpen: false, isPublic: true, invitationCode: "ROOMXYZ", gameState: .forming, admin: User(id: UUID(), username: "Admin", passwordHash: "hashed", apiKey: "apiAdminKeyPreUpdated")), nickname: "PlayerTwo", score: 60, turnOrder: 2, availableLetters: "X,Y,Z"),
            word: "UPDATED",
            startRow: 6,
            startColumn: 7,
            direction: .vertical
        )

        let req = Request(application: app, on: app.eventLoopGroup.next())

        // Обновляем слово через сервис
        let futureResult = wordService.updateWord(word: updatedWordDTO, on: req)
        let result = try futureResult.wait()

        XCTAssertEqual(result.id, wordId)
        XCTAssertEqual(result.word, "UPDATED")
        XCTAssertEqual(result.startRow, 6)
        XCTAssertEqual(result.startColumn, 7)
        XCTAssertEqual(result.direction, .vertical)
    }

    /// Успешное удаление слова
    func testDeleteWord_Success() throws {
        let wordId = UUID()

        let word = Word(
            id: wordId,
            gameId: UUID(),
            playerId: UUID(),
            word: "DELETE",
            startRow: 1,
            startColumn: 2,
            direction: .horizontal
        )

        mockWordRepository.words[wordId] = word

        let req = Request(application: app, on: app.eventLoopGroup.next())

        // Удаляем слово через сервис
        let futureResult = wordService.deleteWord(id: wordId, on: req)
        try futureResult.wait()

        XCTAssertNil(mockWordRepository.words[wordId]) // Убеждаемся, что слово удалено из репозитория
    }
}



