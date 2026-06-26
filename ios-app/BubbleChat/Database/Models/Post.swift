import Foundation
import GRDB

struct Post: Codable, Hashable, FetchableRecord, PersistableRecord, OptionalServerIdentifiable {
    static let databaseTableName = "posts"

    var id: UUID
    var serverId: UUID?
    var chatId: UUID
    var memberId: UUID
    var postType: PostType
    var mediaId: UUID?
    var title: String?
    var description: String?
    var replyToId: UUID?
    var replyEntityType: ChatEntityType?
    var status: DeliveryStatus
    var createdAt: Date
    var editedAt: Date?

    init(
        serverId: UUID?,
        chat: Chat,
        member: ChatMember,
        postType: PostType,
        media: Media?,
        title: String?,
        description: String?,
        replyToId: UUID?,
        replyEntityType: ChatEntityType?,
        status: DeliveryStatus,
        createdAt: Date,
        editedAt: Date?
    ) {
        id = UUID()
        self.serverId = serverId
        chatId = chat.id
        memberId = member.id
        self.postType = postType
        mediaId = media?.id
        self.title = title
        self.description = description
        self.replyToId = replyToId
        self.replyEntityType = replyEntityType
        self.status = status
        self.createdAt = createdAt
        self.editedAt = editedAt
    }
}

extension Post {
    var media: Media? {
        get throws {
            try AppDatabase.shared.dbPool.read { db in
                guard let mediaId else { return nil }
                return try Media.fetchOne(db, key: mediaId)
            }
        }
    }
}
