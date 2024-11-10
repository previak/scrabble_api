import Fluent

struct AddBoardTable: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("boards")
            .id()
            .field("game_id", .uuid, .required, .references("games", "id"))
            .field("tiles", .json, .required)
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("boards").delete()
    }
}
