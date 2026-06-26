import Foundation

struct PublicMedia: Codable {
    var id: UUID
    var mediaType: MediaType
    var duration: Int?

    // Initialization from parameters with validation
    init(
        id: UUID,
        userId _: UUID,
        mediaType: MediaType,
        duration: Int?
    ) throws {
        self.id = id
        self.mediaType = mediaType
        self.duration = duration

        // Validation
        try validate()
    }

    // Initialization from the gRPC model with validation
    init(from entity: Entities_MediaEntity) throws {
        id = try parseUUID(from: entity.mediaID.server)
        mediaType = try MediaType(from: entity.mediaType)
        duration = entity.duration == 0 ? nil : Int(entity.duration)

        // Validation
        try validate()
    }

    // Structure validation
    func validate() throws {
        if mediaType == .video, duration == nil {
            throw ValidationError.invalidField()
        }
    }

    // Conversion to the gRPC model with validation
    func toProto() throws -> Entities_MediaEntity {
        do {
            try validate()
        } catch {
            throw ValidationError.invalidField()
        }

        return Entities_MediaEntity.with {
            $0.mediaID.server = id.uuidString
            $0.mediaType = mediaType.toProtoEnum()
            if let duration = duration {
                $0.duration = Double(duration)
            }
        }
    }
}
