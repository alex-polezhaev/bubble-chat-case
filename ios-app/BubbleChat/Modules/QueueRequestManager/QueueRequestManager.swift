import Foundation
import GRDB

class QueueRequestManager {
    func pushQueueRequest(method: QueueRequestClientMethod, serializedRequest: Data) throws {
        var provider: QueueRequestGrpcProvider {
            switch method {
            case .sendPost:
                .ClientToServer
            case .sendComment:
                .ClientToServer
            case .sendDeliveryStatus:
                .ClientToServer
            }
        }

        let newReq = try AppDatabase.shared.dbPool.write { db in
            let newReq = QueueRequest(method: method,
                                      provider: provider,
                                      payload: serializedRequest,
                                      success: nil,
                                      errorMessages: [],
                                      attempts: 0,
                                      createdAt: Date(),
                                      closedAt: nil)

            try newReq.insert(db)
            return newReq
        }

        try deSerializeAndSend(queueRequest: newReq)
    }

    func sendPendingRequests() {
        guard let requests = try? AppDatabase.shared.dbPool.read({ db in
            try QueueRequest.filter(Column("success") == nil).fetchAll(db)
        }) else {
            print("error \(#function)")
            return
        }

        for req in requests {
            do {
                try deSerializeAndSend(queueRequest: req)
            } catch {
                print("erorr when try to send request \(error)")
            }
        }
    }

    func deSerializeAndSend(queueRequest: QueueRequest) throws {
        switch queueRequest.provider {
        case .ClientToServer:
            let grpcRequest = try Requests_ClientRequest.with {
                $0.requestID.value = queueRequest.id.uuidString
                switch queueRequest.method {
                case .sendPost:
                    $0.requestSendPost = try Entities_PostEntity(serializedBytes: queueRequest.payload)
                case .sendComment:
                    $0.requestSendComment = try Entities_CommentEntity(serializedBytes: queueRequest.payload)
                case .sendDeliveryStatus:
                    $0.requestSendStatus = try CommonRequests_DeliveryStatusPayload(serializedBytes: queueRequest.payload)
                }
            }

            print(#function)
            print(grpcRequest)

            Task(priority: .userInitiated) {
                GRPCManager.shared.clientToServerProvider?.send(request: grpcRequest)
            }

        default:
            throw AppError.unknown(description: "invalid provider")
        }
    }
}
