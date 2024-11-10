import Fluent

struct AddWordTable: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("words")
            .id()
            .field("game_id", .uuid, .required, .references("games", "id"))
            .field("player_id", .uuid, .required, .references("players", "id"))
            .field("word", .string, .required)
            .field("start_row", .int, .required)
            .field("start_column", .int, .required)
            .field("direction", .string, .required)
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("words").delete()
    }
}

