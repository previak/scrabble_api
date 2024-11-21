import Fluent

struct AddRemainingTilesColumn: AsyncMigration {
    
    func prepare(on database: Database) async throws {
        try await database.schema("games")
            .field("remaining_tiles", .string, .required)
            .update()
    }

    func revert(on database: Database) async throws {
        try await database.schema("games")
            .deleteField("remaining_tiles")
            .update()
    }
}
