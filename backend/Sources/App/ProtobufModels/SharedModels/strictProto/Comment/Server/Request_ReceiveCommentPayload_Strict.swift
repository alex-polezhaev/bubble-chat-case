import Foundation

struct Request_ReceiveCommentPayload_Strict: Codable {
    var commentServerId: UUID
    var postServerId: UUID
    var memberServerId: UUID
    var text: String
    var replyToId: UUID?
    var replyEntityType: ChatEntityType?
    var timestamp: Date

    init(
        commentServerId: UUID,
        postServerId: UUID,
        memberServerId: UUID,
        text: String,
        replyToId: UUID?,
        replyEntityType: ChatEntityType?,
        timestamp: Date
    ) {
        self.commentServerId = commentServerId
        self.postServerId = postServerId
        self.memberServerId = memberServerId
        self.text = text
        self.replyToId = replyToId
        self.replyEntityType = replyEntityType
        self.timestamp = timestamp
    }

    // Initialization from the gRPC model
    init(from entity: Entities_CommentEntity) throws {
        commentServerId = try parseUUID(from: entity.commentID.server)
        postServerId = try parseUUID(from: entity.postID.server)
        memberServerId = try parseUUID(from: entity.memberID.server)
        text = entity.text
        replyToId = try? parseUUID(from: entity.replyEntity.replyToID.server)
        replyEntityType = try? ChatEntityType(from: entity.replyEntity.replyEntityType)
        timestamp = try parseDate(from: entity.timestamp.isoDate)
    }

    // Conversion to the gRPC model
    func toProto() -> Entities_CommentEntity {
        let result = Entities_CommentEntity.with {
            $0.commentID.server = commentServerId.uuidString
            $0.postID.server = postServerId.uuidString
            $0.memberID.server = memberServerId.uuidString
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
            let _ = try Request_ReceiveCommentPayload_Strict(from: result)
        } catch {
            fatalError(#file)
        }
        return result
    }
}
