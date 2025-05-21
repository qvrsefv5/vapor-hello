import Fluent
import Vapor
import JWT

struct AuthController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let auth = routes.grouped("auth")
        let secure = auth.grouped(Payload.authenticator(), Payload.guardMiddleware())
        
        auth.post("login", use: login)
        secure.post("logout", use: logout)
        secure.get("refreshToken", use: refreshToken)
    }

      @Sendable
    func login(req: Request) async throws -> Response {
        try LoginRequest.validate(content: req)
        let loginData = try req.content.decode(LoginRequest.self)

        var fetchedUser: User
        if let user = try await User.query(on:req.db).filter(\.$email == loginData.email).first(){
            
            guard try Bcrypt.verify(loginData.password, created: user.$passwordHash.wrappedValue) else {
                throw Abort(.unauthorized, reason: "Invalid email or password")
            }
            
            fetchedUser=user
            
        } else {
            throw Abort(.unauthorized, reason: "Invalid email or password")
        }
        
        let accessPayload = try Payload(subject: SubjectClaim(value: fetchedUser.email), expiration: ExpirationClaim(value:Date().addingTimeInterval (Constants.accessTokenExpiration)), userId: String(fetchedUser.requireID()))
        let refreshPayload = try Payload(subject: SubjectClaim(value: fetchedUser.email), expiration: ExpirationClaim(value:Date().addingTimeInterval (/*Constants.refreshTokenExpiration*/3600)), userId: String(fetchedUser.requireID()))
        
        let refreshToken = UserToken(
            value: try await req.jwt.sign(refreshPayload),
            userID : try fetchedUser.requireID()
        )
        
        try await refreshToken.save(on: req.db)

        let response = Response()
        response.cookies["refreshToken"] = HTTPCookies.Value(
            string: refreshToken.value,
            expires: Date(timeIntervalSinceNow: Constants.refreshTokenExpiration), // 7 days
            path: "/",
            isSecure: true,
            isHTTPOnly: true,
            sameSite: .strict
        )

        try response.content.encode(LoginResponse( user: fetchedUser.toDTO(), accessToken: try await req.jwt.sign(accessPayload)))
        return response
    }
     
    @Sendable
    func logout(req: Request) async throws -> Response {
        
        guard let refreshToken = req.cookies["refreshToken"]?.string else {
            throw Abort(.unauthorized, reason: "Missing refresh token")
        }
        let response = Response(status: .ok)
        
        do {
            try await UserToken.query(on: req.db).filter(\.$value == refreshToken).delete()

            // Clear the refresh token cookie
            response.cookies["refreshToken"] = HTTPCookies.Value(
                string: "",
                expires: Date(timeIntervalSinceNow: -3600), // expire immediately
                path: "/",
                isSecure: true,
                isHTTPOnly: true,
                sameSite: .strict
            )

        } catch {
            throw Abort(.notFound, reason: "Error occurred!")
        }
        
        return response
    }
    
    @Sendable
    func refreshToken(req: Request) async throws -> [String: String] {
        
        guard let refreshToken = req.cookies["refreshToken"]?.string else {
            throw Abort(.unauthorized, reason: "Missing refresh token")
        }
        
        var accessPayload: Payload
        do {
            try await req.jwt.verify(refreshToken, as: Payload.self)
    
            let token = try await UserToken.query(on:req.db).filter(\.$value == refreshToken).first()
            let userId = token?.$user.id
            
            var fetchedUser: User
            if let user = try await User.query(on:req.db).filter(\.$id == userId!).first(){
                fetchedUser=user
            } else {
                throw Abort(.unauthorized, reason: "Invalid email or password")
            }
            
            accessPayload = try Payload(subject: SubjectClaim(value: fetchedUser.email), expiration: ExpirationClaim(value:Date().addingTimeInterval (Constants.accessTokenExpiration)), userId: String(fetchedUser.requireID()))
            
        } catch {
            try await UserToken.query(on: req.db).filter(\.$value == refreshToken).delete()
            throw Abort(.unauthorized, reason: "Token expired")
        }
        
        return ["token": try await req.jwt.sign(accessPayload)]
    }
}
