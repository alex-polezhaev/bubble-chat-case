import Contacts
import GRDB

func updateLocalContacts() async throws {
    // Create the database

    try await AppDatabase.shared.dbPool.write { db in
        // Load all existing contacts from the database in a single query
        let existingContacts = try Contact.fetchAll(db)

        // Create a dictionary for fast lookup of existing contacts by UUID
        var dbContactsDict = Dictionary(uniqueKeysWithValues: existingContacts.map {
            ($0.id, $0)
        })

        // Fetch contacts from the device and build a set of on-device contact identifiers
        let store = CNContactStore()
        let keysToFetch = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey, CNContactIdentifierKey] as [CNKeyDescriptor]
        let request = CNContactFetchRequest(keysToFetch: keysToFetch)

        var realDeviceContactIDs = Set<UUID>()

        try store.enumerateContacts(with: request) { contact, _ in
            do {
                realDeviceContactIDs.insert(contact.id)

                let givenName = contact.givenName
                let familyName = contact.familyName
                let phoneNumbers = contact.phoneNumbers.compactMap {
                    parsePhoneNumber($0.value.stringValue)
                }

                if contact.givenName.isEmpty, contact.familyName.isEmpty { return }

                let blockedPhoneNumber = UserManager.shared.getCurrentUser().phone

                if phoneNumbers.contains(blockedPhoneNumber) || phoneNumbers.isEmpty {
                    return
                }

                var contactToUpload: Contact?

                if var contactToUpdate = dbContactsDict[contact.id] {
                    contactToUpdate.givenName = givenName
                    contactToUpdate.familyName = familyName
                    contactToUpdate.phoneNumbers = phoneNumbers

                    try contactToUpdate.update(db)

                    if contactToUpdate.serverId == nil {
                        contactToUpload = contactToUpdate
                    }

                    dbContactsDict.removeValue(forKey: contact.id)
                } else {
                    let newContact = Contact(
                        id: contact.id,
                        serverId: nil,
                        user: nil,
                        givenName: givenName,
                        familyName: familyName,
                        phoneNumbers: phoneNumbers
                    )

                    try newContact.insert(db)
                    contactToUpload = newContact
                }

                if let contactToUpload {
                    Task {
                        // Call ContactRequests_UploadContact_Strict
                        let request = ContactRequests_UploadContact_Strict(
                            contactClientId: contactToUpload.id,
                            givenName: contactToUpload.givenName,
                            familyName: contactToUpload.familyName,
                            phoneNumbers: contactToUpload.phoneNumbers
                        )
                        print("Uploading contact: \(request)")

                        GRPCManager.shared.contactWithUserActivityProvider?.uploadContact(request)
                    }
                }

            } catch {
                print(error)
            }
        }

        // Remove contacts that are no longer on the device
        for contact in dbContactsDict.values {
            if !realDeviceContactIDs.contains(contact.id) {
                try contact.delete(db)
            }
        }
    }
}
