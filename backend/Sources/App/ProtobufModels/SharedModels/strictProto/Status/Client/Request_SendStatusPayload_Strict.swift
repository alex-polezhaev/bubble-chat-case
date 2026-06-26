import Foundation

struct Request_SendStatusPayload_Strict: Codable {
    var chatServerId: UUID
    var chatMemberServerId: UUID

    var trackClientId: UUID
    var deliveryStatus: DeliveryStatus

    var postServerId: UUID?
    var commentServerId: UUID?
    var layerServerId: UUID?
    var reactionServerId: UUID?

    var timestamp: Date

    init(
        chatServerId: UUID,
        chatMemberServerId: UUID,
        trackClientId: UUID,
        deliveryStatus: DeliveryStatus,
        postServerId: UUID?,
        commentServerId: UUID?,
        layerServerId: UUID?,
        reactionServerId: UUID?,
        timestamp: Date
    ) {
        self.chatServerId = chatServerId
        self.chatMemberServerId = chatMemberServerId
        self.trackClientId = trackClientId
        self.deliveryStatus = deliveryStatus
        self.postServerId = postServerId
        self.commentServerId = commentServerId
        self.layerServerId = layerServerId
        self.reactionServerId = reactionServerId
        self.timestamp = timestamp
    }

    init(from proto: CommonRequests_DeliveryStatusPayload) throws {
        chatServerId = try parseUUID(from: proto.chatID.server)
        chatMemberServerId = try parseUUID(from: proto.memberID.server)
        trackClientId = try parseUUID(from: proto.trackID.client)
        deliveryStatus = try DeliveryStatus(from: proto.deliveryStatus)
        postServerId = proto.postID.server.isEmpty ? nil : try parseUUID(from: proto.postID.server)
        commentServerId = proto.commentID.server.isEmpty ? nil : try parseUUID(from: proto.commentID.server)
        layerServerId = proto.layerID.server.isEmpty ? nil : try parseUUID(from: proto.layerID.server)
        reactionServerId = proto.reactionID.server.isEmpty ? nil : try parseUUID(from: proto.reactionID.server)
        timestamp = try parseDate(from: proto.timestamp.isoDate)
    }

    func toProto() -> CommonRequests_DeliveryStatusPayload {
        var proto = CommonRequests_DeliveryStatusPayload()
        proto.chatID.server = chatServerId.uuidString
        proto.memberID.server = chatMemberServerId.uuidString
        proto.trackID.client = trackClientId.uuidString
        proto.deliveryStatus = deliveryStatus.toProtoEnum()
        proto.timestamp.isoDate = timestamp.ISO8601Format()

        if let postId = postServerId {
            proto.postID.server = postId.uuidString
        }
        if let commentId = commentServerId {
            proto.commentID.server = commentId.uuidString
        }
        if let layerId = layerServerId {
            proto.layerID.server = layerId.uuidString
        }
        if let reactionId = reactionServerId {
            proto.reactionID.server = reactionId.uuidString
        }

        return proto
    }
}

extension Request_SendStatusPayload_Strict {
    func asReceive(serverId: UUID) throws -> Request_ReceiveStatusPayload_Strict {
        return Request_ReceiveStatusPayload_Strict(chatServerId: chatServerId,
                                                   chatMemberServerId: chatMemberServerId,
                                                   trackServerId: serverId,
                                                   deliveryStatus: deliveryStatus,
                                                   postServerId: postServerId,
                                                   commentServerId: commentServerId,
                                                   layerServerId: layerServerId,
                                                   reactionServerId: reactionServerId,
                                                   timestamp: timestamp)
    }

    func asResponse(serverId: UUID) -> Response_SendStatusPayload_Strict {
        return Response_SendStatusPayload_Strict(trackClientId: trackClientId,
                                                 trackServerId: serverId,
                                                 timestamp: timestamp)
    }
}
