import Foundation
import Moya

extension WebRequestManager {
    func createChat(for users: [User], chatType: ChatType) async throws -> CreateChatResponse {
        let request = CreateChatRequest(chatType: chatType, receiverIds: users.map { $0.serverId })

        let target = BackendEndpoints.createChat(request: request)

        return try await withCheckedThrowingContinuation { continuation in
            provider.request(target) { result in
                switch result {
                case let .success(response):
                    do {
                        let decodedResponse = try JSONDecoder()
                            .decode(CreateChatResponse.self, from: response.data)
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

    func fetchChat(chatServerId: UUID) async throws -> CreateChatResponse {
        let target = BackendEndpoints.getChat(chatServerId: chatServerId)

        return try await withCheckedThrowingContinuation { continuation in
            provider.request(target) { result in
                switch result {
                case let .success(response):
                    do {
                        let decodedResponse = try JSONDecoder().decode(CreateChatResponse.self, from: response.data)
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
