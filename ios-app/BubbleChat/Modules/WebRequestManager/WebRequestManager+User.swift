import Foundation
import Moya

extension WebRequestManager {
    func fetchUser(userServerId: UUID) async throws -> PublicUser {
        let target = BackendEndpoints.getUser(userServerId: userServerId)

        return try await withCheckedThrowingContinuation { continuation in
            provider.request(target) { result in
                switch result {
                case let .success(response):
                    do {
                        let decodedResponse = try JSONDecoder().decode(PublicUser.self, from: response.data)
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
