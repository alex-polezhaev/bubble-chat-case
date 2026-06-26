import Foundation
import GRDB

extension AppDatabase {
    func findOrFetchMedia(mediaServerId: UUID) async throws -> Media {
        // Check for media presence in the database
        if let existingMedia = try await AppDatabase.shared.dbPool.write({ db in
            try Media.filter(Column("serverId") == mediaServerId).fetchOne(db)
        }) {
            return existingMedia
        }

        // Download the media file from the server
        let publicMedia = try await WebRequestManager().fetchMedia(mediaServerId: mediaServerId)

        // Save the media to the local database
        return try await AppDatabase.shared.dbPool.write { db in
            let newMedia = Media(id: UUID(), serverId: publicMedia.id, mediaType: .video, duration: publicMedia.duration)
            try newMedia.insert(db)
            return newMedia
        }
    }

    func findOrCreateMediaFromPublic(publicMedia: PublicMedia) async throws -> Media {
        // Check for media presence in the database
        if let existingMedia = try await AppDatabase.shared.dbPool.write({ db in
            try Media.filter(Column("serverId") == publicMedia.id).fetchOne(db)
        }) {
            return existingMedia
        }

        // Save the media to the local database
        return try await createMediaFromPublic(publicMedia: publicMedia)
    }

    func createMediaFromPublic(publicMedia: PublicMedia) async throws -> Media {
        try await AppDatabase.shared.dbPool.write { db in
            let newMedia = Media(id: UUID(),
                                 serverId: publicMedia.id,
                                 mediaType: publicMedia.mediaType,
                                 duration: publicMedia.duration)

            try newMedia.insert(db)
            return newMedia
        }
    }
}
