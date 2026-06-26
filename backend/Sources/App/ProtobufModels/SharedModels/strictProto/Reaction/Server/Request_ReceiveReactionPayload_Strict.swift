import Foundation

struct Request_ReceiveReactionPayload_Strict: Codable {
    var reactionServerId: UUID
    var memberServerId: UUID
    var chatEntityType: ChatEntityType
    var postServerId: UUID?
    var commentServerId: UUID?
    var emoji: String
    var timestamp: Date

    init(
        reactionServerId: UUID,
        memberServerId: UUID,
        chatEntityType: ChatEntityType,
        postServerId: UUID?,
        commentServerId: UUID?,
        emoji: String,
        timestamp: Date
    ) {
        self.reactionServerId = reactionServerId
        self.memberServerId = memberServerId
        self.chatEntityType = chatEntityType
        self.postServerId = postServerId
        self.commentServerId = commentServerId
        self.emoji = emoji
        self.timestamp = timestamp
    }

    // Initialization from the gRPC model
    init(from entity: Entities_ReactionEntity) throws {
        reactionServerId = try parseUUID(from: entity.reactionID.server)
        memberServerId = try parseUUID(from: entity.memberID.server)
        chatEntityType = try ChatEntityType(from: entity.chatEntityType)
        postServerId = try? parseUUID(from: entity.postID.server)
        commentServerId = try? parseUUID(from: entity.commentID.server)
        emoji = entity.emoji
        timestamp = try parseDate(from: entity.timestamp.isoDate)
    }

    // Conversion to the gRPC model
    func toProto() -> Entities_ReactionEntity {
        let result = Entities_ReactionEntity.with {
            $0.reactionID.server = reactionServerId.uuidString
            $0.memberID.server = memberServerId.uuidString
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
            let _ = try Request_ReceiveReactionPayload_Strict(from: result)
        } catch {
            fatalError(#file)
        }
        return result
    }
}
