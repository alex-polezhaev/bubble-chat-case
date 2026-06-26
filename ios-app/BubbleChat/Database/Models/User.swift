import Foundation
import GRDB

struct User: Codable, FetchableRecord, PersistableRecord, ServerIdentifiable {
    static let databaseTableName = "users"

    var id: UUID
    var serverId: UUID
    var firstName: String
    var lastName: String
    var avatar: String?
    var phone: String

    init(
        serverId: UUID,
        firstName: String,
        lastName: String,
        avatar: String?,
        phone: String
    ) {
        id = UUID()
        self.serverId = serverId
        self.firstName = firstName
        self.lastName = lastName
        self.avatar = avatar
        self.phone = phone
    }
}
