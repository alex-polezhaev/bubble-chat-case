import Foundation

struct Request_SendReactionPayload_Strict: Codable {
    var reactionClientId: UUID
    var chatEntityType: ChatEntityType
    var postServerId: UUID?
    var commentServerId: UUID?
    var emoji: String
    var timestamp: Date

    init(
        reactionClientId: UUID,
        chatEntityType: ChatEntityType,
        postServerId: UUID?,
        commentServerId: UUID?,
        emoji: String,
        timestamp: Date
    ) {
        self.reactionClientId = reactionClientId
        self.chatEntityType = chatEntityType
        self.postServerId = postServerId
        self.commentServerId = commentServerId
        self.emoji = emoji
        self.timestamp = timestamp
    }

    // Initialization from the gRPC model
    init(from entity: Entities_ReactionEntity) throws {
        reactionClientId = try parseUUID(from: entity.reactionID.client)
        chatEntityType = try ChatEntityType(from: entity.chatEntityType)
        postServerId = try? parseUUID(from: entity.postID.server)
        commentServerId = try? parseUUID(from: entity.commentID.server)
        emoji = entity.emoji
        timestamp = try parseDate(from: entity.timestamp.isoDate)
    }

    // Conversion to the gRPC model
    func toProto() -> Entities_ReactionEntity {
        let result = Entities_ReactionEntity.with {
            $0.reactionID.client = reactionClientId.uuidString
            $0.chatEntityType = chatEntityType.toProtoEnum()
            $0.emoji = emoji
            $0.timestamp.isoDate = timestamp.ISO8601Format()

            if let postServerId = postServerId {
                $0.postID.server = postServerId.uuidString
            }
            if let commentServerId = commentServerId {
                $0.commentID.server = commentServerId.uuidString
            }
        }

        do {
            // Check that the fields are filled in
            let _ = try Request_SendReactionPayload_Strict(from: result)
        } catch {
            fatalError(#file)
        }
        return result
    }

    func asResponse(serverId: UUID) -> Response_SendReactionPayload_Strict {
        return Response_SendReactionPayload_Strict(
            reactionClientId: reactionClientId,
            reactionServerId: serverId,
            timestamp: timestamp
        )
    }

    func asReceive(memberServerId: UUID, serverId: UUID) -> Request_ReceiveReactionPayload_Strict {
        return Request_ReceiveReactionPayload_Strict(
            reactionServerId: serverId,
            memberServerId: memberServerId,
            chatEntityType: chatEntityType,
            postServerId: postServerId,
            commentServerId: commentServerId,
            emoji: emoji,
            timestamp: timestamp
        )
    }
}
