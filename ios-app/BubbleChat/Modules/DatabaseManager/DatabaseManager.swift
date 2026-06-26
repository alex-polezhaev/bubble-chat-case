import Foundation
import GRDB

class DatabaseManager {
    private let db: DatabasePool

    init() {
        db = AppDatabase.shared.dbPool
    }
}
