import Foundation
import GRDB

struct Contact: Codable, Hashable, FetchableRecord, PersistableRecord, OptionalServerIdentifiable {
    static let databaseTableName = "contacts"

    var id: UUID
    var serverId: UUID?
    var userId: UUID?
    var givenName: String
    var familyName: String
    var phoneNumbers: [String]

    init(id: UUID,
         serverId: UUID?,
         user: User?,
         givenName: String,
         familyName: String,
         phoneNumbers: [String])
    {
        self.id = id
        self.serverId = serverId
        userId = user?.id
        self.givenName = givenName
        self.familyName = familyName
        self.phoneNumbers = phoneNumbers
    }
}
