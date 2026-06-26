import Foundation
import GRDB

struct Comment: Codable, Hashable, FetchableRecord, PersistableRecord, OptionalServerIdentifiable {
    static let databaseTableName = "comments"

    var id: UUID
    var serverId: UUID?
    var postId: UUID
    var memberId: UUID
    var text: String
    var replyToId: UUID?
    var replyEntityType: ChatEntityType?
    var status: DeliveryStatus
    var createdAt: Date
    var editedAt: Date?

    init(
        serverId: UUID?,
        post: Post,
        member: ChatMember,
        text: String,
        replyToId: UUID?,
        replyEntityType: ChatEntityType?,
        status: DeliveryStatus,
        createdAt: Date,
        editedAt: Date?
    ) {
        id = UUID()
        self.serverId = serverId
        postId = post.id
        memberId = member.id
        self.text = text
        self.replyToId = replyToId
        self.replyEntityType = replyEntityType
        self.status = status
        self.createdAt = createdAt
        self.editedAt = editedAt
    }
}
