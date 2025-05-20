import Fluent
import Vapor
import struct Foundation.UUID

final class User: Model, @unchecked Sendable {
    static let schema = "users"
    
    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String?

    @Field(key: "email")
    var email: String

    @Field(key: "password_hash")
    var passwordHash: String
    
    @Field(key: "token")
    var token: [String?]?

    @Timestamp(key: "created_at", on: .create, format: .iso8601)
    var createdAt: Date?
    
    @Timestamp(key: "updated_at", on: .update, format: .iso8601)
    var updatedAt: Date?
    

    init() { }

    init(id: UUID? = nil, name: String? = nil, email: String, passwordHash: String, token: [String]? = []) {
        self.id = id
        self.name = name
        self.email = email
        self.passwordHash = passwordHash
        self.token = token
    }

    func toDTO() -> UserDTO {
        .init(
            id: self.id,
            email: self.$email.value ?? "test@test.com"
        )
    }
    
}


extension User: ModelAuthenticatable {
    static let usernameKey: KeyPath<User, Field<String>> = \.$email
    static let passwordHashKey: KeyPath<User, Field<String>> = \.$passwordHash

    func verify(password: String) throws -> Bool {
        try Bcrypt.verify(password, created: self.passwordHash)
    }
}

