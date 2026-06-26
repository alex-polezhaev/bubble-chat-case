import Foundation
import GRPC
import NIO

final class ClientToServerProvider: ObservableObject {
    private let client: Services_ClientToServerStreamAsyncClient
    private var requestContinuation: AsyncStream<Requests_ClientRequest>.Continuation?
    private var responseStreamTask: Task<Void, Never>?

    init(connection: ClientConnection, callOptions: CallOptions) {
        client = Services_ClientToServerStreamAsyncClient(
            channel: connection,
            defaultCallOptions: callOptions
        )
    }

    /// Release resources
    func clean() {
        print("Cleaning up ClientToServerProvider resources")

        requestContinuation?.finish()
        requestContinuation = nil

        responseStreamTask?.cancel()
        responseStreamTask = nil
        Task { @MainActor in
            GRPCManager.shared.isCTSActive = false
        }
    }

    /// Start the stream
    func startStream() {
        let requestStream = AsyncStream<Requests_ClientRequest> { continuation in
            self.requestContinuation = continuation
        }

        responseStreamTask = Task(priority: .userInitiated) {
            do {
                let call = client.clientStream(requestStream)

                for try await response in call {
                    Task.detached(priority: .userInitiated) {
                        await self.handleResponse(response)
                    }
                }

                throw AppError.unknown(description: "Stream completed by server")
            } catch {
                print("Error in ClientToServerStream: \(error)")
                Task { @MainActor in
                    GRPCManager.shared.isCTSActive = false
                }
                clean()
                try? await Task.sleep(nanoseconds: 1_500_000_000) // Delay before reconnecting
                startStream()
            }
        }
    }

    private func handleResponse(_ response: Responses_ServerResponse) async {
        do {
            if response.requestID.value == "ping" {
                print("Connected to ClientToServer stream")
                Task { @MainActor in
                    GRPCManager.shared.isCTSActive = true
                }
                return
            }

            print("Received server response: \(response)")

            guard let requestId = UUID(uuidString: response.requestID.value),
                  let queueRequest = try await AppDatabase.shared.dbPool.read({ db in
                      try QueueRequest.fetchOne(db, key: requestId)
                  })
            else {
                throw GRPCStatus(code: .invalidArgument, message: "Invalid request ID")
            }

            if response.success == false {
                let errorMessage = response.errorMessage.isEmpty ? nil : response.errorMessage
                try AppDatabase.shared.negativeAttempt(queueRequestId: requestId, errorMessage: errorMessage)
                return
            }

            if queueRequest.success == true {
                print("QueueRequest already success")
                return
            }

            switch response.payload {
            case let .responseSendPost(notStrictResponse):
                let parsedResponse = try Response_SendPostPayload_Strict(from: notStrictResponse)
                try await handleSendPostReponse(res: parsedResponse, queueRequest: queueRequest)

            case let .responseSendComment(notStrictResponse):
                let parsedResponse = try Response_SendCommentPayload_Strict(from: notStrictResponse)
                try await handleSendCommentReponse(res: parsedResponse, queueRequest: queueRequest)

            case let .responseSendStatus(notStrictResponse):
                let parsedResponse = try Response_SendStatusPayload_Strict(from: notStrictResponse)
                try await handleSendStatusReponse(res: parsedResponse, queueRequest: queueRequest)

            case .none:
                print("Cannot handle server response: \(response)")

            default:
                print("TODO: Handle other response types")
            }

            try AppDatabase.shared.positiveAttempt(queueRequestId: requestId)
        } catch {
            print("Error handling response: \(error)")
        }
    }

    /// Send a request
    func send(request: Requests_ClientRequest) {
        requestContinuation?.yield(request)
    }
}
