import Foundation
import GRDB

extension ContactWithUserActivityProvider {
    func handleContactWithUserAndActivity(_ res: ContactResponses_ContactWithUserActivity_Strict) async throws {
        let dbPool = AppDatabase.shared.dbPool

        try await dbPool.write { db in
            // MARK: - Fetch or delete Contact

            guard var contact = try Contact.fetchOne(db, key: res.contactClientId) else {
                // HTTP DELETE contact logic
                print("Contact not found. Trigger delete logic.")
                return
            }

            if contact.serverId != res.contactServerId {
                contact.serverId = res.contactServerId
            }

            var user: User? = try User.fetchOne(db, key: contact.userId)

            // Reconnect lost connections
            if user == nil {
                user = try User.filter(Column("phone") == res.user.phone).fetchOne(db)
            }

            if user != nil {
                if user?.firstName != res.user.firstName {
                    user?.firstName = res.user.firstName
                }
                if user?.lastName != res.user.lastName {
                    user?.lastName = res.user.lastName
                }
                if user?.avatar != res.user.avatar {
                    user?.avatar = res.user.avatar
                }
                if user?.phone != res.user.phone {
                    user?.phone = res.user.phone
                }
            }

            if user == nil {
                user = User(serverId: res.user.id,
                            firstName: res.user.firstName,
                            lastName: res.user.lastName,
                            avatar: res.user.avatar,
                            phone: res.user.phone)
            }

            if contact.userId != user?.id {
                contact.userId = user?.id
            }

            try user?.save(db)
            try contact.save(db)

            var activity: UserActivity? = try UserActivity
                .filter(Column("serverId") == res.userActivity.id).fetchOne(db)

            if activity != nil {
                if activity?.status != res.userActivity.userStatus {
                    activity?.status = res.userActivity.userStatus
                }
                if activity?.lastActiveAt != res.userActivity.lastActiveAt {
                    activity?.lastActiveAt = res.userActivity.lastActiveAt
                }
            }

            if activity == nil, let user {
                activity = UserActivity(serverId: res.userActivity.id,
                                        user: user,
                                        lastActiveAt: res.userActivity.lastActiveAt,
                                        status: res.userActivity.userStatus)
            }

            try activity?.save(db)
        }
    }
}
