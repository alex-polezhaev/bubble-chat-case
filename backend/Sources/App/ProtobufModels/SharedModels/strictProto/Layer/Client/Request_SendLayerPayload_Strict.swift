//
//  Request_SendLayerPayload_Strict.swift
//  BubbleBackendVapor
//
//  Created by polezhaev_aleksandr on 14.12.2024.
//

import Foundation

struct Request_SendLayerPayload_Strict: Codable {
    var layerClientId: UUID
    var postServerId: UUID

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
        layerClientId: UUID,
        postServerId: UUID,
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
        self.layerClientId = layerClientId
        self.postServerId = postServerId
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
        layerClientId = try parseUUID(from: entity.layerID.client)
        postServerId = try parseUUID(from: entity.postID.server)
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
            $0.layerID.client = layerClientId.uuidString
            $0.postID.server = postServerId.uuidString
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
            let _ = try Request_SendLayerPayload_Strict(from: result)
        } catch {
            fatalError(#file)
        }
        return result
    }

    func asResponse(serverId: UUID) -> Response_SendLayerPayload_Strict {
        return Response_SendLayerPayload_Strict(
            layerClientId: layerClientId,
            layerServerId: serverId,
            timestamp: timestamp
        )
    }

    func asReceive(memberServerId: UUID, serverId: UUID) -> Request_ReceiveLayerPayload_Strict {
        return Request_ReceiveLayerPayload_Strict(
            layerServerId: serverId,
            postServerId: postServerId,
            memberServerId: memberServerId,
            layerType: layerType,
            x: x,
            y: y,
            scale: scale,
            rotation: rotation,
            textAttributes: textAttributes,
            gifAttributes: gifAttributes,
            stickerAttributes: stickerAttributes,
            timestamp: timestamp
        )
    }
}
