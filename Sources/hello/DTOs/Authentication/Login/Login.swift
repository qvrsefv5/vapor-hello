import Vapor
import Fluent

struct LoginRequest: Content {
    var email: String
    var password: String
}

extension LoginRequest: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("email", as: String.self, is: .email)
        validations.add("password", as: String.self, is: !.empty)
    }
}

struct LoginResponse: Content {
    let user: UserDTO
    let accessToken: String
}

