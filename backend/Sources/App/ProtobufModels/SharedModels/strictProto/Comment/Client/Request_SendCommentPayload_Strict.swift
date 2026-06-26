import Foundation

struct Request_SendCommentPayload_Strict: Codable {
    var commentClientId: UUID
    var postServerId: UUID
    var text: String
    var replyToId: UUID?
    var replyEntityType: ChatEntityType?
    var timestamp: Date

    init(
        commentClientId: UUID,
        postServerId: UUID,
        text: String,
        replyToId: UUID?,
        replyEntityType: ChatEntityType?,
        timestamp: Date
    ) {
        self.commentClientId = commentClientId
        self.postServerId = postServerId
        self.text = text
        self.replyToId = replyToId
        self.replyEntityType = replyEntityType
        self.timestamp = timestamp
    }

    // Initialization from the gRPC model
    init(from entity: Entities_CommentEntity) throws {
        commentClientId = try parseUUID(from: entity.commentID.client)
        postServerId = try parseUUID(from: entity.postID.server)
        text = entity.text
        replyToId = try? parseUUID(from: entity.replyEntity.replyToID.server)
        replyEntityType = try? ChatEntityType(from: entity.replyEntity.replyEntityType)
        timestamp = try parseDate(from: entity.timestamp.isoDate)
    }

    // Conversion to the gRPC model
    func toProto() -> Entities_CommentEntity {
        let result = Entities_CommentEntity.with {
            $0.commentID.client = commentClientId.uuidString
            $0.postID.server = postServerId.uuidString
            $0.text = text
            $0.timestamp.isoDate = timestamp.ISO8601Format()

            if let replyToId = replyToId, let replyEntityType = replyEntityType {
                $0.replyEntity = Entities_ReplyEntity.with {
                    $0.replyToID.server = replyToId.uuidString
                    $0.replyEntityType = replyEntityType.toProtoEnum()
                }
            }
        }

        do {
            // Check that the fields are filled in
            let _ = try Request_SendCommentPayload_Strict(from: result)
        } catch {
            fatalError(#file)
        }
        return result
    }

    func asResponse(serverId: UUID) -> Response_SendCommentPayload_Strict {
        return Response_SendCommentPayload_Strict(
            commentClientId: commentClientId,
            commentServerId: serverId,
            timestamp: timestamp
        )
    }

    func asReceive(memberServerId: UUID, serverId: UUID) -> Request_ReceiveCommentPayload_Strict {
        return Request_ReceiveCommentPayload_Strict(
            commentServerId: serverId,
            postServerId: postServerId,
            memberServerId: memberServerId,
            text: text,
            replyToId: replyToId,
            replyEntityType: replyEntityType,
            timestamp: timestamp
        )
    }
}
