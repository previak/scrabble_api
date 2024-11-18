import Fluent

struct AddPlayerTable: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("players")
            .id()
            .field("user_id", .uuid, .required, .references("users", "id"))
            .field("room_id", .uuid, .required, .references("rooms", "id"))
            .field("nickname", .string, .required)
            .field("score", .int, .required)
            .field("turn_order", .int, .required)
            .field("available_letters", .string, .required)
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("players").delete()
    }
}
