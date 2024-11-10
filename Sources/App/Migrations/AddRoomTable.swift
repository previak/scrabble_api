import Fluent

struct AddRoomTable: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("rooms")
            .id()
            .field("is_open", .bool, .required)
            .field("is_public", .bool, .required)
            .field("invitation_code", .string, .required)
            .field("game_state", .string, .required)
            .field("admin_id", .string, .required)
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("rooms").delete()
    }
}
