import Vapor

func routes(_ app: Application) throws {
    try app.register(collection: UserController())
    try app.register(collection: AuthController())
    try app.register(collection: AssetController())
    try app.register(collection: ChatController())
    try app.register(collection: ContactController())
    try app.register(collection: ImageController())
}
