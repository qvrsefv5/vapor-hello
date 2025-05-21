import Fluent
import FluentSQL

struct CreateToken: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("user_tokens")
            .id()
            .field("value", .string)
            .field("user_id", .uuid, .required, .references("users", "id"))
            .unique(on: "value")
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema("user_tokens").delete()
    }
}
