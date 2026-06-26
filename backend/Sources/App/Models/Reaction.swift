import Fluent
import Vapor

final class Reaction: Model, Content, @unchecked Sendable,
    ClientIdentifiable,
    MemberIdentifiable,
    DeliveryTrackable
{
    static let schema = "reactions" // Table name in the database

    @ID(key: .id)
    var id: UUID?

    @Field(key: "client_id")
    var clientId: UUID

    @OptionalParent(key: "post_id")
    var post: Post?

    @OptionalParent(key: "comment_id")
    var comment: Comment?

    @Enum(key: "chat_entity_type")
    var chatEntityType: ChatEntityType

    @Parent(key: "member_id")
    var member: ChatMember

    // MARK: - Data

    @Field(key: "emoji")
    var emoji: String

    // MARK: - Other

    @Enum(key: "delivery_status")
    var status: DeliveryStatus

    @Field(key: "created_at")
    var createdAt: Date

    @OptionalField(key: "edited_at")
    var editedAt: Date?

    init() {}

    init(clientId: UUID, post: Post?, comment: Comment?, chatEntityType: ChatEntityType, member: ChatMember, emoji: String, status: DeliveryStatus, createdAt: Date, editedAt: Date?) throws {
        id = UUID()
        self.clientId = clientId
        self.$post.id = try post?.requireID()
        self.$comment.id = try comment?.requireID()
        self.chatEntityType = chatEntityType
        self.$member.id = try member.requireID()
        self.emoji = emoji
        self.status = status
        self.createdAt = createdAt
        self.editedAt = editedAt
    }
}
