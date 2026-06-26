import Foundation
import GRPC
import NIO

final class ContactWithUserActivityProvider: ObservableObject {
    private let client: Services_ContactWithUserActivityStreamAsyncClient
    private var requestContinuation: AsyncStream<ContactRequests_UploadContact>.Continuation?
    private var responseStreamTask: Task<Void, Never>?

    @Published var isConnected: Bool = false

    init(connection: ClientConnection, callOptions: CallOptions) {
        client = Services_ContactWithUserActivityStreamAsyncClient(
            channel: connection,
            defaultCallOptions: callOptions
        )
    }

    /// Release resources
    func clean() {
        print("Cleaning up ContactWithUserActivityProvider resources")
        requestContinuation?.finish()
        requestContinuation = nil

        responseStreamTask?.cancel()
        responseStreamTask = nil

        Task { @MainActor in
            GRPCManager.shared.isCWUAActive = false
        }
    }

    /// Start the stream
    func startStream() {
        let requestStream = AsyncStream<ContactRequests_UploadContact> { continuation in
            self.requestContinuation = continuation
        }

        responseStreamTask = Task {
            do {
                let call = client.contactUserActivityStream(requestStream)

                for try await notStrictResponse in call {
                    if notStrictResponse.contactID.server == "ping" {
                        print("Connected to ContactWithUserActivity stream")
                        Task { @MainActor in
                            GRPCManager.shared.isCWUAActive = true
                        }
                        continue
                    }

                    let response = try ContactResponses_ContactWithUserActivity_Strict(from: notStrictResponse)
                    try await handleContactWithUserAndActivity(response)
                }

                throw AppError.unknown(description: "Stream completed by server")
            } catch {
                print("Unhandled error in ContactWithUserActivityStream: \(error)")
                Task { @MainActor in
                    GRPCManager.shared.isCWUAActive = false
                }
                clean()
                try? await Task.sleep(nanoseconds: 1_500_000_000)
                startStream()
            }
        }
    }

    /// Send data
    func uploadContact(_ contact: ContactRequests_UploadContact_Strict) {
        requestContinuation?.yield(contact.toProto())
    }
}
