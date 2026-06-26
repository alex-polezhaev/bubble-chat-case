import Foundation

struct Response_SendReactionPayload_Strict: Codable {
    var reactionClientId: UUID
    var reactionServerId: UUID
    var timestamp: Date

    init(reactionClientId: UUID, reactionServerId: UUID, timestamp: Date) {
        self.reactionClientId = reactionClientId
        self.reactionServerId = reactionServerId
        self.timestamp = timestamp
    }

    // Initialization from the gRPC model
    init(from entity: Entities_ReactionEntity) throws {
        reactionClientId = try parseUUID(from: entity.reactionID.client)
        reactionServerId = try parseUUID(from: entity.reactionID.server)
        timestamp = try parseDate(from: entity.timestamp.isoDate)
    }

    // Conversion to the gRPC model
    func toProto() -> Entities_ReactionEntity {
        let result = Entities_ReactionEntity.with {
            $0.reactionID.client = reactionClientId.uuidString
            $0.reactionID.server = reactionServerId.uuidString
            $0.timestamp.isoDate = timestamp.ISO8601Format()
        }

        do {
            // Check that the fields are filled in
            let _ = try Response_SendReactionPayload_Strict(from: result)
        } catch {
            fatalError(#file)
        }
        return result
    }
}
