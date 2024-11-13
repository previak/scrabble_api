import Vapor

struct WordController: RouteCollection, Sendable {
    private let wordService: WordService
    
    init(wordService: WordService) {
        self.wordService = wordService
    }
    
    func boot(routes: RoutesBuilder) throws {
        let words = routes.grouped("words")
        
        words.get(":id", use: getWord)
        words.post(use: createWord)
        words.put(":id", use: updateWord)
        words.delete(":id", use: deleteWord)
    }
    
    @Sendable
    func getWord(req: Request) throws -> EventLoopFuture<WordDTO> {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Missing or invalid word ID.")
        }
        return wordService.getWord(id: id, on: req)
    }
    
    @Sendable
    func createWord(req: Request) throws -> EventLoopFuture<WordDTO> {
        let word = try req.content.decode(WordDTO.self)
        return wordService.createWord(word: word, on: req)
    }
    
    @Sendable
    func updateWord(req: Request) throws -> EventLoopFuture<WordDTO> {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Missing or invalid word ID.")
        }
        var word = try req.content.decode(WordDTO.self)
        word.id = id
        return wordService.updateWord(word: word, on: req)
    }
    
    @Sendable
    func deleteWord(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Missing or invalid word ID.")
        }
        return wordService.deleteWord(id: id, on: req).transform(to: .noContent)
    }
}
