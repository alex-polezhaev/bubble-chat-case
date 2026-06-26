import Foundation
import GRDB

struct Layer: Codable, FetchableRecord, PersistableRecord, OptionalServerIdentifiable {
    static let databaseTableName = "layers"

    var id: UUID
    var serverId: UUID?
    var postId: UUID
    var memberId: UUID
    var x: Double
    var y: Double
    var scale: Double
    var rotation: Double
    var layerType: LayerType
    var textAttributes: TextAttributes?
    var gifAttributes: GifAttributes?
    var stickerAttributes: StickerAttributes?
    var status: DeliveryStatus
    var createdAt: Date
    var editedAt: Date?

    init(
        serverId: UUID?,
        post: Post,
        member: ChatMember,
        x: Double,
        y: Double,
        scale: Double,
        rotation: Double,
        layerType: LayerType,
        textAttributes: TextAttributes?,
        gifAttributes: GifAttributes?,
        stickerAttributes: StickerAttributes?,
        status: DeliveryStatus,
        createdAt: Date,
        editedAt: Date?
    ) {
        id = UUID()
        self.serverId = serverId
        postId = post.id
        memberId = member.id
        self.x = x
        self.y = y
        self.scale = scale
        self.rotation = rotation
        self.layerType = layerType
        self.textAttributes = textAttributes
        self.gifAttributes = gifAttributes
        self.stickerAttributes = stickerAttributes
        self.status = status
        self.createdAt = createdAt
        self.editedAt = editedAt
    }
}

extension TextAttributes: DatabaseValueConvertible {}
extension GifAttributes: DatabaseValueConvertible {}
extension StickerAttributes: DatabaseValueConvertible {}
