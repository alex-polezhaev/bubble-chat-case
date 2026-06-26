import Foundation

struct Response_SendCommentPayload_Strict: Codable {
    var commentClientId: UUID
    var commentServerId: UUID
    var timestamp: Date

    init(commentClientId: UUID, commentServerId: UUID, timestamp: Date) {
        self.commentClientId = commentClientId
        self.commentServerId = commentServerId
        self.timestamp = timestamp
    }

    // Initialization from the gRPC model
    init(from entity: Entities_CommentEntity) throws {
        commentClientId = try parseUUID(from: entity.commentID.client)
        commentServerId = try parseUUID(from: entity.commentID.server)
        timestamp = try parseDate(from: entity.timestamp.isoDate)
    }

    // Conversion to the gRPC model
    func toProto() -> Entities_CommentEntity {
        let result = Entities_CommentEntity.with {
            $0.commentID.client = commentClientId.uuidString
            $0.commentID.server = commentServerId.uuidString
            $0.timestamp.isoDate = timestamp.ISO8601Format()
        }

        do {
            // Check that the fields are filled in
            let _ = try Response_SendCommentPayload_Strict(from: result)
        } catch {
            fatalError(#file)
        }
        return result
    }
}
