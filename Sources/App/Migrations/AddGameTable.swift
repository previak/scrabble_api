import Fluent

struct AddGameTable: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("games")
            .id()
            .field("room_id", .uuid, .required, .references("rooms", "id"))
            .field("is_paused", .bool, .required)
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("games").delete()
    }
}
