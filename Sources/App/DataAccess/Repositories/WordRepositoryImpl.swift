import Vapor

final class WordRepositoryImpl: WordRepository {
    func find(id: UUID, on req: Request) -> EventLoopFuture<Word?> {
        return Word.find(id, on: req.db)
    }
    
    func create(word: Word, on req: Request) -> EventLoopFuture<Word> {
        return word.save(on: req.db).map { word }
    }
    
    func update(word: Word, on req: Request) -> EventLoopFuture<Word> {
        return word.update(on: req.db).map { word }
    }
    
    func delete(id: UUID, on req: Request) -> EventLoopFuture<Void> {
        return Word.find(id, on: req.db).flatMap { word in
            guard let word = word else {
                return req.eventLoop.makeFailedFuture(Abort(.notFound))
            }
            return word.delete(on: req.db)
        }
    }
}
