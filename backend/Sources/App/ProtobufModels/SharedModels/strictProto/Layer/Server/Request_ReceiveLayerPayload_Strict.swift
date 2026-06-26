import Foundation

struct Request_ReceiveLayerPayload_Strict: Codable {
    var layerServerId: UUID
    var postServerId: UUID
    var memberServerId: UUID

    var layerType: LayerType
    var x: Double
    var y: Double
    var scale: Double
    var rotation: Double

    var textAttributes: TextAttributes?
    var gifAttributes: GifAttributes?
    var stickerAttributes: StickerAttributes?

    var timestamp: Date

    init(
        layerServerId: UUID,
        postServerId: UUID,
        memberServerId: UUID,
        layerType: LayerType,
        x: Double,
        y: Double,
        scale: Double,
        rotation: Double,
        textAttributes: TextAttributes?,
        gifAttributes: GifAttributes?,
        stickerAttributes: StickerAttributes?,
        timestamp: Date
    ) {
        self.layerServerId = layerServerId
        self.postServerId = postServerId
        self.memberServerId = memberServerId
        self.layerType = layerType
        self.x = x
        self.y = y
        self.scale = scale
        self.rotation = rotation
        self.textAttributes = textAttributes
        self.gifAttributes = gifAttributes
        self.stickerAttributes = stickerAttributes
        self.timestamp = timestamp
    }

    // Initialization from the gRPC model
    init(from entity: Entities_LayerEntity) throws {
        layerServerId = try parseUUID(from: entity.layerID.server)
        postServerId = try parseUUID(from: entity.postID.server)
        memberServerId = try parseUUID(from: entity.memberID.server)
        layerType = try LayerType(from: entity.layerType)
        x = entity.x
        y = entity.y
        scale = entity.scale
        rotation = entity.rotation
        textAttributes = try? TextAttributes(from: entity.textAttributes)
        gifAttributes = try? GifAttributes(from: entity.gifAttributes)
        stickerAttributes = try? StickerAttributes(from: entity.stickerAttributes)
        timestamp = try parseDate(from: entity.timestamp.isoDate)
    }

    // Conversion to the gRPC model
    func toProto() -> Entities_LayerEntity {
        let result = Entities_LayerEntity.with {
            $0.layerID.server = layerServerId.uuidString
            $0.postID.server = postServerId.uuidString
            $0.memberID.server = memberServerId.uuidString
            $0.layerType = layerType.toProtoEnum()
            $0.x = x
            $0.y = y
            $0.scale = scale
            $0.rotation = rotation
            $0.timestamp.isoDate = timestamp.ISO8601Format()

            if let textAttributes = textAttributes {
                $0.textAttributes = textAttributes.toProto()
            }
            if let gifAttributes = gifAttributes {
                $0.gifAttributes = gifAttributes.toProto()
            }
            if let stickerAttributes = stickerAttributes {
                $0.stickerAttributes = stickerAttributes.toProto()
            }
        }

        do {
            // Check that the fields are filled in
            let _ = try Request_ReceiveLayerPayload_Strict(from: result)
        } catch {
            fatalError(#file)
        }
        return result
    }
}
