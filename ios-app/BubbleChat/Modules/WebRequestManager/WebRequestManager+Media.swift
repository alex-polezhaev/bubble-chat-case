import Foundation
import Moya

extension WebRequestManager {
    func downloadAndCacheVideo(mediaServerId: UUID, mediaClientId: UUID) async throws -> URL {
        let target = BackendEndpoints
            .downloadMedia(serverId: mediaServerId, mediaType: .video)
        return try await withCheckedThrowingContinuation { continuation in
            provider.request(target) { result in
                switch result {
                case let .success(response):
                    do {
                        let fileUrl = try CacheManager.shared.save(data: response.data, filename: "\(mediaClientId.uuidString).mp4", category: "videos")
                        continuation.resume(returning: fileUrl)

                    } catch {
                        continuation.resume(throwing: error)
                    }
                case let .failure(error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    func downloadAndCachePreview(media: Media) async throws -> URL {
        guard let mediaServerId = media.serverId else {
            throw AppError.unknown(description: "no video server id to cache")
        }

        let target = BackendEndpoints
            .downloadMedia(serverId: mediaServerId, mediaType: .image)
        return try await withCheckedThrowingContinuation { continuation in
            provider.request(target) { result in
                switch result {
                case let .success(response):
                    do {
                        let fileUrl = try CacheManager.shared.save(data: response.data, filename: "\(media.id.uuidString).jpg", category: "images")
                        continuation.resume(returning: fileUrl)

                    } catch {
                        continuation.resume(throwing: error)
                    }
                case let .failure(error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    func fetchMedia(mediaServerId: UUID) async throws -> PublicMedia {
        let target = BackendEndpoints.getMedia(mediaServerId: mediaServerId)

        return try await withCheckedThrowingContinuation { continuation in
            provider.request(target) { result in
                switch result {
                case let .success(response):
                    do {
                        let decodedResponse = try JSONDecoder().decode(PublicMedia.self, from: response.data)
                        continuation.resume(returning: decodedResponse)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                case let .failure(error):
                    print(error)
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
