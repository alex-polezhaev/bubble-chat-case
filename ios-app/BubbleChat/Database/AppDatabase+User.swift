import Foundation
import GRDB

extension AppDatabase {
    func findOrFetchUser(userServerId: UUID) async throws -> User {
        if let existingUser = try await AppDatabase.shared.dbPool.write({ db in
            try User.filter(Column("serverId") == userServerId).fetchOne(db)

        }) {
            return existingUser
        }

        let response = try await WebRequestManager().fetchUser(userServerId: userServerId)

        return try await AppDatabase.shared.dbPool.write { db in
            // Create a new dialogue
            let newUser = User(serverId: response.id,
                               firstName: response.firstName,
                               lastName: response.lastName,
                               avatar: response.avatar,
                               phone: response.phone)
            try newUser.insert(db)
            return newUser
        }
    }
}
