import Foundation
import GRDB

struct Media: Codable, FetchableRecord, PersistableRecord, OptionalServerIdentifiable {
    static let databaseTableName = "media"

    var id: UUID
    var serverId: UUID?
    var mediaType: MediaType
    var duration: Int?

    init(id: UUID,
         serverId: UUID?,
         mediaType: MediaType,
         duration: Int?)
    {
        self.id = id
        self.serverId = serverId
        self.mediaType = mediaType
        self.duration = duration
    }
}

extension Media {
    func asPublic() throws -> PublicMedia {
        guard let serverId else {
            throw AppError.database(description: "not serverId found media")
        }
        return try PublicMedia(id: serverId, userId: UserManager.shared.getCurrentUser().serverId, mediaType: mediaType, duration: duration)
    }
}
