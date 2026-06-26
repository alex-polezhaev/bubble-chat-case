import Fluent
import Vapor

final class Post: Model, Content, @unchecked Sendable,
    ClientIdentifiable,
    ChatIdentifiable,
    MemberIdentifiable,
    Replyable,
    DeliveryTrackable
{
    static let schema = "posts" // Table name in the database

    // MARK: - Ident

    @ID(key: .id)
    var id: UUID?

    @Field(key: "client_id")
    var clientId: UUID

    @Parent(key: "chat_id")
    var chat: Chat

    @Parent(key: "member_id")
    var member: ChatMember

    // MARK: - Data

    @Enum(key: "post_type")
    var postType: PostType

    @OptionalParent(key: "media_id")
    var media: Media?

    @OptionalField(key: "title")
    var title: String?

    @OptionalField(key: "description")
    var description: String? // Topic description

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

    init(clientId: UUID, chat: Chat, member: ChatMember, postType: PostType, media: Media?, title: String?, description: String?, replyToId: UUID?, replyEntityType: ChatEntityType?, status: DeliveryStatus, createdAt: Date, editedAt: Date?) throws {
        id = UUID()
        self.clientId = clientId
        self.$chat.id = try chat.requireID()
        self.$member.id = try member.requireID()
        self.postType = postType
        self.$media.id = try media?.requireID()
        self.title = title
        self.description = description
        self.replyToId = replyToId
        self.replyEntityType = replyEntityType
        self.status = status
        self.createdAt = createdAt
        self.editedAt = editedAt
    }
}
