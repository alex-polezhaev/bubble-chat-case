import Foundation
import GRDB

struct Reaction: Codable, FetchableRecord, PersistableRecord, OptionalServerIdentifiable {
    static let databaseTableName = "reactions"

    var id: UUID
    var serverId: UUID?
    var postId: UUID?
    var commentId: UUID?
    var chatEntityType: ChatEntityType
    var memberId: UUID
    var emoji: String
    var status: DeliveryStatus
    var createdAt: Date
    var editedAt: Date?

    init(
        serverId: UUID?,
        post: Post?,
        comment: Comment?,
        chatEntityType: ChatEntityType,
        member: ChatMember,
        emoji: String,
        status: DeliveryStatus,
        createdAt: Date,
        editedAt: Date?
    ) {
        id = UUID()
        self.serverId = serverId
        postId = post?.id
        commentId = comment?.id
        self.chatEntityType = chatEntityType
        memberId = member.id
        self.emoji = emoji
        self.status = status
        self.createdAt = createdAt
        self.editedAt = editedAt
    }
}
