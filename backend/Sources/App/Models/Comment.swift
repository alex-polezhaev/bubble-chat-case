import Fluent
import Vapor

final class Comment: Model, Content, @unchecked Sendable,
    ClientIdentifiable,
    PostIdentifiable,
    MemberIdentifiable,
    Replyable,
    DeliveryTrackable
{
    static let schema = "comments"

    // MARK: - Ident

    @ID(key: .id)
    var id: UUID?

    @Field(key: "client_id")
    var clientId: UUID

    @Parent(key: "post_id")
    var post: Post

    @Parent(key: "member_id")
    var member: ChatMember

    // MARK: - Data

    @Field(key: "text")
    var text: String

    // MARK: - Other

    @Field(key: "reply_to_id")
    var replyToId: UUID?

    @OptionalEnum(key: "reply_entity_type")
    var replyEntityType: ChatEntityType?

    // MARK: - Other

    @Enum(key: "delivery_status")
    var status: DeliveryStatus

    @Field(key: "created_at")
    var createdAt: Date

    @OptionalField(key: "edited_at")
    var editedAt: Date?

    init() {}

    init(clientId: UUID, post: Post, member: ChatMember, text: String, replyToId: UUID?, replyEntityType: ChatEntityType?, status: DeliveryStatus, createdAt: Date, editedAt: Date?) throws {
        id = UUID()
        self.clientId = clientId
        self.$post.id = try post.requireID()
        self.$member.id = try member.requireID()
        self.text = text
        self.replyToId = replyToId
        self.replyEntityType = replyEntityType
        self.status = status
        self.createdAt = createdAt
        self.editedAt = editedAt
    }
}
