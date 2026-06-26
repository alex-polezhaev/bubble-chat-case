import Fluent
import Vapor

final class VerificationCode: Model, Content, @unchecked Sendable,
    UserIdentifiable
{
    static let schema = "verification_codes"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "user_id")
    var user: User

    @Field(key: "code")
    var code: String

    @Field(key: "expires_at")
    var expiresAt: Date

    init() {}

    init(user: User, code: String, expiresAt: Date) throws {
        id = UUID()
        self.$user.id = try user.requireID()
        self.code = code
        self.expiresAt = expiresAt
    }
}
