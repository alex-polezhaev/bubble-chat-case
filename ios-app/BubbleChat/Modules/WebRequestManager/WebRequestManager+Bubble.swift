import Foundation
import Moya

extension WebRequestManager {
    func sendPostVideo(videoUrl: URL,
                       previewUrl: URL,
                       duration: Int,
                       clientId: UUID) async throws -> PublicMedia
    {
        let target = BackendEndpoints.uploadVideoAndPreview(clientId: clientId,
                                                            videoUrl: videoUrl,
                                                            previewUrl: previewUrl,
                                                            duration: duration)

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
