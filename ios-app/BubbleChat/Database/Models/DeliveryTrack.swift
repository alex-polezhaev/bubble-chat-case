import Foundation
import GRDB

struct DeliveryTrack: Codable, FetchableRecord, PersistableRecord, OptionalServerIdentifiable {
    static let databaseTableName = "delivery_tracks"

    var id: UUID
    var serverId: UUID?
    var memberId: UUID
    var postId: UUID?
    var commentId: UUID?
    var layerId: UUID?
    var reactionId: UUID?
    var status: DeliveryStatus
    var timestamp: Date

    init(
        serverId: UUID?,
        member: ChatMember,
        post: Post?,
        comment: Comment?,
        layer: Layer?,
        reaction: Reaction?,
        status: DeliveryStatus,
        timestamp: Date
    ) {
        id = UUID()
        self.serverId = serverId
        memberId = member.id
        postId = post?.id
        commentId = comment?.id
        layerId = layer?.id
        reactionId = reaction?.id
        self.status = status
        self.timestamp = timestamp
    }
}
