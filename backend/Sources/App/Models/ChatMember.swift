import Fluent
import Vapor

final class ChatMember: Model, Content, @unchecked Sendable,
    UserIdentifiable,
    ChatIdentifiable
{
    static let schema = "chat_members"

    // MARK: - Ident

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "user_id")
    var user: User

    @Parent(key: "chat_id")
    var chat: Chat

    // MARK: - Data

    @Enum(key: "role")
    var role: MemberRole

    init() {}

    init(user: User, chat: Chat, role: MemberRole) throws {
        id = UUID()
        self.$user.id = try user.requireID()
        self.$chat.id = try chat.requireID()
        self.role = role
    }
}

extension ChatMember {
    func asPublic() throws -> PublicChatMember {
        return try PublicChatMember(
            id: requireID(),
            chatId: $chat.id,
            userId: $user.id,
            role: role
        )
    }
}
