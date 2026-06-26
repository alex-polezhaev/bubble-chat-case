import Foundation

struct Response_SendStatusPayload_Strict: Codable {
    var trackClientId: UUID
    var trackServerId: UUID
    var timestamp: Date

    init(
        trackClientId: UUID,
        trackServerId: UUID,
        timestamp: Date
    ) {
        self.trackClientId = trackClientId
        self.trackServerId = trackServerId
        self.timestamp = timestamp
    }

    init(from proto: CommonRequests_DeliveryStatusPayload) throws {
        trackClientId = try parseUUID(from: proto.trackID.client)
        trackServerId = try parseUUID(from: proto.trackID.server)
        timestamp = try parseDate(from: proto.timestamp.isoDate)
    }

    func toProto() -> CommonRequests_DeliveryStatusPayload {
        var proto = CommonRequests_DeliveryStatusPayload()
        proto.trackID.client = trackClientId.uuidString
        proto.trackID.server = trackServerId.uuidString
        proto.timestamp.isoDate = timestamp.ISO8601Format()
        return proto
    }
}
