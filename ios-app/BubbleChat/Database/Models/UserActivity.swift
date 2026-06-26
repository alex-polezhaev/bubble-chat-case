import Foundation
import GRDB

struct UserActivity: Codable, FetchableRecord, PersistableRecord, ServerIdentifiable {
    static let databaseTableName = "user_activities"

    var id: UUID
    var serverId: UUID
    var userId: UUID
    var lastActiveAt: Date
    var status: UserStatus

    init(serverId: UUID, user: User, lastActiveAt: Date, status: UserStatus) {
        id = UUID()
        self.serverId = serverId
        userId = user.id
        self.lastActiveAt = lastActiveAt
        self.status = status
    }
}
