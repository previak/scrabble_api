import Vapor

protocol WordRepository: Sendable {
    func find(id: UUID, on req: Request) -> EventLoopFuture<Word?>
    func create(word: Word, on req: Request) -> EventLoopFuture<Word>
    func update(word: Word, on req: Request) -> EventLoopFuture<Word>
    func delete(id: UUID, on req: Request) -> EventLoopFuture<Void>
}
