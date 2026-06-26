import Foundation

struct Response_SendPostPayload_Strict: Codable {
    var postClientId: UUID
    var postServerId: UUID
    var timestamp: Date

    init(postClientId: UUID, postServerId: UUID, timestamp: Date) {
        self.postClientId = postClientId
        self.postServerId = postServerId
        self.timestamp = timestamp
    }

    init(from entity: Entities_PostEntity) throws {
        postClientId = try parseUUID(from: entity.postID.client)
        postServerId = try parseUUID(from: entity.postID.server)
        timestamp = try parseDate(from: entity.timestamp.isoDate)
    }

    func toProto() -> Entities_PostEntity {
        let result = Entities_PostEntity.with {
            $0.postID.client = postClientId.uuidString
            $0.postID.server = postServerId.uuidString
            $0.timestamp.isoDate = timestamp.ISO8601Format()
        }

        do {
            let _ = try Response_SendPostPayload_Strict(from: result)
        } catch {
            fatalError(#file)
        }
        return result
    }
}
