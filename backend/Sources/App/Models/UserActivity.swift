import Fluent
import Vapor

final class UserActivity: Model, Content, @unchecked Sendable, UserIdentifiable {
    static let schema = "user_activities"

    // MARK: - Identifiers

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "user_id")
    var user: User

    // MARK: - Data

    @Field(key: "last_active_at")
    var lastActiveAt: Date

    // Stream activity
    @Field(key: "is_server_to_client_stream_active")
    var isServerToClientStreamActive: Bool

    @Field(key: "is_client_to_server_stream_active")
    var isClientToServerStreamActive: Bool

    @Field(key: "is_contact_stream_active")
    var isContactStreamActive: Bool

    // Computed user status
    var status: UserStatus {
        if isServerToClientStreamActive || isClientToServerStreamActive || isContactStreamActive {
            return .online
        } else {
            return .offline
        }
    }

    init() {}

    init(user: User, lastActiveAt: Date) throws {
        id = UUID()
        self.$user.id = try user.requireID()
        self.lastActiveAt = lastActiveAt
        isServerToClientStreamActive = false
        isClientToServerStreamActive = false
        isContactStreamActive = false
    }
}

extension UserActivity {
    func asPublic() throws -> PublicUserActivity {
        try PublicUserActivity(
            id: requireID(),
            lastActiveAt: lastActiveAt,
            userStatus: status
        )
    }
}
