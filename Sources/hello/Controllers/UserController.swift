import Fluent
import Vapor

struct UserController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let user = routes.grouped("user")
        let secure = user.grouped(Payload.authenticator(), Payload.guardMiddleware())
        secure.post("register", use: create)
        secure.post("delete", use: delete)
    }
    
    @Sendable
    func create(req: Request) async throws -> UserDTO {
        try RegisterRequest.validate(content: req)
        let create = try req.content.decode(RegisterRequest.self)
        guard create.password == create.confirmPassword else {
            throw Abort(.badRequest, reason: "Passwords did not match")
        }
        let user = try User(
            email: create.email,
            passwordHash: Bcrypt.hash(create.password)
        )
        try await user.save(on: req.db)
        return user.toDTO()
    }

    @Sendable
    func delete(req: Request) async throws -> HTTPStatus {
        guard let todo = try await Todo.find(req.parameters.get("todoID"), on: req.db) else {
            throw Abort(.notFound)
        }
        
            try await todo.delete(on: req.db)
        
        return .noContent
    }
}
