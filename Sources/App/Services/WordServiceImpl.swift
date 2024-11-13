import Vapor

final class WordServiceImpl: WordService {
    private let wordRepository: WordRepository
    
    init(wordRepository: WordRepository) {
        self.wordRepository = wordRepository
    }
    
    func getWord(id: UUID, on req: Request) -> EventLoopFuture<WordDTO> {
        return wordRepository.find(id: id, on: req).flatMapThrowing { word in
            guard let word = word else {
                throw Abort(.notFound)
            }
            return word.toDTO()
        }
    }
    
    func createWord(word: WordDTO, on req: Request) -> EventLoopFuture<WordDTO> {
        let model = word.toModel()
        return wordRepository.create(word: model, on: req).map { $0.toDTO() }
    }
    
    func updateWord(word: WordDTO, on req: Request) -> EventLoopFuture<WordDTO> {
        let model = word.toModel()
        return wordRepository.update(word: model, on: req).map { $0.toDTO() }
    }
    
    func deleteWord(id: UUID, on req: Request) -> EventLoopFuture<Void> {
        return wordRepository.delete(id: id, on: req)
    }
}
