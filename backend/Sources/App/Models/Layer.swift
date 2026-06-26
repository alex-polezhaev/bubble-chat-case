import Fluent
import Vapor

final class Layer: Model, Content, @unchecked Sendable,
    ClientIdentifiable,
    PostIdentifiable,
    MemberIdentifiable,
    DeliveryTrackable
{
    static let schema = "layers"

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

    @Field(key: "x")
    var x: Double

    @Field(key: "y")
    var y: Double

    @Field(key: "scale")
    var scale: Double

    @Field(key: "rotation")
    var rotation: Double

    // MARK: - Type

    @Enum(key: "type")
    var layerType: LayerType

    @Field(key: "text_attributes")
    var textAttributes: TextAttributes?

    @Field(key: "gif_attributes")
    var gifAttributes: GifAttributes?

    @Field(key: "sticker_attributes")
    var stickerAttributes: StickerAttributes?

    // MARK: - Other

    @Enum(key: "delivery_status")
    var status: DeliveryStatus

    @Field(key: "created_at")
    var createdAt: Date

    @OptionalField(key: "edited_at")
    var editedAt: Date?

    init() {}

    init(clientId: UUID, post: Post, member: ChatMember, x: Double, y: Double, scale: Double, rotation: Double, layerType: LayerType, textAttributes: TextAttributes?, gifAttributes: GifAttributes?, stickerAttributes: StickerAttributes?, status: DeliveryStatus, createdAt _: Date, editedAt _: Date?) throws {
        id = UUID()
        self.clientId = clientId
        self.$post.id = try post.requireID()
        self.$member.id = try member.requireID()

        self.x = x
        self.y = y
        self.scale = scale
        self.rotation = rotation

        self.layerType = layerType
        self.textAttributes = textAttributes
        self.gifAttributes = gifAttributes
        self.stickerAttributes = stickerAttributes

        self.status = status
        createdAt = Date()
        editedAt = Date()
    }
}
