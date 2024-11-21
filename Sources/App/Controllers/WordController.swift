import Vapor

struct WordController: RouteCollection, Sendable {
    private let wordService: WordService
    
    init(wordService: WordService) {
        self.wordService = wordService
    }
    
    func boot(routes: RoutesBuilder) throws {
        _ = routes.grouped("words")
        
    }
    
}
