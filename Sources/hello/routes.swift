import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get { req async in
        "It works!"
    }

    app.get("hello") { req async -> String in
        "Hello, world!"
    }
    app.group("api") { api in
        try! api.register(collection: TodoController())
        try! api.register(collection: UserController())
        try! api.register(collection: AuthController())
    }
}
