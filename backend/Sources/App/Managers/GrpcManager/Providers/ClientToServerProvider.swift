import Fluent
import GRPC
import NIO
import Vapor

final class ClientToServerProvider: Services_ClientToServerStreamAsyncProvider {
    let app: Application

    init(app: Application) {
        self.app = app
    }

    func clientStream(
        requestStream: GRPCAsyncRequestStream<Requests_ClientRequest>,
        responseStream: GRPCAsyncResponseStreamWriter<Responses_ServerResponse>,
        context: GRPCAsyncServerCallContext
    ) async throws {
        guard let userIdString = context.request.headers.first(name: "user_id"),
              let userId = UUID(uuidString: userIdString),
              let user = try await User.find(userId, on: app.db),
              let userActivity = try await UserActivity.query(on: app.db)
              .filter(\.$user.$id == userId).first()
        else {
            throw GRPCStatus(code: .unauthenticated, message: "Invalid auth attempt")
        }

        userActivity.isClientToServerStreamActive = true
        try await userActivity.save(on: app.db)

        print("[GRPC Connect] [Client-Server] - \(user.firstName) \(user.lastName)")

        try await responseStream.send(Responses_ServerResponse.with { $0.requestID.value = "ping" })

        do {
            for try await notStrictRequest in requestStream {
                print("Received request: \(notStrictRequest)")

                var response = Responses_ServerResponse.with {
                    $0.requestID = notStrictRequest.requestID
                    $0.success = true
                }

                do {
                    switch notStrictRequest.payload {
                    case let .requestSendPost(notStrict):
                        let strictReq = try Request_SendPostPayload_Strict(from: notStrict)
                        response.responseSendPost = try await handleSendPost(strictReq, user: user).toProto()

                    case let .requestSendComment(notStrict):
                        let strictReq = try Request_SendCommentPayload_Strict(from: notStrict)
                        response.responseSendComment = try await handleSendComment(strictReq, user: user).toProto()

                    case let .requestSendLayer(notStrict):
                        let strictReq = try Request_SendLayerPayload_Strict(from: notStrict)
                        response.responseSendLayer = try await handleSendLayer(strictReq, user: user).toProto()

                    case let .requestSendReaction(notStrict):
                        let strictReq = try Request_SendReactionPayload_Strict(from: notStrict)
                        response.responseSendReaction = try await handleSendReaction(strictReq, user: user).toProto()

                    case let .requestSendStatus(notStrict):
                        let strictReq = try Request_SendStatusPayload_Strict(from: notStrict)
                        response.responseSendStatus = try await handleSendStatus(strictReq, user: user).toProto()

                    case .none:
                        throw GRPCStatus(code: .invalidArgument, message: "none payload")
                    }

                } catch {
                    return try await sendNegativeResponse("\(String(reflecting: error))", responseStream: responseStream, reqId: notStrictRequest.requestID)
                }

                // Send the response
                try await responseStream.send(response)
            }

        } catch {
            print("Error in ClientToServerStream: \(String(reflecting: error))")
        }

        print("[GRPC Close] [Client-Server] - \(user.firstName) \(user.lastName)")

        userActivity.isClientToServerStreamActive = false
        try await userActivity.save(on: app.db)
    }

    func sendNegativeResponse(_ msg: String, responseStream: GRPCAsyncResponseStreamWriter<Responses_ServerResponse>, reqId: Common_RequestId) async throws {
        let response = Responses_ServerResponse.with {
            $0.requestID = reqId
            $0.success = false
            $0.errorMessage = msg
        }

        try await responseStream.send(response)
    }
}
