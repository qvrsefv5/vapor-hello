import Fluent
import Vapor

struct UserDTO: Content {
    var id: UUID?
    var name: String?
    var email: String
    var token: [String]?
    var createdAt: Date?
    var updatedAt: Date?
    
    
    func toModel() -> User {
        let model = User()
        
        model.id = self.id
        model.name = self.name
        model.email = self.email

        return model
    }
}


//extension User: ModelAuthenticatable {
//   static let usernameKey = \User.$email
//   static let passwordHashKey = \User.$passwordHash
//
//   func verify(password: String) throws -> Bool {
//       try Bcrypt.verify(password, created: self.passwordHash)
//   }
//}
//
//struct UserAuthenticator: AsyncBearerAuthenticator {
//    typealias User = App.User
//
//    func authenticate(
//        bearer: BearerAuthorization,
//        for request: Request
//    ) async throws {
//       if bearer.token == "foo" {
//           request.auth.login(User(name: "Vapor"))
//       }
//   }
//}


