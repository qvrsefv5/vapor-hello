import Fluent
import Vapor

struct UserController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let auth = routes.grouped("auth")
        let passwordProtected = auth.grouped(User.authenticator())
        auth.post("register", use: create)
        passwordProtected.post("login", use: login) 
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
    func login(req: Request) async throws -> HTTPStatus {
//        try LoginRequest.validate(content: req)
        let user = try req.auth.require(User.self)
        print("\(user)")
        let loginRequest = try req.content.decode(LoginRequest.self)
//        let user = try req.auth.require(User.self)
//        return [user: user.toDTO(), accessToken: "token"]
        return .ok
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
