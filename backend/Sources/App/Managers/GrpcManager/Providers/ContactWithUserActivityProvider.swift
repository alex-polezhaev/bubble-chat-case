import Fluent
import GRPC
import NIO
import Vapor

final class ContactWithUserActivityProvider: Services_ContactWithUserActivityStreamAsyncProvider {
    let app: Application

    init(app: Application) {
        self.app = app
    }

    func contactUserActivityStream(
        requestStream: GRPCAsyncRequestStream<ContactRequests_UploadContact>,
        responseStream: GRPCAsyncResponseStreamWriter<ContactResponses_ContactWithUserActivity>,
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

        userActivity.isContactStreamActive = true
        try await userActivity.save(on: app.db)

        print("[GRPC Connect] [ContactUserActivityStream] - \(user.firstName) \(user.lastName)")

        try await responseStream.send(ContactResponses_ContactWithUserActivity.with { $0.contactID.server = "ping" })

        // Start the sending loop
        let sendTask = Task {
            await sendContactUpdates(for: user, to: responseStream)
        }

        do {
            for try await notStrictRequest in requestStream {
                print("Received contact: \(notStrictRequest)")

                let request: ContactRequests_UploadContact_Strict

                do {
                    request = try ContactRequests_UploadContact_Strict(from: notStrictRequest)
                } catch {
                    throw GRPCStatus(code: .invalidArgument, message: "Invalid payload schema")
                }

                let response = try await handleUploadContact(request, user: user)?.toProto()

                if let response {
                    try await responseStream.send(response)
                }
            }
        } catch {
            print("Error in ContactUserActivityStream: \(String(reflecting: error))")
        }

        // Stop sending if the connection is closing
        sendTask.cancel()

        print("[GRPC Close] [ContactUserActivityStream] - \(user.firstName) \(user.lastName)")
        userActivity.isContactStreamActive = false
        userActivity.lastActiveAt = Date()
        try await userActivity.save(on: app.db)
    }

    private func sendContactUpdates(
        for user: User,
        to responseStream: GRPCAsyncResponseStreamWriter<ContactResponses_ContactWithUserActivity>
    ) async {
        while true {
            do {
                let userId = try user.requireID()
                // Get contacts with activity
                let contacts = try await Contact.query(on: app.db)
                    .with(\.$targetUser)
                    .filter(\.$user.$id == userId)
                    .filter(\.$targetUser.$id != nil)
                    .all()

                for contact in contacts {
                    guard let targetUser = contact.targetUser else {
                        return
                    }

                    let targetUserId = try targetUser.requireID()

                    let contactUserActivity = try await UserActivity.query(on: app.db)
                        .filter(\.$user.$id == targetUserId)
                        .first()

                    let response = try ContactResponses_ContactWithUserActivity_Strict(
                        contactClientId: contact.clientId,
                        contactServerId: contact.requireID(),
                        user: targetUser.asPublic(),
                        userActivity: contactUserActivity!.asPublic()
                    )

                    try await responseStream.send(response.toProto())
                }
            } catch {
                print("Error sending contact updates: \(error)")
                break
            }

            // Wait 1 second before the next send
            try? await Task.sleep(nanoseconds: 1_500_000_000)
        }
    }
}
