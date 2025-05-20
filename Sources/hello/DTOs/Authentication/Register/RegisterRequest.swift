import Vapor

struct RegisterRequest: Content {
    var name: String?
    var email: String
    var password: String
    var confirmPassword: String
}

extension RegisterRequest: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("email", as: String.self, is: .email)
        validations.add("password", as: String.self, is: .count(8...))
    }
}

// extension User {
//     convenience init (from register: RegisterRequest, hash:String) throws {
//         self.init(name: register.name, email: register.email, passwordHash: hash)
//     }
// }
