import Foundation
import GRDB

struct ChatMember: Codable, Hashable, FetchableRecord, PersistableRecord, ServerIdentifiable {
    static let databaseTableName = "chat_members"

    var id: UUID
    var serverId: UUID
    var userId: UUID
    var chatId: UUID
    var role: MemberRole

    init(serverId: UUID, user: User, chat: Chat, role: MemberRole) {
        id = UUID()
        self.serverId = serverId
        userId = user.id
        chatId = chat.id
        self.role = role
    }
}
