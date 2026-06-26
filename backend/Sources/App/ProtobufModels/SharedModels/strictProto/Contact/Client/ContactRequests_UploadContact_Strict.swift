import Foundation

struct ContactRequests_UploadContact_Strict: Codable {
    var contactClientId: UUID
    var givenName: String
    var familyName: String
    var phoneNumbers: [String]

    init(
        contactClientId: UUID,
        givenName: String,
        familyName: String,
        phoneNumbers: [String]
    ) {
        self.contactClientId = contactClientId
        self.givenName = givenName
        self.familyName = familyName
        self.phoneNumbers = phoneNumbers
    }

    init(from payload: ContactRequests_UploadContact) throws {
        contactClientId = try parseUUID(from: payload.contactID.client)
        givenName = payload.givenName
        familyName = payload.familyName
        phoneNumbers = payload.phoneNumbers
    }

    func toProto() -> ContactRequests_UploadContact {
        let result = ContactRequests_UploadContact.with {
            $0.contactID.client = contactClientId.uuidString
            $0.givenName = givenName
            $0.familyName = familyName
            $0.phoneNumbers = phoneNumbers
        }

        do {
            // Check that the fields are filled in
            let _ = try ContactRequests_UploadContact_Strict(from: result)
        } catch {
            fatalError(#file)
        }
        return result
    }
}
