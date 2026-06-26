import Fluent
import Foundation
import GRPC
import Vapor

// Structure to store the UserID and the associated stream
struct UserStream: Hashable {
    let userId: UUID
    let stream: GRPCAsyncResponseStreamWriter<Requests_ServerRequest>

    func hash(into hasher: inout Hasher) {
        hasher.combine(userId) // Hash only the user identifier
    }

    static func == (lhs: UserStream, rhs: UserStream) -> Bool {
        return lhs.userId == rhs.userId // Comparison is also based on the identifier only
    }
}

actor ClientStreamRegistry {
    private var userStreams: Set<UserStream> = []
    private let app: Application

    init(app: Application) {
        self.app = app
        Task {
            await self.runTasks()
        }
    }

    /// Add a user and their response stream
    func addUser(userId: UUID, responseStream: GRPCAsyncResponseStreamWriter<Requests_ServerRequest>) {
        let userStream = UserStream(userId: userId, stream: responseStream)
        userStreams.insert(userStream)

        print(userStreams.count)
    }

    /// Remove a user and their stream
    func removeUser(userId: UUID) {
        if let existingStream = userStreams.first(where: { $0.userId == userId }) {
            userStreams.remove(existingStream)
        }
    }

    /// Get the response stream for a specific user
    func getStream(for userId: UUID) -> GRPCAsyncResponseStreamWriter<Requests_ServerRequest>? {
        print(userStreams)
        return userStreams.first(where: { $0.userId == userId })?.stream
    }

    /// Run tasks for the current array of users
    private func runTasks() async {
        while true {
            for userStream in userStreams {
                let userID = userStream.userId
                do {
                    try await QueueRequestManager(app: app).sendPendingRequests(userId: userID)
                } catch {
                    print("Error while executing task for userID \(userID): \(error)")
                }
            }
            // Delay of 2 seconds
            try? await Task.sleep(nanoseconds: 2_000_000_000)
        }
    }
}

final class ServerToClientProvider: Services_ServerToClientStreamAsyncProvider {
    let app: Application
    private let registry: ClientStreamRegistry

    init(app: Application) {
        self.app = app
        registry = ClientStreamRegistry(app: app)
    }

    func serverStream(
        requestStream: GRPCAsyncRequestStream<Responses_ClientResponse>,
        responseStream: GRPCAsyncResponseStreamWriter<Requests_ServerRequest>,
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

        userActivity.isServerToClientStreamActive = true
        try await userActivity.save(on: app.db)

        // Save the request stream
        await registry.addUser(userId: userId, responseStream: responseStream)

        print("[GRPC Connect] [Server-Client] - \(user.firstName) \(user.lastName)")

        try await responseStream.send(Requests_ServerRequest.with { $0.requestID.value = "ping" })

        // Handle incoming messages from the client
        do {
            for try await response in requestStream {
                print("Received response from client \(userId): \(response)")
                await handleClientResponse(clientId: userId, response: response)
            }
        } catch {
            print("Error in request stream for client \(userId): \(error)")
        }

        // Remove the client from the registry after the stream ends
        await registry.removeUser(userId: userId)

        print("[GRPC Close] [Server-Client] - \(user.firstName) \(user.lastName)")

        userActivity.isServerToClientStreamActive = false
        userActivity.lastActiveAt = Date()
        try await userActivity.save(on: app.db)
    }

    func sendRequestToClient(userId: UUID, request: Requests_ServerRequest) async throws {
        guard let responseStream = await registry.getStream(for: userId) else {
            print("Client \(userId) not found")
            return
        }

        do {
            try await responseStream.send(request)
            print("Request sent to client \(userId): \(request)")
        } catch {
            print("Error sending request to client \(userId): \(error)")
        }
    }

    private func handleClientResponse(clientId: UUID, response: Responses_ClientResponse) async {
        // Implement your response-handling logic here
        print("Handling response from client \(clientId): \(response)")

        guard let responseId = UUID(uuidString: response.requestID.value) else {
            print("Response without req id")
            return
        }

        // Look up the QueueRequest by reqId
        guard let queueRequest = try? await QueueRequest
            .query(on: app.db)
            .filter(\.$id == responseId)
            .with(\.$receiver)
            .first()
        else {
            print("QueueRequest with id \(responseId) not found")
            return
        }

        do {
            if queueRequest.success == true { return }

            try await handleResponseAndSendStatus(res: response, queueRequest: queueRequest)

            if response.success {
                try DatabaseManager(db: app.db).closeQueueRequest(queueRequest: queueRequest)

            } else {
                let errorMessage = response.errorMessage.isEmpty ? nil : response.errorMessage

                try DatabaseManager(db: app.db).negativeQueueRequest(queueRequest: queueRequest, errorMessage: errorMessage)
            }
        } catch {
            print(String(describing: error))
        }
    }
}
