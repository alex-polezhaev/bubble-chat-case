import Foundation
import GRPC
import NIO

final class ServerToClientProvider {
    private let client: Services_ServerToClientStreamAsyncClient

    private var requestContinuation: AsyncStream<Responses_ClientResponse>.Continuation?
    private var responseStreamTask: Task<Void, Never>?

    @Published var isConnected: Bool = false

    init(connection: ClientConnection, callOptions: CallOptions) {
        client = Services_ServerToClientStreamAsyncClient(
            channel: connection,
            defaultCallOptions: callOptions
        )
    }

    /// Release resources
    func clean() {
        print("Cleaning up ServerToClientProvider resources")
        requestContinuation?.finish()
        requestContinuation = nil

        responseStreamTask?.cancel()
        responseStreamTask = nil

        Task { @MainActor in
            GRPCManager.shared.isSTCActive = false
        }
    }

    /// Start the stream
    func startStream() {
        let responseStream = AsyncStream<Responses_ClientResponse> { continuation in
            self.requestContinuation = continuation
        }

        responseStreamTask = Task {
            do {
                let call = client.serverStream(responseStream)

                for try await req in call {
                    if req.requestID.value == "ping" {
                        Task { @MainActor in
                            GRPCManager.shared.isSTCActive = true
                        }
                        print("Connected to ServerToClientProvider")
                        continue
                    }

                    print("Received server request: \(req)")

                    Task.detached(priority: .userInitiated) {
                        try await self.handleServerRequest(req: req)
                    }
                }

                throw AppError.unknown(description: "Stream completed by server")
            } catch {
                print("Unhandled error in ServerToClientStream: \(error)")
                Task { @MainActor in
                    GRPCManager.shared.isSTCActive = false
                }
                clean()
                try? await Task.sleep(nanoseconds: 1_500_000_000)
                startStream()
            }
        }
    }
}

extension ServerToClientProvider {
    private func handleServerRequest(req: Requests_ServerRequest) async throws {
        print("Handling server request: \(req)")

        var response = Responses_ClientResponse.with {
            $0.requestID = req.requestID
            $0.success = true
        }

        do {
            switch req.payload {
            case let .requestReceivePost(payload):
                let request = try Request_ReceivePostPayload_Strict(from: payload)
                try await handleReceivePost(request)

            case let .requestReceiveComment(payload):
                let request = try Request_ReceiveCommentPayload_Strict(from: payload)
                try await handleReceiveComment(request)

            case let .requestReceiveStatus(payload):
                let request = try Request_ReceiveStatusPayload_Strict(from: payload)
                try await handleReceiveStatus(request)

            case .none:
                throw GRPCStatus(code: .invalidArgument, message: "Payload is none")

            default:
                throw GRPCStatus(code: .invalidArgument, message: "Unsupported payload type")
            }

        } catch {
            response.success = false
            response.errorMessage = "\(String(reflecting: error))"
        }

        requestContinuation?.yield(response)
    }
}
