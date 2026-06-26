import Foundation

struct ContactResponses_ContactWithUserActivity_Strict: Codable {
    var contactClientId: UUID
    var contactServerId: UUID // Added the serverId field
    var user: PublicUser
    var userActivity: PublicUserActivity

    init(
        contactClientId: UUID,
        contactServerId: UUID, // Added a parameter to the initializer
        user: PublicUser,
        userActivity: PublicUserActivity
    ) {
        self.contactClientId = contactClientId
        self.contactServerId = contactServerId
        self.user = user
        self.userActivity = userActivity
    }

    init(from payload: ContactResponses_ContactWithUserActivity) throws {
        contactClientId = try parseUUID(from: payload.contactID.client)
        contactServerId = try parseUUID(from: payload.contactID.server) // Process serverId
        user = try PublicUser(from: payload.user)
        userActivity = try PublicUserActivity(from: payload.userActivity)
    }

    func toProto() -> ContactResponses_ContactWithUserActivity {
        let result = ContactResponses_ContactWithUserActivity.with {
            $0.contactID.client = contactClientId.uuidString
            $0.contactID.server = contactServerId.uuidString // Set serverId
            $0.user = user.toProto()
            $0.userActivity = userActivity.toProto()
        }

        do {
            // Check that the fields are filled in
            let _ = try ContactResponses_ContactWithUserActivity_Strict(from: result)
        } catch {
            fatalError(#file)
        }
        return result
    }
}
