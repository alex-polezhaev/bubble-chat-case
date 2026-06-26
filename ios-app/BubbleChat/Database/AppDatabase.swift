import Foundation
import GRDB

final class AppDatabase {
    static let shared = AppDatabase()
    let dbPool: DatabasePool

    private init() {
        do {
            // Path to the database
            let databaseURL = try FileManager.default
                .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                .appendingPathComponent("db.sqlite")

            // Database configuration
            var config = Configuration()
            config.foreignKeysEnabled = true
            dbPool = try DatabasePool(path: databaseURL.path, configuration: config)

            // Run migrations
            try migrator.migrate(dbPool)
        } catch {
            fatalError("Failed to initialize the database: \(error)")
        }
    }
}
