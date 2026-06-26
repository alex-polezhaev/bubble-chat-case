import Fluent
import Vapor

struct UserController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let users = routes.grouped("users")

        users.get(":userId", use: get)
        users.grouped(UserIdMiddleware()).post("deviceToken", use: updateDeviceToken)
    }

    // Read: get a single user by ID
    @Sendable
    func get(req: Request) async throws -> PublicUser {
        guard let user = try await User.find(req.parameters.get("userId", as: UUID.self), on: req.db)
        else {
            throw Abort(.notFound) // Return a 404 error if the user is not found
        }
        return user.asPublic()
    }

    // Update: update a user by ID
    @Sendable
    func updateDeviceToken(req: Request) async throws -> Response {
        let updateRequest = try req.content.decode(UpdateDeviceTokenRequest.self)

        // Look up the user by user_id
        guard let user = try await User.find(req.userId, on: req.db) else {
            throw Abort(.notFound, reason: "User not found")
        }

        // Update the deviceToken of the found user
        user.deviceToken = updateRequest.deviceToken

        // Save the updated user to the database
        try await user.save(on: req.db)

        // Return a successful response
        return Response(status: .ok)
    }
}
