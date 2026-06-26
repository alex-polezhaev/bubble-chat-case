import Foundation
import GRDB

struct Chat: Codable, Hashable, FetchableRecord, PersistableRecord, ServerIdentifiable {
    static let databaseTableName = "chats"

    var id: UUID
    var serverId: UUID
    var chatType: ChatType

    var title: String?
    var picture: String?

    init(serverId: UUID, chatType: ChatType, title: String?, picture: String?) {
        id = UUID()
        self.serverId = serverId
        self.chatType = chatType
        self.title = title
        self.picture = picture
    }
}
