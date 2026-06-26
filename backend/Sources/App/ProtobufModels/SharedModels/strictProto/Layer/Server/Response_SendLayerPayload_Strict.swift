import Foundation

struct Response_SendLayerPayload_Strict: Codable {
    var layerClientId: UUID
    var layerServerId: UUID
    var timestamp: Date

    init(layerClientId: UUID, layerServerId: UUID, timestamp: Date) {
        self.layerClientId = layerClientId
        self.layerServerId = layerServerId
        self.timestamp = timestamp
    }

    // Initialization from the gRPC model
    init(from entity: Entities_LayerEntity) throws {
        layerClientId = try parseUUID(from: entity.layerID.client)
        layerServerId = try parseUUID(from: entity.layerID.server)
        timestamp = try parseDate(from: entity.timestamp.isoDate)
    }

    // Conversion to the gRPC model
    func toProto() -> Entities_LayerEntity {
        let result = Entities_LayerEntity.with {
            $0.layerID.client = layerClientId.uuidString
            $0.layerID.server = layerServerId.uuidString
            $0.timestamp.isoDate = timestamp.ISO8601Format()
        }

        do {
            // Check that the fields are filled in
            let _ = try Response_SendLayerPayload_Strict(from: result)
        } catch {
            fatalError(#file)
        }
        return result
    }
}
