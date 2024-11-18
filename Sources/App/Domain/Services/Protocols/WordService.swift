import Vapor

protocol WordService {
    func getWord(id: UUID, on req: Request) -> EventLoopFuture<WordDTO>
    func createWord(word: WordDTO, on req: Request) -> EventLoopFuture<WordDTO>
    func updateWord(word: WordDTO, on req: Request) -> EventLoopFuture<WordDTO>
    func deleteWord(id: UUID, on req: Request) -> EventLoopFuture<Void>
}
