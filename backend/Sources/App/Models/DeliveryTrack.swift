import Fluent
import Vapor

final class DeliveryTrack: Model, Content, @unchecked Sendable,
    MemberIdentifiable
{
    static let schema = "delivery_tracks" // Table name

    // MARK: - Ident

    @ID(key: .id)
    var id: UUID?

    @OptionalField(key: "client_id")
    var clientId: UUID?

    @OptionalParent(key: "post_id")
    var post: Post?

    @OptionalParent(key: "comment_id")
    var comment: Comment?

    @OptionalParent(key: "layer_id")
    var layer: Layer?

    @OptionalParent(key: "reaction_id")
    var reaction: Reaction?

    @Parent(key: "member_id")
    var member: ChatMember

    // MARK: - Data

    @Enum(key: "status")
    var status: DeliveryStatus

    @Field(key: "timestamp")
    var timestamp: Date

    init() {}

    init(clientId: UUID?,
         post: Post?,
         comment: Comment?,
         layer: Layer?,
         reaction: Reaction?,
         member: ChatMember,
         status: DeliveryStatus,
         timestamp: Date) throws
    {
        self.clientId = clientId
        self.$post.id = post?.id
        self.$comment.id = comment?.id
        self.$layer.id = layer?.id
        self.$reaction.id = reaction?.id
        self.$member.id = try member.requireID()
        self.status = status
        self.timestamp = timestamp
    }
}
