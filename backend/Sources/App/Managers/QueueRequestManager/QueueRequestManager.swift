import Fluent
import Foundation
import GRPC
import Vapor

final class QueueRequestManager {
    let app: Application
    let provider: ServerToClientProvider!

    init(app: Application) {
        self.app = app
        provider = app.grpcServerToClientProvider
    }

    func pushQueueRequest(method: QueueRequestServerMethod, serializedPayload: Data, chatMembers: [ChatMember], user: User) async throws {
        var provider: QueueRequestGrpcProvider {
            return .ServerToClient
        }

        for receiver in chatMembers {
            try await receiver.$user.load(on: app.db)

            let newReq = try QueueRequest(id: UUID(),
                                          user: user,
                                          receiver: receiver.user,
                                          method: method,
                                          provider: provider,
                                          payload: serializedPayload,
                                          success: nil,
                                          errorMessages: [],
                                          attempts: 0,
                                          createdAt: Date(),
                                          closedAt: nil)

            try await newReq.save(on: app.db)

            try await deSerializeAndSend(queueRequest: newReq, receiverId: receiver.user.requireID())
        }
    }

    func sendPendingRequests(userId: UUID) async throws {
        let requests = try await QueueRequest
            .query(on: app.db)
            .filter(\.$success == nil)
            .filter(\.$receiver.$id == userId)
            .filter(\.$createdAt < Date().addingTimeInterval(-2)) // Filter by createdAt
            .with(\.$receiver)
            .all()

        for req in requests {
            do {
                try await deSerializeAndSend(queueRequest: req, receiverId: userId)
            } catch {
                print("erorr when try to send request \(error)")
            }
        }
    }

    func deSerializeAndSend(queueRequest: QueueRequest, receiverId: UUID) async throws {
        switch queueRequest.provider {
        case .ServerToClient:
            let grpcRequest = try Requests_ServerRequest.with {
                $0.requestID.value = try queueRequest.requireID().uuidString
                switch queueRequest.method {
                case .receivePost:
                    $0.requestReceivePost = try Entities_PostEntity(serializedBytes: queueRequest.payload)
                case .receiveComment:
                    $0.requestReceiveComment = try Entities_CommentEntity(serializedBytes: queueRequest.payload)
                case .receiveLayer:
                    $0.requestReceiveLayer = try Entities_LayerEntity(serializedBytes: queueRequest.payload)
                case .receiveReaction:
                    $0.requestReceiveReaction = try Entities_ReactionEntity(serializedBytes: queueRequest.payload)
                case .receiveDeliveryStatus:
                    $0.requestReceiveStatus = try CommonRequests_DeliveryStatusPayload(serializedBytes: queueRequest.payload)
                }
            }

            try await provider.sendRequestToClient(userId: receiverId, request: grpcRequest)

        default:
            print(#file + "invalid provider")
        }
    }
}
