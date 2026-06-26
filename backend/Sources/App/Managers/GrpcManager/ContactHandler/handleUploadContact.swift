import Fluent
import Vapor

extension ContactWithUserActivityProvider {
    func handleUploadContact(_ req: ContactRequests_UploadContact_Strict, user: User) async throws -> ContactResponses_ContactWithUserActivity_Strict? {
        let userId = try user.requireID()

        let existingContact = try await Contact.query(on: app.db)
            .with(\.$targetUser)
            .filter(\.$clientId == req.contactClientId)
            .filter(\.$user.$id == userId)
            .first()

        let currentContact: Contact

        if let existingContact {
            currentContact = existingContact

            var changed = false

            if existingContact.givenName != req.givenName {
                existingContact.givenName = req.givenName
                changed = true
            }
            if existingContact.familyName != req.familyName {
                existingContact.familyName = req.familyName
                changed = true
            }

            // If the new numbers differ, the linked user must be removed
            if existingContact.phoneNumbers != req.phoneNumbers {
                existingContact.targetUser = nil
                existingContact.phoneNumbers = req.phoneNumbers
                changed = true
            }

            if changed {
                try await existingContact.save(on: app.db)
            }

        } else {
            let newContact = try Contact(clientId: req.contactClientId,
                                         user: user,
                                         targetUser: nil,
                                         givenName: req.givenName,
                                         familyName: req.familyName,
                                         phoneNumbers: req.phoneNumbers)

            try await newContact.save(on: app.db)

            try await newContact.$targetUser.load(on: app.db)

            currentContact = newContact
        }

        if currentContact.targetUser == nil {
            if let potentialtargetUser = try await User.query(on: app.db)
                .filter(\.$phone ~~ req.phoneNumbers)
                .first()
            {
                currentContact.$targetUser.id = potentialtargetUser.id
                try await currentContact.save(on: app.db)
            }
        }

        if let targetUser = currentContact.targetUser {
            let targetUserId = try targetUser.requireID()

            guard let targetUserActivity = try await UserActivity.query(on: app.db)
                .filter(\.$user.$id == targetUserId)
                .first()
            else {
                throw Abort(.internalServerError, reason: "Not found user activity")
            }

            return try ContactResponses_ContactWithUserActivity_Strict(
                contactClientId: currentContact.clientId,
                contactServerId: currentContact.requireID(),
                user: targetUser.asPublic(),
                userActivity: targetUserActivity.asPublic()
            )
        }

        return nil
    }
}
