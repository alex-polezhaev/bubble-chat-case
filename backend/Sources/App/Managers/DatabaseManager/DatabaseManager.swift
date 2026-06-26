import Fluent
import Vapor

class DatabaseManager: @unchecked Sendable {
    var db: Database

    init(db: Database) {
        self.db = db
    }
}
