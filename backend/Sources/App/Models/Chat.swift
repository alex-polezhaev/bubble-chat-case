import Fluent
import Vapor

final class Chat: Model, Content, @unchecked Sendable {
    static let schema = "chats"

    // MARK: - Ident

    @ID(key: .id)
    var id: UUID?

    // MARK: - Data

    @Enum(key: "chat_type")
    var chatType: ChatType

    @OptionalField(key: "title")
    var title: String?

    init() {}

    init(chatType: ChatType,
         title: String?)
    {
        id = UUID()
        self.chatType = chatType
        self.title = title
    }
}

extension Chat {
    func asPublic() throws -> PublicChat {
        try PublicChat(id: requireID(), chatType: chatType)
    }
}
