import Fluent
import Vapor
import struct Foundation.UUID
import JWT

final class UserToken: Model, @unchecked Sendable {
    static let schema = "user_tokens"
    
    @ID(key: .id)
    var id: UUID?

    @Field(key: "value")
    var value: String

    @Parent(key: "user_id")
    var user: User

    init(){}

    init(id: UUID? = nil, value: String, userID: User.IDValue){
        self.id = id
        self.value = value
        self.$user.id = userID
    }
}

struct Payload: Authenticatable, JWTPayload{
       // Maps the longer Swift property names to the
    // shortened keys used in the JWT payload.
    enum CodingKeys: String, CodingKey {
        case subject = "sub"
        case expiration = "exp"
        case userId = "string"
    }

    // The "sub" (subject) claim identifies the principal that is the
    // subject of the JWT.
    var subject: SubjectClaim

    // The "exp" (expiration time) claim identifies the expiration time on
    // or after which the JWT MUST NOT be accepted for processing.
    var expiration: ExpirationClaim

    // Custom data.
    // user id.
    var userId: String

    // Run any additional verification logic beyond
    // signature verification here.
    // Since we have an ExpirationClaim, we will
    // call its verify method.
    func verify(using algorithm: some JWTAlgorithm) async throws {
        try self.expiration.verifyNotExpired()
    }
}

// struct RefreshToken: Content,Authenticatable, JWTPayload {
//     // Constatns
//     let expirationTime: TimeInterval = 60//Constants.refreshTokenExpiration

//     // Token data
//     var expiration: ExpirationClaim
//     var userId: UUID

//     init(userId:UUID) {
//         self.userId = userId
//         self.expiration = ExpirationClaim(value: Date().addingTimeInterval(expirationTime))
//     }

//     init(user: User) throws {
//         self.userId = try user.requireID()
//         self.expiration = ExpirationClaim(value: Date().addingTimeInterval(expirationTime))
//     }

//     func verify(using algorithm: some JWTAlgorithm) throws {
//         try expiration.verifyNotExpired()
//     }
// }


// struct AccessToken: Content, Authenticatable, JWTPayload {
//     // Constatns
//     let expirationTime: TimeInterval = Constants.accessTokenExpiration

//     // Token data
//     var expiration: ExpirationClaim
//     var userId: UUID

//     init(userId:UUID) {
//         self.userId = userId
//         self.expiration = ExpirationClaim(value: Date().addingTimeInterval(expirationTime))
//     }

//     init(user: User) throws {
//         self.userId = try user.requireID()
//         self.expiration = ExpirationClaim(value: Date().addingTimeInterval(expirationTime))
//     }

//     func verify(using algorithm: some JWTAlgorithm) throws {
//         try expiration.verifyNotExpired()
//     }
// }
